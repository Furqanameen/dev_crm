class Message < ApplicationRecord
  # Enums
  enum :channel, { 
    email: 0, 
    sms: 1, 
    whatsapp: 2 
  }
  
  enum :status, { 
    queued: 0, 
    sent: 1, 
    failed: 2, 
    suppressed: 3,
    bounced: 4,
    delivered: 5
  }

  # Relationships
  belongs_to :schedule
  belongs_to :contact
  belongs_to :provider
  has_many :message_events, dependent: :destroy

  # Validations
  validates :channel, presence: true
  validates :status, presence: true
  
  # Unique constraint on schedule and contact
  validates :contact_id, uniqueness: { scope: :schedule_id }

  # Scopes
  scope :by_status, ->(status) { where(status: status) }
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :pending, -> { where(status: [:queued]) }
  scope :processed, -> { where(status: [:sent, :failed, :suppressed, :bounced, :delivered]) }

  # Methods
  def display_status
    case status
    when 'queued'
      'Waiting to send'
    when 'sent'
      'Sent successfully'
    when 'failed'
      'Failed to send'
    when 'suppressed'
      'Suppressed by provider'
    when 'bounced'
      'Bounced back'
    when 'delivered'
      'Delivered to recipient'
    else
      status.humanize
    end
  end

  def has_events?
    message_events.any?
  end

  def latest_event
    message_events.order(:occurred_at).last
  end

  def mark_as_sent!(provider_msg_id)
    update!(
      status: :sent,
      provider_message_id: provider_msg_id,
      sent_at: Time.current
    )
  end

  def mark_as_failed!(error_message)
    update!(
      status: :failed,
      last_error: error_message,
      attempts: attempts + 1
    )
  end
end
