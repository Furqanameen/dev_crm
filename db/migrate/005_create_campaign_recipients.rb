class CreateCampaignRecipients < ActiveRecord::Migration[8.0]
  def change
    create_table :campaign_recipients do |t|
      t.references :contact, null: false, foreign_key: true
      t.bigint :campaign_id # For future use
      t.integer :state, default: 0
      t.string :message_id
      
      t.timestamps
    end

    add_index :campaign_recipients, [:contact_id, :campaign_id], unique: true
    add_index :campaign_recipients, :state
  end
end
