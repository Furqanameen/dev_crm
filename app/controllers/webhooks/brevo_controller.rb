class Webhooks::BrevoController < ApplicationController
  # Skip CSRF protection for webhooks
  skip_before_action :verify_authenticity_token
  
  # Skip authentication for webhooks
  skip_before_action :authenticate_user!
  
  # Test endpoint to verify webhook is reachable
  def test
    Rails.logger.info "Brevo webhook test endpoint accessed"
    render json: { 
      status: 'ok', 
      message: 'Brevo webhook endpoint is working',
      timestamp: Time.current.iso8601 
    }, status: :ok
  end
  
  # Status endpoint to check recent webhook activity
  def status
    recent_events = MessageEvent.order(:created_at).limit(10)
    recent_messages = Message.where(status: [:delivered, :bounced, :suppressed]).limit(5)
    
    render json: {
      status: 'ok',
      message: 'Webhook status',
      recent_events_count: MessageEvent.where('created_at > ?', 1.hour.ago).count,
      recent_events: recent_events.map do |event|
        {
          id: event.id,
          message_id: event.message_id,
          event_type: event.event_type,
          occurred_at: event.occurred_at,
          created_at: event.created_at
        }
      end,
      recent_deliveries: recent_messages.map do |msg|
        {
          id: msg.id,
          contact_email: msg.contact.email,
          status: msg.status,
          sent_at: msg.sent_at,
          updated_at: msg.updated_at
        }
      end
    }
  end
  
  def receive
    # Log the webhook for debugging
    raw_body = request.body.read
    Rails.logger.info "=== Brevo Webhook Received ==="
    Rails.logger.info "Headers: #{request.headers.to_h.select { |k, v| k.start_with?('HTTP_') }}"
    Rails.logger.info "Body: #{raw_body}"
    Rails.logger.info "Content-Type: #{request.content_type}"
    Rails.logger.info "================================="
    
    # Reset the request body for processing
    request.body.rewind
    
    # Handle both JSON and form-encoded webhooks
    payload = if request.content_type&.include?('application/json')
      JSON.parse(raw_body)
    else
      # Brevo sometimes sends form-encoded data
      params_hash = request.request_parameters
      Rails.logger.info "Form params: #{params_hash}"
      params_hash
    end
    
    Rails.logger.info "Parsed payload: #{payload}"
    
    # Process different event types
    event_type = payload['event'] || payload[:event]
    case event_type
    when 'delivered'
      handle_delivered_event(payload)
    when 'opened', 'open'
      handle_opened_event(payload)
    when 'clicked', 'click'
      handle_clicked_event(payload)
    when 'bounced', 'bounce'
      handle_bounced_event(payload)
    when 'spam'
      handle_spam_event(payload)
    when 'unsubscribed', 'unsubscribe'
      handle_unsubscribed_event(payload)
    when 'blocked', 'block'
      handle_blocked_event(payload)
    else
      Rails.logger.warn "Unknown Brevo webhook event: #{event_type}"
    end
    
    # Return success response
    render json: { status: 'ok' }, status: :ok
    
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON in Brevo webhook: #{e.message}"
    render json: { error: 'Invalid JSON' }, status: :bad_request
  rescue => e
    Rails.logger.error "Error processing Brevo webhook: #{e.message}"
    render json: { error: 'Internal server error' }, status: :internal_server_error
  end
  
  private
  
  def handle_delivered_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    Rails.logger.info "Processing delivered event for message_id: #{message_id}"
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      message.update!(status: :delivered)
      create_message_event(message, 'delivered', payload)
      Rails.logger.info "Message #{message.id} marked as delivered"
    else
      Rails.logger.warn "Message with provider_message_id #{message_id} not found"
      Rails.logger.warn "Available message IDs: #{Message.pluck(:provider_message_id, :id).inspect}"
    end
  end
  
  def handle_opened_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    Rails.logger.info "Processing opened event for message_id: #{message_id}"
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      create_message_event(message, 'opened', payload)
      Rails.logger.info "Open event created for message #{message.id}"
    else
      Rails.logger.warn "Message with provider_message_id #{message_id} not found for open event"
    end
  end
  
  def handle_clicked_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    Rails.logger.info "Processing clicked event for message_id: #{message_id}"
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      create_message_event(message, 'clicked', payload)
      Rails.logger.info "Click event created for message #{message.id}"
    else
      Rails.logger.warn "Message with provider_message_id #{message_id} not found for click event"
    end
  end
  
  def handle_bounced_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      message.update!(status: :bounced)
      create_message_event(message, 'bounced', payload)
      Rails.logger.info "Message #{message.id} marked as bounced"
    end
  end
  
  def handle_spam_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      message.update!(status: :suppressed)
      create_message_event(message, 'spam', payload)
      Rails.logger.info "Message #{message.id} marked as spam"
    end
  end
  
  def handle_unsubscribed_event(payload)
    email = payload['email'] || payload[:email]
    return unless email
    
    # Mark contact as unsubscribed
    contact = Contact.find_by(email: email)
    if contact
      contact.update!(consent_status: :unsubscribed)
      Rails.logger.info "Contact #{contact.id} marked as unsubscribed"
    end
    
    # Also create event if we can find the message
    message_id = extract_message_id(payload)
    if message_id
      message = Message.find_by(provider_message_id: message_id)
      create_message_event(message, 'unsubscribed', payload) if message
    end
  end
  
  def handle_blocked_event(payload)
    message_id = extract_message_id(payload)
    return unless message_id
    
    message = Message.find_by(provider_message_id: message_id)
    if message
      message.update!(status: :failed, last_error: 'Blocked by provider')
      create_message_event(message, 'rejected', payload)
      Rails.logger.info "Message #{message.id} marked as blocked"
    end
  end
  
  def extract_message_id(payload)
    # Try different possible keys that Brevo might use
    message_id = payload.dig('message-id') || 
                 payload.dig('messageId') ||
                 payload.dig('id') ||
                 payload.dig(:message_id) ||
                 payload.dig('message_uuid') ||
                 payload['message-id'] ||
                 payload['messageId'] ||
                 payload['id'] ||
                 payload[:message_id]
    
    Rails.logger.info "Extracted message_id: #{message_id} from payload keys: #{payload.keys}"
    message_id
  end
  
  def create_message_event(message, event_type, payload)
    return unless message
    
    # Try to parse timestamp from different possible fields
    timestamp = payload['date'] || payload['timestamp'] || payload[:date] || payload[:timestamp] || payload['ts']
    
    occurred_at = begin
      if timestamp
        # Handle Unix timestamp or ISO string
        timestamp.is_a?(String) ? Time.parse(timestamp) : Time.at(timestamp.to_i)
      else
        Time.current
      end
    rescue
      Rails.logger.warn "Could not parse timestamp: #{timestamp}"
      Time.current
    end
    
    event = MessageEvent.create!(
      message: message,
      event_type: event_type,
      occurred_at: occurred_at,
      raw: payload
    )
    
    Rails.logger.info "Created message event #{event.id} for message #{message.id}: #{event_type}"
    event
  rescue => e
    Rails.logger.error "Failed to create message event: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end
