class RenameRunAtToSendAtInSchedules < ActiveRecord::Migration[8.0]
  def change
    rename_column :schedules, :run_at, :send_at
  end
end
