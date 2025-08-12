class ContactListMembership < ApplicationRecord
  belongs_to :contact
  belongs_to :list
  
  # Validations
  validates :contact_id, uniqueness: { scope: :list_id }
  
  # Callbacks
  after_create :increment_list_contacts_count
  after_destroy :decrement_list_contacts_count
  
  private
  
  def increment_list_contacts_count
    list.increment!(:contacts_count)
  end
  
  def decrement_list_contacts_count
    list.decrement!(:contacts_count)
  end
end
