class ImportBatchRowJob < ApplicationJob
  queue_as :default
  
  def perform(import_batch_id, row_data, row_number, column_mapping, options = {})
    import_batch = ImportBatch.find(import_batch_id)
    
    begin
      # Map CSV data to contact attributes
      contact_data = map_row_data(row_data, column_mapping, options)
      
      # Import the contact
      result = Contact.import_from_row(contact_data, options)
      
      case result[:action]
      when :created
        import_batch.increment_counter(:imported)
      when :updated
        import_batch.increment_counter(:updated)
      when :skipped
        import_batch.increment_counter(:skipped)
      when :error
        import_batch.increment_counter(:error)
        import_batch.add_error(row_number, result[:errors])
      end
      
    rescue StandardError => e
      import_batch.increment_counter(:error)
      import_batch.add_error(row_number, "Processing error: #{e.message}")
    end
  end
  
  private
  
  def map_row_data(row_data, column_mapping, options = {})
    mapped_data = {}
    
    column_mapping.each do |csv_column, contact_field|
      next if contact_field == 'ignore'
      
      value = row_data[csv_column]&.to_s&.strip
      next if value.blank?
      
      case contact_field
      when 'first_name'
        mapped_data[:first_name] = value
      when 'last_name'
        mapped_data[:last_name] = value
      when 'tags'
        mapped_data[:tags] = value
      else
        mapped_data[contact_field.to_sym] = value
      end
    end
    
    # Combine first_name and last_name if both present
    if mapped_data[:first_name] || mapped_data[:last_name]
      mapped_data[:full_name] = [mapped_data[:first_name], mapped_data[:last_name]].compact.join(' ')
      mapped_data.delete(:first_name)
      mapped_data.delete(:last_name)
    end
    
    # Apply default values from options
    mapped_data[:consent_status] = options[:default_consent] if options[:default_consent].present?
    mapped_data[:source] = options[:default_source] if options[:default_source].present?
    
    # Add default tags
    if options[:default_tags].present?
      existing_tags = mapped_data[:tags]&.split(/[,;]/)&.map(&:strip) || []
      all_tags = (existing_tags + options[:default_tags]).uniq
      mapped_data[:tags] = all_tags.join(',')
    end
    
    mapped_data
  end
end
