class MessageEvent < ApplicationRecord
  # Enums
  enum :event_type, {
    delivered: 0,
    opened: 1,
    clicked: 2,
    bounced: 3,
    spam: 4,
    unsubscribed: 5,
    failed: 6,
    rejected: 7,
    deferred: 8
  }

  # Relationships
  belongs_to :message

  # Validations
  validates :event_type, presence: true
  validates :occurred_at, presence: true

  # Scopes
  scope :by_type, ->(type) { where(event_type: type) }
  scope :recent, -> { order(occurred_at: :desc) }

  # Methods
  def display_type
    event_type.humanize
  end

  def provider_data
    raw || {}
  end
  
  # Alias for better naming - returns the webhook event data
  def event_data
    raw || {}
  end
  
  # Provides a descriptive message for the event
  def description
    case event_type
    when 'delivered'
      "Email successfully delivered to #{event_data['email'] || 'recipient'}"
    when 'opened'
      if event_data['date']
        "Email opened at #{Time.parse(event_data['date']).strftime('%I:%M %p')}"
      else
        "Email was opened by recipient"
      end
    when 'clicked'
      if event_data['url']
        "Clicked link: #{event_data['url']}"
      else
        "Recipient clicked a link in the email"
      end
    when 'bounced'
      reason = event_data['reason'] || event_data['error'] || 'Unknown reason'
      "Email bounced: #{reason}"
    when 'spam'
      "Email marked as spam by recipient"
    when 'unsubscribed'
      "Recipient unsubscribed from emails"
    when 'failed', 'rejected'
      reason = event_data['reason'] || event_data['error'] || 'Unknown reason'
      "Email delivery failed: #{reason}"
    when 'deferred'
      "Email delivery temporarily deferred"
    else
      "Email event: #{event_type.humanize}"
    end
  rescue => e
    # Fallback in case of any parsing errors
    "#{event_type.humanize} event occurred"
  end
end
