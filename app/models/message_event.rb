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
end
