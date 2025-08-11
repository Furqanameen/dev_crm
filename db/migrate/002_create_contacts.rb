class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'citext' unless extension_enabled?('citext')
    
    create_table :contacts do |t|
      # Basic contact information
      t.citext :email, null: true
      t.string :mobile_number
      t.integer :account_type, default: 0 # individual: 0, company: 1
      t.string :full_name
      t.string :company_name
      t.string :role
      
      # Location
      t.string :country
      t.string :city
      t.string :source
      
      # Custom fields and tags
      t.jsonb :custom_fields, default: {}
      t.string :tags, array: true, default: []
      
      # Consent and status
      t.integer :consent_status, default: 0 # unknown: 0, consented: 1, unsubscribed: 2
      t.datetime :unsubscribed_at
      t.boolean :bounced, default: false
      
      t.timestamps
    end

    # Indexes
    add_index :contacts, 'LOWER(email)', unique: true, where: 'email IS NOT NULL'
    add_index :contacts, :mobile_number, where: 'mobile_number IS NOT NULL'
    add_index :contacts, :tags, using: 'gin'
    add_index :contacts, :custom_fields, using: 'gin'
    add_index :contacts, :account_type
    add_index :contacts, :consent_status
  end
end
