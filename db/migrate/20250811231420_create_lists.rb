class CreateLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.string :name, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.integer :contacts_count, default: 0, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end
    
    add_index :lists, :name
    add_index :lists, [:user_id, :name], unique: true
  end
end
