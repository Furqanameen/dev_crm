require 'ostruct'

class Brevo::EmailSender
  include ActiveSupport::Benchmarkable
  
  def initialize(schedule = nil)
    @schedule = schedule
    @template = schedule&.template
    @provider = schedule&.provider
    @api_client = Brevo::ApiClient.new
  end

  # Main method to process a schedule and send emails
  def send_campaign
    Rails.logger.info "Starting Brevo campaign for Schedule ID: #{@schedule.id}"
    
    # Update schedule state
    @schedule.update!(state: :sending)
    
    begin
      # Get target contacts
      contacts = get_target_contacts
      
      if contacts.empty?
        Rails.logger.warn "No contacts found for schedule #{@schedule.id}"
        @schedule.update!(state: :failed)
        return { success: false, message: "No contacts to send to" }
      end

      # Create messages in database (your existing flow)
      create_messages_for_contacts(contacts)
      
      # Choose sending method based on volume
      result = if contacts.count <= 50
        # For small lists, send individual emails for better tracking
        send_individual_emails(contacts)
      else
        # For larger lists, use Brevo campaigns
        send_campaign_to_lists
      end
      
      if result[:success]
        @schedule.update!(state: :completed)
        Rails.logger.info "Campaign completed successfully for Schedule ID: #{@schedule.id}"
      else
        @schedule.update!(state: :failed)
        Rails.logger.error "Campaign failed for Schedule ID: #{@schedule.id}: #{result[:message]}"
      end
      
      result
      
    rescue => e
      Rails.logger.error "Error in Brevo campaign: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @schedule.update!(state: :failed)
      { success: false, message: e.message }
    end
  end

  def send_test_email(template:, to_email:, to_name:)
    api_client = Brevo::ApiClient.new

    # Create a temporary contact object for the test
    test_contact = OpenStruct.new(
      email: to_email,
      full_name: to_name,
      company_name: "Test Company Ltd",
      mobile_number: "+1234567890",
      account_type: "company",
      tags: ["technology", "testing"],
      display_name: to_name,
      individual?: false
    )

    # Use Brevo template if external_template_id is present
    if template.external_template_id.present?
      # Use the enhanced parameter mapping from the API client
      result = api_client.send_transactional_email_with_template(
        template_id: template.external_template_id,
        contact: test_contact,
        params: {
          # Override with test-specific values
          "Their Industry" => "technology",
          "Test Mode" => "Yes",
          "Subject Line" => template.subject || "Test Email"
        }
      )
    else
      # Send test email using the existing transactional method
      result = api_client.send_transactional_email(
        template: template,
        contact: test_contact
      )
    end

    Rails.logger.info "Test email sent to #{to_email}: #{result.inspect}"
    result
  end

  private

  def get_target_contacts
    case @schedule.target_type
    when 'List'
      @schedule.target.contacts.where(consent_status: [:opted_in, :pending, :consented])
                               .where(bounced: false)
                               .where("email IS NOT NULL AND email != ''")
    else
      # Handle other target types in future
      Contact.none
    end
  end

  def create_messages_for_contacts(contacts)
    contacts.find_each do |contact|
      # Skip if message already exists (preventing duplicates)
      next if @schedule.messages.exists?(contact: contact)
      
      @schedule.messages.create!(
        contact: contact,
        channel: :email,
        provider: @provider,
        status: :queued,
        queued_at: Time.current
      )
    end
  end

  def send_individual_emails(contacts)
    success_count = 0
    failure_count = 0
    
    contacts.find_each do |contact|
      message = @schedule.messages.find_by(contact: contact)
      next unless message
      
      begin
        # Use Brevo template if external_template_id is present
        if @template.external_template_id.present?
          result = @api_client.send_transactional_email_with_template(
            template_id: @template.external_template_id,
            contact: contact,
            params: prepare_template_params(contact)
          )
        else
          # Send via Brevo transactional API with local template
          result = @api_client.send_transactional_email(
            template: @template,
            contact: contact,
            custom_data: @schedule.merge_data || {}
          )
        end
        
        # Update message with success
        message.update!(
          provider_message_id: result.message_id,
          status: :sent,
          sent_at: Time.current
        )
        
        success_count += 1
        Rails.logger.info "Email sent to #{contact.email}: #{result.message_id}"
        
      rescue => e
        # Update message with failure
        message.update!(
          status: :failed,
          last_error: e.message,
          attempts: (message.attempts || 0) + 1
        )
        
        failure_count += 1
        Rails.logger.error "Failed to send email to #{contact.email}: #{e.message}"
      end
    end
    
    {
      success: failure_count == 0,
      message: "Sent: #{success_count}, Failed: #{failure_count}",
      sent_count: success_count,
      failed_count: failure_count
    }
  end

  # Prepare template parameters for Brevo template
  def prepare_template_params(contact)
    # Start with basic params structure
    params = {}
    
    # Add contact-specific data based on account type using Brevo template syntax
    if contact.account_type == 'individual'
      params.merge!({
        "contact_person_name" => contact.full_name || "Dear Friend",
        "company_name" => contact.company_name || "Your Company",
        "first_name" => contact.full_name&.split(' ')&.first || "Friend",
        "last_name" => contact.full_name&.split(' ')&.drop(1)&.join(' ') || "",
        "full_name" => contact.full_name,
        "their_industry" => extract_industry_from_contact(contact) || "your industry"
      })
    else # company contact
      params.merge!({
        "contact_person_name" => contact.full_name || "Dear Sir/Madam",
        "company_name" => contact.company_name,
        "first_name" => contact.full_name&.split(' ')&.first || "Dear",
        "last_name" => contact.full_name&.split(' ')&.drop(1)&.join(' ') || "Sir/Madam",
        "full_name" => contact.full_name || "Dear Sir/Madam",
        "their_industry" => extract_industry_from_contact(contact) || "business"
      })
    end
    
    # Additional dynamic fields using lowercase underscore format
    params.merge!({
      "display_name" => contact.display_name,
      "account_type" => contact.account_type&.humanize
    })
    
    # Add any custom merge data from the schedule
    if @schedule.merge_data.present?
      params.merge!(@schedule.merge_data)
    end
    
    # Add contact tags if available - and use first tag as industry if available
    if contact.tags.present?
      params["tags"] = contact.tags.join(", ")
      # Use first tag as potential industry if no industry found
      if params["their_industry"] == "your industry" || params["their_industry"] == "business"
        params["their_industry"] = contact.tags.first.downcase
      end
    end
    
    # Clean up nil values and provide fallbacks
    params.each do |key, value|
      if value.blank?
        params[key] = case key
        when "contact_person_name", "full_name" then "Dear Customer"
        when "first_name" then "Dear"
        when "last_name" then "Customer"  
        when "company_name" then "Your Company"
        when "their_industry" then "your industry"
        else ""
        end
      end
    end
    
    Rails.logger.info "Template params for #{contact.email}: #{params.inspect}"
    params
  end
  
  private
  
  # Extract industry information from contact
  def extract_industry_from_contact(contact)
    # Try to extract industry from various sources
    if contact.tags.present?
      # Look for industry-related tags
      industry_tags = contact.tags.select do |tag|
        tag.match?(/(tech|finance|healthcare|retail|restaurant|legal|construction|marketing|consulting|education|automotive|real\s*estate)/i)
      end
      return industry_tags.first&.downcase if industry_tags.any?
    end
    
    # Try to infer from company name
    if contact.company_name.present?
      company_lower = contact.company_name.downcase
      case company_lower
      when /tech|software|digital|dev|app|web/
        return "technology"
      when /restaurant|food|cafe|dining/
        return "restaurant"
      when /law|legal|attorney|solicitor/
        return "legal"
      when /medical|health|clinic|doctor/
        return "healthcare"
      when /construction|building|contractor/
        return "construction"
      when /marketing|advertising|seo|digital/
        return "marketing"
      when /consulting|advisory|strategy/
        return "consulting"
      when /education|school|university|training/
        return "education"
      when /automotive|car|vehicle/
        return "automotive"
      when /real estate|property|realty/
        return "real estate"
      when /finance|banking|investment|accounting/
        return "financial"
      when /retail|shop|store|commerce/
        return "retail"
      end
    end
    
    nil # Return nil if no industry detected
  end

  def send_campaign_to_lists
    # For larger campaigns, use Brevo's campaign API
    contact_lists = [@schedule.target] # Your List model
    
    begin
      result = @api_client.create_email_campaign(
        template: @template,
        contact_lists: contact_lists,
        schedule_at: @schedule.send_at
      )
      
      # Update all messages with campaign info
      @schedule.messages.update_all(
        provider_message_id: "campaign_#{result.id}",
        status: :sent,
        sent_at: Time.current
      )
      
      {
        success: true,
        message: "Campaign created successfully",
        campaign_id: result.id
      }
      
    rescue => e
      Rails.logger.error "Failed to create Brevo campaign: #{e.message}"
      {
        success: false,
        message: e.message
      }
    end
  end

  # Simple HTML tag removal for text content
  def strip_html(html)
    return '' if html.blank?
    html.gsub(/<[^>]*>/, '').strip
  end
end
