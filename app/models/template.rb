class Template < ApplicationRecord
  # Enums
  enum :purpose, {
    newsletter: 0,
    welcome: 1,
    promotional: 2,
    transactional: 3,
    notification: 4,
    reminder: 5,
    survey: 6,
    announcement: 7
  }

  # Validations
  validates :name, presence: true
  validates :purpose, presence: true
  validates :default_provider, presence: true
  
  # At least one content method should be present
  validate :content_presence

  # Relationships
  has_many :schedules, dependent: :destroy

  # Scopes
  scope :by_purpose, ->(purpose) { where(purpose: purpose) }

  # Methods
  def provider_hosted?
    external_template_id.present?
  end

  def local_rendering?
    !provider_hosted?
  end

  def display_name
    "#{name} (#{purpose.humanize})"
  end

  def has_content?
    subject.present? || html_body.present? || text_body.present?
  end

  private

  def content_presence
    if local_rendering? && !has_content?
      errors.add(:base, "Local templates must have at least subject, HTML body, or text body")
    end
  end
end
