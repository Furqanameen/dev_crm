class CreateImportBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :import_batches do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0 # uploaded: 0, mapping: 1, validating: 2, importing: 3, completed: 4, failed: 5
      t.string :filename
      t.string :original_filename
      
      # Counters
      t.integer :total_rows, default: 0
      t.integer :imported_count, default: 0
      t.integer :updated_count, default: 0
      t.integer :skipped_count, default: 0
      t.integer :error_count, default: 0
      
      # Options and configurations
      t.jsonb :options, default: {}
      t.jsonb :column_mapping, default: {}
      t.jsonb :error_log, default: []
      
      # Timestamps for processing
      t.datetime :started_at
      t.datetime :finished_at
      
      t.timestamps
    end

    add_index :import_batches, :status
    add_index :import_batches, :created_at
  end
end
