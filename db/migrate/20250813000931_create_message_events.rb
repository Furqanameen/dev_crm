class CreateMessageEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :message_events do |t|
      t.references :message, null: false, foreign_key: true
      t.integer :event_type, null: false
      t.datetime :occurred_at, null: false
      t.jsonb :raw, default: {}

      t.timestamps
    end
    
    add_index :message_events, :event_type
    add_index :message_events, :occurred_at
  end
end
