class CreateContactListMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_list_memberships do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :list, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :contact_list_memberships, [:contact_id, :list_id], unique: true
  end
end
