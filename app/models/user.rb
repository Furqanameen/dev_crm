class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  # Role-based authorization
  enum :role, { member: 0, admin: 1, super_admin: 2 }

  # Associations
  has_many :import_batches, dependent: :destroy
  has_many :audit_logs, foreign_key: :actor_id, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  # Scopes
  scope :admins, -> { where(role: [:admin, :super_admin]) }
  scope :active, -> { where.not(confirmed_at: nil) }

  # Instance methods
  def admin?
    role == 'admin' || role == 'super_admin'
  end

  def display_name
    email.split('@').first.humanize
  end
end
