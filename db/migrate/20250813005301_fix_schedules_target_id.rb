class FixSchedulesTargetId < ActiveRecord::Migration[8.0]
  def up
    # Change target_id from integer to bigint for polymorphic references
    change_column :schedules, :target_id, :bigint, null: false
  end
  
  def down
    change_column :schedules, :target_id, :integer, null: false
  end
end
