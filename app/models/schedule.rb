class Schedule < ApplicationRecord
  # Enums
  enum :state, { 
    draft: 0, 
    scheduled: 1, 
    sending: 2, 
    completed: 3, 
    paused: 4, 
    failed: 5 
  }

  # Associations
  belongs_to :user , optional: true
  belongs_to :template
  belongs_to :provider, optional: true
  has_many :messages, dependent: :destroy

  # Target relationship - using polymorphic for flexibility
  # This allows targeting List (target_type: 'List', target_id: list.id)
  # or other future target types like Segment, Contact, etc.
  belongs_to :target, polymorphic: true, foreign_key: :target_id, foreign_type: :target_type
  
  # Convenience method for when target is a List
  def contact_list
    target if target_type == 'List'
  end
  
  def contact_list=(list)
    self.target = list
    self.target_type = 'List'
  end

  # Validations
  validates :name, presence: true
  validates :state, presence: true
  validates :send_at, presence: true
  validates :target_type, presence: true
  validates :target_id, presence: true

  # Scopes
  scope :active, -> { where(state: [:scheduled, :sending]) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_state, ->(state) { where(state: state) }

  # Instance methods
  def can_be_edited?
    draft? || scheduled?
  end

  def can_be_deleted?
    draft? || completed? || failed?
  end

  def can_be_started?
    draft? || scheduled?
  end

  def can_be_paused?
    scheduled? || sending?
  end

  def target_name
    return 'Unknown' unless target
    
    case target_type
    when 'List'
      target.name
    else
      target.respond_to?(:name) ? target.name : target.to_s
    end
  end

  def target_contacts_count
    return 0 unless target
    
    case target_type
    when 'List'
      target.contacts_count || 0
    else
      0
    end
  end

  def progress_percentage
    return 0 if messages.empty?
    
    delivered_count = messages.joins(:message_events)
                             .where(message_events: { event_type: 'delivered' })
                             .distinct
                             .count
    
    (delivered_count.to_f / messages.count * 100).round(1)
  end

  def status_label
    case state
    when 'draft'
      'Draft'
    when 'scheduled'
      'Scheduled'
    when 'sending'
      'Sending'
    when 'completed'
      'Completed'
    when 'paused'
      'Paused'
    when 'failed'
      'Failed'
    else
      state.humanize
    end
  end
end
