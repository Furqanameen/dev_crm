class Brevo::ApiClient
  include ActiveSupport::Benchmarkable
  
  def initialize
    @email_campaigns_api = SibApiV3Sdk::EmailCampaignsApi.new
    @transactional_emails_api = SibApiV3Sdk::TransactionalEmailsApi.new
    @contacts_api = SibApiV3Sdk::ContactsApi.new
  end

  # Create and send email campaign to contact lists
  def create_email_campaign(template:, contact_lists:, sender: nil, schedule_at: nil)
    sender_info = sender || Rails.application.config.brevo[:default_sender]
    campaign_data = {
      "name" => "Campaign: #{template.name} - #{Time.current.strftime('%Y-%m-%d %H:%M')}",
      "subject" => template.subject,
      "sender" => sender_info,
      "type" => "classic",
      "htmlContent" => template.html_body,
      "textContent" => template.text_body,
      "recipients" => {
        "listIds" => contact_lists.map(&:id) # Using your List IDs
      }
    }
    
    # Add scheduling if specified
    if schedule_at.present?
      campaign_data["scheduledAt"] = schedule_at.utc.iso8601
    end

    Rails.logger.info "Creating Brevo campaign: #{campaign_data['name']}"
    
    begin
      result = @email_campaigns_api.create_email_campaign(campaign_data)
      Rails.logger.info "Campaign created successfully: ID #{result.id}"
      result
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Brevo API Error: #{e.message}"
      Rails.logger.error "Response body: #{e.response_body}"
      raise e
    end
  end

  # Send individual transactional email
  def send_transactional_email(template:, contact:, sender: nil, custom_data: {})
    sender_info = sender || Rails.application.config.brevo[:default_sender]
    
    email_data = {
      "sender" => sender_info,
      "to" => [{"email" => contact.email, "name" => contact.full_name}],
      "subject" => template.subject,
      "htmlContent" => render_template_with_data(template.html_body, contact, custom_data),
      "textContent" => render_template_with_data(template.text_body, contact, custom_data)
    }

    Rails.logger.info "Sending transactional email to: #{contact.email}"
    
    begin
      result = @transactional_emails_api.send_transac_email(email_data)
      Rails.logger.info "Email sent successfully: Message ID #{result.message_id}"
      result
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Brevo API Error: #{e.message}"
      raise e
    end
  end

    # Send email using Brevo template ID with dynamic variables
  def send_transactional_email_with_template(template_id:, contact:, params: {}, sender: nil)
    sender_info = sender || Rails.application.config.brevo[:default_sender]
    
    # Prepare comprehensive template parameters
    template_params = build_template_params(contact).merge(params) # Allow custom parameters to override defaults
    
    email_data = {
      "sender" => sender_info,
      "to" => [{"email" => contact.email, "name" => contact.display_name}],
      "templateId" => template_id.to_i,
      "params" => template_params
    }

    Rails.logger.info "Sending Brevo template email (ID: #{template_id}) to: #{contact.email}"
    Rails.logger.info "Template params: #{template_params.inspect}"
    
    begin
      result = @transactional_emails_api.send_transac_email(email_data)
      Rails.logger.info "Email sent successfully: Message ID #{result.message_id}"
      Rails.logger.info "Full Brevo response: #{result.inspect}"
      result
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Brevo API Error: #{e.message}"
      raise e
    end
  end

  # Get campaign statistics
  def get_campaign_stats(campaign_id)
    begin
      @email_campaigns_api.get_email_campaign(campaign_id)
    rescue SibApiV3Sdk::ApiError => e
      Rails.logger.error "Error fetching campaign stats: #{e.message}"
      nil
    end
  end

  # Test API connection
  def test_connection
    begin
      # Use AccountApi to get account information
      account_api = SibApiV3Sdk::AccountApi.new
      account = account_api.get_account
      {
        success: true,
        account_name: account.company_name,
        email_credits: account.plan.find { |p| p.type == 'email' }&.credits
      }
    rescue SibApiV3Sdk::ApiError => e
      {
        success: false,
        error: e.message
      }
    rescue => e
      {
        success: false,
        error: "Connection failed: #{e.message}"
      }
    end
  end

  # Build comprehensive template parameters for contact
  def build_template_params(contact)
    params = {
      "email" => contact.email,
      "phone" => contact.mobile_number,
      "mobile_number" => contact.mobile_number
    }
    
    # Handle individual vs company contacts using Brevo template syntax
    if contact.individual?
      params.merge!({
        "contact_person_name" => contact.full_name,
        "first_name" => contact.full_name&.split(' ')&.first,
        "last_name" => contact.full_name&.split(' ')&.drop(1)&.join(' '),
        "full_name" => contact.full_name,
        "company_name" => contact.company_name || "Your Company",
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
    
    # Add contact tags if available
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

  private

  # Simple template variable replacement
  def render_template_with_data(content, contact, custom_data = {})
    return content if content.blank?
    
    # Replace contact variables
    content = content.gsub(/\{\{contact\.(\w+)\}\}/) do |match|
      field = $1
      contact.send(field) if contact.respond_to?(field)
    end
    
    # Replace custom variables
    custom_data.each do |key, value|
      content = content.gsub(/\{\{#{key}\}\}/, value.to_s)
    end
    
    content
  end
end
