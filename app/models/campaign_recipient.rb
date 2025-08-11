class CampaignRecipient < ApplicationRecord
  belongs_to :contact

  enum :state, { pending: 0, sent: 1, delivered: 2, opened: 3, clicked: 4, bounced: 5, unsubscribed: 6 }

  validates :contact, presence: true
end
