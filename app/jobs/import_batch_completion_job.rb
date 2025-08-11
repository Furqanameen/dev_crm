class ImportBatchCompletionJob < ApplicationJob
  queue_as :default
  
  def perform(import_batch_id)
    import_batch = ImportBatch.find(import_batch_id)
    
    # Check if all rows have been processed
    total_processed = import_batch.imported_count + 
                     import_batch.updated_count + 
                     import_batch.skipped_count + 
                     import_batch.error_count
    
    if total_processed >= import_batch.total_rows
      # All rows processed, mark as completed
      import_batch.complete_processing!(true)
    else
      # Not all rows processed yet, check again later
      ImportBatchCompletionJob.set(wait: 30.seconds).perform_later(import_batch_id)
    end
  end
end
