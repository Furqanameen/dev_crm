class ImportBatch < ApplicationRecord
  # Associations
  belongs_to :user
  has_one_attached :csv_file

  # Enums
  enum :status, { 
    uploaded: 0, 
    mapping: 1, 
    validating: 2, 
    importing: 3, 
    completed: 4, 
    failed: 5 
  }

  # Validations
  validates :status, presence: true
  validate :csv_file_attached
  validate :ensure_original_filename

  # Callbacks
  before_validation :set_filename_from_attachment
  after_initialize :set_default_status

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :processing, -> { where(status: [:mapping, :validating, :importing]) }
  scope :completed, -> { where(status: [:completed, :failed]) }

  # Instance methods
  def progress_percentage
    return 0 if total_rows.zero?
    
    processed = imported_count + updated_count + skipped_count + error_count
    (processed.to_f / total_rows * 100).round(1)
  end

  def processing?
    %w[mapping validating importing].include?(status)
  end

  def completed?
    %w[completed failed].include?(status)
  end

  def duration
    return nil unless started_at && finished_at
    
    Time.at(finished_at - started_at).utc.strftime("%H:%M:%S")
  end

  def success_rate
    return 0 if total_rows.zero?
    
    successful = imported_count + updated_count
    (successful.to_f / total_rows * 100).round(1)
  end

  def add_error(row_number, errors)
    self.error_log ||= []
    self.error_log << {
      row: row_number,
      errors: Array(errors),
      timestamp: Time.current.iso8601
    }
    save!
  end

  def increment_counter(type)
    case type
    when :imported
      increment!(:imported_count)
    when :updated
      increment!(:updated_count)
    when :skipped
      increment!(:skipped_count)
    when :error
      increment!(:error_count)
    end
  end

  def start_processing!
    update!(
      status: :importing,
      started_at: Time.current,
      imported_count: 0,
      updated_count: 0,
      skipped_count: 0,
      error_count: 0
    )
  end

  def complete_processing!(success = true)
    update!(
      status: success ? :completed : :failed,
      finished_at: Time.current
    )
  end

  def csv_headers
    return [] unless csv_file.attached?
    
    csv_file.open do |file|
      CSV.foreach(file, headers: true).first&.headers || []
    end
  rescue StandardError
    []
  end

  def preview_rows(limit = 20)
    return [] unless csv_file.attached?
    
    rows = []
    csv_file.open do |file|
      CSV.foreach(file, headers: true).with_index do |row, index|
        break if index >= limit
        rows << row.to_h
      end
    end
    rows
  rescue StandardError
    []
  end

  def count_total_rows
    return 0 unless csv_file.attached?
    
    count = 0
    csv_file.open do |file|
      CSV.foreach(file, headers: true) { count += 1 }
    end
    update!(total_rows: count)
    count
  rescue StandardError
    0
  end

  def error_details
    return nil if error_log.blank?
    
    formatted_errors = error_log.map do |error_entry|
      row_num = error_entry['row']
      errors = Array(error_entry['errors']).join(', ')
      timestamp = error_entry['timestamp']
      
      "Row #{row_num}: #{errors}"
    end
    
    formatted_errors.join("\n")
  end

  private

  def set_default_status
    self.status ||= :uploaded
  end

  def csv_file_attached
    unless csv_file.attached?
      errors.add(:csv_file, "Please select a CSV file to upload")
      return
    end
    
    # Validate file type
    unless csv_file.content_type.in?(['text/csv', 'application/csv', 'text/plain'])
      errors.add(:csv_file, "must be a CSV file")
    end
    
    # Validate file size (max 10MB)
    if csv_file.byte_size > 10.megabytes
      errors.add(:csv_file, "must be less than 10MB")
    end
  end

  def ensure_original_filename
    set_filename_from_attachment if csv_file.attached? && original_filename.blank?
    
    if original_filename.blank?
      errors.add(:base, "Unable to determine filename from uploaded file")
    end
  end

  def csv_file_attached?
    csv_file.attached?
  end

  def set_filename_from_attachment
    return unless csv_file.attached?
    
    filename_str = csv_file.filename.to_s
    Rails.logger.debug "Setting filename from attachment: #{filename_str}" if defined?(Rails) && Rails.logger
    
    self.filename = filename_str if filename.blank?
    self.original_filename = filename_str if original_filename.blank?
  end

  def set_filename
    set_filename_from_attachment
  end
end
