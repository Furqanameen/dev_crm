class Admin::ImportsController < Admin::BaseController
  before_action :set_import_batch, only: [:show, :edit, :update, :destroy, :mapping, :preview, :perform, :status, :download_errors, :download_processed]

  def index
    @import_batches = policy_scope(ImportBatch).recent.includes(:user)
    
    # Apply pagination (simple limit/offset approach)
    @page = (params[:page] || 1).to_i
    @per_page = 15
    @total_count = @import_batches.count
    @total_pages = (@total_count.to_f / @per_page).ceil
    @import_batches = @import_batches.limit(@per_page).offset((@page - 1) * @per_page)
  end

  def show
    authorize @import_batch
    @progress = @import_batch.progress_percentage
  end

  def new
    @import_batch = current_user.import_batches.build
    authorize @import_batch
  end

  def create
    # Debug: Let's see what parameters we're getting
    Rails.logger.debug "Received params: #{params.inspect}"
    Rails.logger.debug "Import batch params: #{import_batch_params.inspect}"
    
    @import_batch = current_user.import_batches.build(import_batch_params)
    authorize @import_batch

    if @import_batch.save
      @import_batch.count_total_rows
      AuditLog.log_action(current_user, :upload_csv, @import_batch, { filename: @import_batch.original_filename })
      redirect_to mapping_admin_import_path(@import_batch), notice: 'CSV file uploaded successfully. Please map the columns.'
    else
      Rails.logger.debug "Import batch errors: #{@import_batch.errors.full_messages}"
      render :new, status: :unprocessable_content
    end
  end

  def mapping
    authorize @import_batch, :mapping?
    
    @headers = @import_batch.csv_headers
    @suggested_mapping = suggest_column_mapping(@headers)
    @available_fields = Contact.column_names + ['tags']
    
    @import_batch.update!(status: :mapping)
  end

  def preview
    authorize @import_batch, :preview?
    
    # In Rails 8, we need to handle parameters more carefully
    column_mapping = if params[:column_mapping].present?
      # Permit all keys in column_mapping dynamically
      params[:column_mapping].permit!.to_h
    else
      {}
    end
    
    @import_batch.update!(column_mapping: column_mapping)
    
    @preview_data = generate_preview_data(column_mapping)
    @validation_results = validate_preview_data(@preview_data)
    
    @import_batch.update!(status: :validating)
  end

  def perform
    authorize @import_batch, :perform?
    
    # Start the background import job
    ImportBatchEnqueueJob.perform_later(@import_batch, import_options)
    
    AuditLog.log_action(current_user, :start_import, @import_batch)
    
    redirect_to admin_import_path(@import_batch), notice: 'Import started! You can monitor the progress here.'
  end

  def status
    authorize @import_batch
    
    render json: {
      status: @import_batch.status,
      progress: @import_batch.progress_percentage,
      total_rows: @import_batch.total_rows,
      imported_count: @import_batch.imported_count,
      updated_count: @import_batch.updated_count,
      skipped_count: @import_batch.skipped_count,
      error_count: @import_batch.error_count,
      completed: @import_batch.completed?,
      duration: @import_batch.duration
    }
  end

  def download_errors
    authorize @import_batch, :download_errors?
    
    csv_data = generate_errors_csv(@import_batch)
    send_data csv_data, 
              filename: "import_errors_#{@import_batch.id}_#{Date.current.strftime('%Y%m%d')}.csv",
              type: 'text/csv'
  end

  def download_processed
    authorize @import_batch, :download_processed?
    
    # Implementation for downloading processed data
    redirect_to admin_import_path(@import_batch), alert: 'Feature not yet implemented.'
  end

  def destroy
    authorize @import_batch
    
    AuditLog.log_action(current_user, :delete_import, @import_batch, { filename: @import_batch.original_filename })
    @import_batch.destroy
    
    redirect_to admin_imports_path, notice: 'Import batch was successfully deleted.'
  end

  private

  def set_import_batch
    @import_batch = ImportBatch.find(params[:id])
  end

  def import_batch_params
    params.require(:import_batch).permit(:csv_file)
  end

  def import_options
    {
      update_existing: params[:update_existing] == '1',
      default_consent: params[:default_consent],
      default_tags: params[:default_tags]&.split(',')&.map(&:strip),
      default_source: params[:default_source]
    }
  end

  def suggest_column_mapping(headers)
    mapping = {}
    
    headers.each do |header|
      normalized = header.downcase.strip
      
      case normalized
      when /email|e-mail|e_mail/
        mapping[header] = 'email'
      when /phone|mobile|mobile_number|cell/
        mapping[header] = 'mobile_number'
      when /company|company_name|organization/
        mapping[header] = 'company_name'
      when /name|full_name|contact_name/
        mapping[header] = 'full_name'
      when /first.*name/
        mapping[header] = 'first_name'
      when /last.*name/
        mapping[header] = 'last_name'
      when /role|title|position/
        mapping[header] = 'role'
      when /country/
        mapping[header] = 'country'
      when /city/
        mapping[header] = 'city'
      when /source/
        mapping[header] = 'source'
      when /tag/
        mapping[header] = 'tags'
      when /note|notes|comment|comments|description/
        mapping[header] = 'notes'
      else
        mapping[header] = 'ignore'
      end
    end
    
    mapping
  end

  def generate_preview_data(column_mapping)
    preview_rows = @import_batch.preview_rows(20)
    
    # column_mapping is already a hash from the preview action
    mapping_hash = column_mapping
    
    preview_rows.map do |row|
      mapped_data = {}
      
      mapping_hash.each do |csv_column, contact_field|
        next if contact_field == 'ignore' || contact_field.blank?
        
        value = row[csv_column]
        
        if contact_field == 'full_name' && mapped_data['full_name'].blank?
          # Try to combine first_name and last_name if mapping separately
          first_name_column = mapping_hash.key('first_name')
          last_name_column = mapping_hash.key('last_name')
          
          first_name = first_name_column ? row[first_name_column] : nil
          last_name = last_name_column ? row[last_name_column] : nil
          
          if first_name || last_name
            mapped_data['full_name'] = [first_name, last_name].compact.join(' ')
          else
            mapped_data['full_name'] = value
          end
        else
          mapped_data[contact_field] = value
        end
      end
      
      mapped_data
    end
  end

  def validate_preview_data(preview_data)
    results = []
    
    preview_data.each_with_index do |row_data, index|
      row_number = index + 1
      errors = []
      warnings = []
      
      # Email validation
      if row_data['email'].present?
        unless row_data['email'].match?(URI::MailTo::EMAIL_REGEXP)
          errors << "Invalid email format"
        end
        
        # Check for duplicates
        if Contact.where("LOWER(email) = ?", row_data['email'].downcase).exists?
          warnings << "Email already exists"
        end
      end
      
      # Mobile number validation
      if row_data['mobile_number'].present?
        unless row_data['mobile_number'].match?(/\A[\d\-\+\(\)\s]+\z/)
          warnings << "Mobile number format may be invalid"
        end
      end
      
      # Required field validation
      if row_data['email'].blank? && row_data['mobile_number'].blank?
        errors << "Either email or mobile number is required"
      end
      
      # Account type specific validation
      has_company = row_data['company_name'].present?
      has_full_name = row_data['full_name'].present?
      
      if has_company && !has_full_name
        # Company contact is valid
      elsif !has_company && has_full_name
        # Individual contact is valid
      elsif !has_company && !has_full_name
        errors << "Either company name or full name is required"
      end
      
      status = if errors.any?
        'error'
      elsif warnings.any?
        'warning'
      else
        'ok'
      end
      
      results << {
        row_number: row_number,
        status: status,
        errors: errors,
        warnings: warnings,
        data: row_data
      }
    end
    
    results
  end

  def generate_errors_csv(import_batch)
    CSV.generate(headers: true) do |csv|
      csv << ['Row Number', 'Errors', 'Timestamp']
      
      import_batch.error_log.each do |error_entry|
        csv << [
          error_entry['row'],
          error_entry['errors'].join('; '),
          error_entry['timestamp']
        ]
      end
    end
  end
end
