class List < ApplicationRecord
  belongs_to :user
  has_many :contact_list_memberships, dependent: :destroy
  has_many :contacts, through: :contact_list_memberships
  
  # Validations
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :contacts_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_active, inclusion: { in: [true, false] }
  
  # Scopes
  scope :active, -> { where(is_active: true) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Callbacks
  after_create :update_contacts_count
  
  def display_name
    "#{name} (#{contacts_count})"
  end
  
  private
  
  def update_contacts_count
    update_column(:contacts_count, contact_list_memberships.count)
  end
end
