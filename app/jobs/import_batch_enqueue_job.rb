class ImportBatchEnqueueJob < ApplicationJob
  queue_as :default
  
  def perform(import_batch, options = {})
    import_batch.start_processing!
    
    # Store options in the import batch
    import_batch.update!(options: options)
    
    row_count = 0
    
    begin
      import_batch.csv_file.open do |file|
        CSV.foreach(file, headers: true).with_index do |row, index|
          row_count += 1
          
          # Enqueue individual row processing job
          ImportBatchRowJob.perform_later(
            import_batch.id, 
            row.to_h, 
            row_count, 
            import_batch.column_mapping,
            options
          )
          
          # Add small delay to prevent overwhelming the queue
          sleep(0.01) if row_count % 100 == 0
        end
      end
      
      # Enqueue completion check job
      ImportBatchCompletionJob.set(wait: 30.seconds).perform_later(import_batch.id)
      
    rescue StandardError => e
      import_batch.complete_processing!(false)
      import_batch.add_error(0, "Failed to process CSV: #{e.message}")
      
      raise e
    end
  end
end
