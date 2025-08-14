class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :contact, null: false, foreign_key: true
      t.integer :channel, null: false
      t.references :provider, null: false, foreign_key: true
      t.string :provider_message_id
      t.integer :status, default: 0
      t.integer :attempts, default: 0
      t.text :last_error
      t.datetime :queued_at
      t.datetime :sent_at

      t.timestamps
    end
    
    add_index :messages, [:schedule_id, :contact_id], unique: true
    add_index :messages, [:provider_id, :provider_message_id]
    add_index :messages, :status
    add_index :messages, :queued_at
  end
end
