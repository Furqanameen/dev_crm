class CreateProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :providers do |t|
      t.integer :name, null: false
      t.integer :channel, null: false
      t.text :credentials
      t.jsonb :settings, default: {}
      t.boolean :active, default: true

      t.timestamps
    end
    
    add_index :providers, [:channel, :name]
    add_index :providers, :active
  end
end
