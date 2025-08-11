# Create sample users
puts "Creating users..."

# Create Super Admin
super_admin_password = ENV['SUPER_ADMIN_PASSWORD'] || SecureRandom.hex(8)
super_admin = User.create!(
  email: 'superadmin@devcrm.com',
  password: super_admin_password,
  password_confirmation: super_admin_password,
  role: :super_admin,
  confirmed_at: Time.current
)

# Create Admin
admin_password = SecureRandom.hex(8)
admin = User.create!(
  email: 'admin@devcrm.com',
  password: admin_password,
  password_confirmation: admin_password,
  role: :admin,
  confirmed_at: Time.current
)

puts "Super Admin created: superadmin@devcrm.com / #{super_admin_password}"
puts "Admin created: admin@devcrm.com / #{admin_password}"

# Create sample contacts
puts "Creating sample contacts..."

contacts_data = [
  {
    email: 'john.doe@example.com',
    mobile_number: '+1234567890',
    full_name: 'John Doe',
    account_type: :individual,
    country: 'USA',
    city: 'New York',
    source: 'Website',
    tags: ['lead', 'potential'],
    consent_status: :consented
  },
  {
    email: 'jane.smith@techcorp.com',
    company_name: 'TechCorp Inc',
    full_name: 'Jane Smith',
    role: 'CTO',
    account_type: :company,
    country: 'USA',
    city: 'San Francisco',
    source: 'LinkedIn',
    tags: ['enterprise', 'tech'],
    consent_status: :consented
  },
  {
    email: 'bob.wilson@startup.io',
    mobile_number: '+1987654321',
    company_name: 'Startup.io',
    full_name: 'Bob Wilson',
    role: 'Founder',
    account_type: :company,
    country: 'Canada',
    city: 'Toronto',
    source: 'Conference',
    tags: ['startup', 'saas'],
    consent_status: :unknown
  },
  {
    mobile_number: '+1555123456',
    full_name: 'Alice Johnson',
    account_type: :individual,
    country: 'USA',
    city: 'Chicago',
    source: 'Referral',
    tags: ['referral'],
    consent_status: :consented
  },
  {
    email: 'marketing@bigcorp.com',
    company_name: 'BigCorp Ltd',
    role: 'Marketing Director',
    account_type: :company,
    country: 'UK',
    city: 'London',
    source: 'Trade Show',
    tags: ['enterprise', 'marketing'],
    consent_status: :consented
  }
]

contacts_data.each do |contact_data|
  Contact.create!(contact_data)
end

puts "Created #{contacts_data.length} sample contacts"

# Create a sample import batch
puts "Creating sample import batch..."

import_batch = ImportBatch.create!(
  user: admin,
  status: :completed,
  original_filename: 'sample_contacts.csv',
  filename: 'sample_contacts.csv',
  total_rows: 5,
  imported_count: 4,
  updated_count: 1,
  skipped_count: 0,
  error_count: 0,
  started_at: 1.hour.ago,
  finished_at: 30.minutes.ago,
  options: {
    update_existing: true,
    default_consent: 'consented',
    default_source: 'CSV Import'
  }
)

puts "Created sample import batch"

# Create audit logs
puts "Creating audit logs..."

AuditLog.create!(
  actor: super_admin,
  action: 'create_user',
  subject: admin,
  data: { email: admin.email, role: admin.role }
)

AuditLog.create!(
  actor: admin,
  action: 'upload_csv',
  subject: import_batch,
  data: { filename: import_batch.original_filename, total_rows: import_batch.total_rows }
)

puts "Created audit logs"

puts "\n🎉 Seeding completed successfully!"
puts "\nLogin credentials:"
puts "Super Admin: superadmin@devcrm.com / #{super_admin_password}"
puts "Admin: admin@devcrm.com / #{admin_password}"
puts "\nAccess the admin panel at: /admin"
