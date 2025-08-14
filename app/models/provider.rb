class Provider < ApplicationRecord
  # Enums
  enum :channel, { 
    email: 0, 
    sms: 1, 
    whatsapp: 2 
  }
  
  enum :status, {
    active: 0,
    inactive: 1,
    error: 2
  }

  # Validations
  validates :name, presence: true
  validates :channel, presence: true
  validates :configuration, presence: true
  
  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_channel, ->(channel) { where(channel: channel) }

  # Relationships
  has_many :schedules, dependent: :destroy
  has_many :messages, through: :schedules

  # Methods
  def display_name
    "#{name} (#{channel.humanize})"
  end

  def active?
    status == 'active'
  end
  
  def schedules_count
    schedules.count
  end
end
