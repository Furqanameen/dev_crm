class AuditLog < ApplicationRecord
  belongs_to :actor, class_name: 'User'

  validates :action, presence: true
  validates :actor, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_subject, ->(subject) {
    where(subject_type: subject.class.name, subject_id: subject.id)
  }

  def self.log_action(actor, action, subject = nil, data = {})
    create!(
      actor: actor,
      action: action.to_s,
      subject_type: subject&.class&.name,
      subject_id: subject&.id,
      data: data
    )
  end

  def subject
    return nil unless subject_type && subject_id
    
    subject_type.constantize.find_by(id: subject_id)
  rescue NameError
    nil
  end
end
