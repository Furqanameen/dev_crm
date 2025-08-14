class AddMissingColumnsToSchedules < ActiveRecord::Migration[8.0]
  def change
    # Add missing columns
    add_column :schedules, :name, :string
    add_column :schedules, :timezone, :string, default: 'UTC'
    add_column :schedules, :merge_data, :jsonb, default: {}
    add_column :schedules, :meta, :jsonb, default: {}
  end
end
