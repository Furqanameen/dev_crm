class Contact < ApplicationRecord
  # Enums
  enum :account_type, { individual: 0, company: 1 }
  enum :consent_status, { unknown: 0, consented: 1, unsubscribed: 2 }

  # Validations
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :mobile_number, format: { with: /\A[\d\-\+\(\)\s]+\z/ }, allow_blank: true
  validates :full_name, presence: true, if: :individual?
  validates :company_name, presence: true, if: :company?
  
  validate :email_or_mobile_required
  validate :email_uniqueness_case_insensitive

  # Callbacks
  before_save :normalize_email
  before_save :normalize_mobile_number
  before_save :normalize_tags

  # Scopes
  scope :with_email, -> { where.not(email: nil) }
  scope :with_mobile, -> { where.not(mobile_number: nil) }
  scope :consented, -> { where(consent_status: :consented) }
  scope :unsubscribed, -> { where(consent_status: :unsubscribed) }
  scope :bounced, -> { where(bounced: true) }
  scope :active, -> { where(bounced: false, consent_status: [:unknown, :consented]) }
  scope :recent, -> { order(created_at: :desc) }

  # Search
  scope :search, ->(query) {
    return none if query.blank?
    
    where(
      "LOWER(email) LIKE :query OR 
       LOWER(full_name) LIKE :query OR 
       LOWER(company_name) LIKE :query OR
       LOWER(mobile_number) LIKE :query",
      query: "%#{query.downcase}%"
    )
  }

  # Class methods
  def self.find_duplicate(email, mobile_number)
    where(
      "LOWER(email) = :email OR mobile_number = :mobile",
      email: email&.downcase,
      mobile: mobile_number
    ).first
  end

  def self.import_from_row(row_data, options = {})
    contact_attrs = normalize_import_data(row_data)
    
    if options[:update_existing]
      contact = find_duplicate(contact_attrs[:email], contact_attrs[:mobile_number])
      if contact
        contact.update_from_import(contact_attrs, options)
        return { contact: contact, action: :updated }
      end
    else
      existing = find_duplicate(contact_attrs[:email], contact_attrs[:mobile_number])
      return { contact: existing, action: :skipped } if existing
    end

    contact = new(contact_attrs)
    if contact.save
      { contact: contact, action: :created }
    else
      { contact: contact, action: :error, errors: contact.errors.full_messages }
    end
  end

  # Instance methods
  def display_name
    if company?
      company_name
    else
      full_name
    end
  end

  def primary_identifier
    email.presence || mobile_number
  end

  def update_from_import(attrs, options = {})
    return false unless attrs.is_a?(Hash)
    
    # Only update blank fields unless explicitly overriding
    attrs_to_update = attrs.select do |key, value|
      next false if value.blank?
      
      current_value = send(key) rescue nil
      current_value.blank? || options[:override_existing]
    end

    # Handle tags separately - append instead of replace
    if attrs[:tags].present?
      new_tags = Array(attrs[:tags])
      existing_tags = Array(tags)
      attrs_to_update[:tags] = (existing_tags + new_tags).uniq
    end

    update(attrs_to_update)
  end

  def unsubscribe!
    update!(
      consent_status: :unsubscribed,
      unsubscribed_at: Time.current
    )
  end

  private

  def email_or_mobile_required
    return if email.present? || mobile_number.present?
    
    errors.add(:base, "Either email or mobile number is required")
  end

  def email_uniqueness_case_insensitive
    return if email.blank?
    
    existing = Contact.where("LOWER(email) = ?", email.downcase)
    existing = existing.where.not(id: id) if persisted?
    
    errors.add(:email, "has already been taken") if existing.exists?
  end

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def normalize_mobile_number
    return if mobile_number.blank?
    
    # Basic normalization - remove spaces and common separators
    self.mobile_number = mobile_number.gsub(/[\s\-\(\)]/, '')
    
    # You can enhance this with Phonelib for proper E.164 formatting
    # self.mobile_number = Phonelib.parse(mobile_number).e164 if Phonelib.valid?(mobile_number)
  end

  def normalize_tags
    return if tags.blank?
    
    self.tags = tags.map(&:to_s).map(&:strip).map(&:downcase).reject(&:blank?).uniq
  end

  def self.normalize_import_data(row_data)
    attrs = {}
    
    # Map and clean the data
    attrs[:email] = row_data[:email]&.strip&.downcase
    attrs[:mobile_number] = row_data[:mobile_number]&.strip
    attrs[:full_name] = row_data[:full_name]&.strip
    attrs[:company_name] = row_data[:company_name]&.strip
    attrs[:role] = row_data[:role]&.strip
    attrs[:country] = row_data[:country]&.strip
    attrs[:city] = row_data[:city]&.strip
    attrs[:source] = row_data[:source]&.strip
    attrs[:notes] = row_data[:notes]&.strip
    
    # Determine account type
    if attrs[:company_name].present?
      attrs[:account_type] = :company
    else
      attrs[:account_type] = :individual
    end
    
    # Handle tags
    if row_data[:tags].present?
      attrs[:tags] = row_data[:tags].split(/[,;]/).map(&:strip).reject(&:blank?)
    end
    
    # Set defaults
    attrs[:consent_status] = row_data[:consent_status] || :unknown
    
    attrs.compact
  end
end
