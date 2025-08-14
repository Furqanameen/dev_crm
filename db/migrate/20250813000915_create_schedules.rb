class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :template, null: false, foreign_key: true
      t.integer :channel, null: false
      t.string :target_type, null: false
      t.integer :target_id, null: false
      t.references :provider, null: true, foreign_key: true
      t.datetime :run_at
      t.integer :state, default: 0

      t.timestamps
    end
    
    add_index :schedules, [:target_type, :target_id]
    add_index :schedules, :run_at
    add_index :schedules, :state
    add_index :schedules, :channel
  end
end
