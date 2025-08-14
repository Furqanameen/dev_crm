class RemoveChannelFromSchedules < ActiveRecord::Migration[8.0]
  def change
    remove_column :schedules, :channel, :integer
  end
end
