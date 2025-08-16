# Test script to send email and see Brevo response format
schedule = Schedule.joins(:template).where(templates: { external_template_id: ['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(&:to_s) + ['jhknjk'] }).first

if schedule
  puts "Testing campaign send with Schedule ID: #{schedule.id}"
  puts "Template ID: #{schedule.template.external_template_id}"
  puts "Target contacts: #{schedule.target.contacts.count}"
  
  # Send to just one contact for testing  
  contact = schedule.target.contacts.first
  if contact
    puts "Sending test email to: #{contact.email}"
    
    # Create or find message
    message = schedule.messages.find_or_create_by(contact: contact) do |m|
      m.channel = :email
      m.provider = schedule.provider
      m.status = :queued
      m.queued_at = Time.current
    end
    
    puts "Message ID: #{message.id}"
    
    # Send via Brevo API
    api_client = Brevo::ApiClient.new
    result = api_client.send_transactional_email_with_template(
      template_id: schedule.template.external_template_id,
      contact: contact,
      params: {}
    )
    
    # Update message with result
    message.update!(
      provider_message_id: result.message_id,
      status: :sent,
      sent_at: Time.current
    )
    
    puts "Message sent with provider_message_id: #{message.provider_message_id}"
    puts "Check Rails logs for full response details"
  else
    puts 'No contacts found in target list'
  end
else
  puts 'No schedule found with external template ID'
  puts 'Available templates:'
  Template.where.not(external_template_id: nil).each do |t|
    puts "  ID: #{t.id}, External ID: #{t.external_template_id}, Name: #{t.name}"
  end
end
