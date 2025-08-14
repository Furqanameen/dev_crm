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

# Create sample contacts from CSV data
puts "Creating sample contacts from CSV data..."

# CSV data from Sample_contacts__20_rows_.csv
csv_contacts_data = [
  { email: 'alice.smith@acme.co.uk', mobile_number: '+447900100001', full_name: 'Alice Smith', company_name: 'Acme Innovations Ltd', tags: ['lead', 'marketing'], notes: 'Met at SaaS Expo.' },
  { email: 'ben.patel@orbital.io', mobile_number: '+447900100002', full_name: 'Ben Patel', company_name: 'Orbital Systems', tags: ['apps', 'priority'], notes: 'Interested in mobile app.' },
  { email: '', mobile_number: '+447900100003', full_name: 'Carla Gomez', company_name: '', tags: ['lead', 'security'], notes: 'No email; WhatsApp OK.' },
  { email: 'daniel.cho@riskguard.com', mobile_number: '', full_name: 'Daniel Cho', company_name: 'RiskGuard Security', tags: ['security'], notes: 'Wants pentest quote.' },
  { email: 'emily.wang@northstar.co', mobile_number: '+447900100005', full_name: 'Emily Wang', company_name: 'Northstar Co.', tags: ['apps', 'web'], notes: 'Rails preferred.' },
  { email: 'francois.dupont@atelier.fr', mobile_number: '+33612345678', full_name: 'François Dupont', company_name: 'Atelier Numérique', tags: ['marketing', 'eu'], notes: 'French site revamp.' },
  { email: '', mobile_number: '+447900100007', full_name: 'George O\'Neill', company_name: '', tags: ['lead'], notes: 'Referral.' },
  { email: 'helen.yu@pixelcraft.io', mobile_number: '+447900100008', full_name: 'Helen Yu', company_name: 'Pixelcraft', tags: ['design', 'apps'], notes: 'Design + build.' },
  { email: 'ivan.petrov@volta.tech', mobile_number: '', full_name: 'Ivan Petrov', company_name: 'Volta Tech', tags: ['ai', 'apps'], notes: 'AI agent PoC.' },
  { email: 'jasmine.ali@mediapulse.co', mobile_number: '+447900100010', full_name: 'Jasmine Ali', company_name: 'MediaPulse', tags: ['marketing'], notes: 'Needs SEO.' },
  { email: 'kevin.nguyen@cloudbridge.io', mobile_number: '', full_name: 'Kevin Nguyen', company_name: 'CloudBridge', tags: ['web', 'infra'], notes: 'Cloud migration inquiry.' },
  { email: '', mobile_number: '+447900100012', full_name: 'Laura Müller', company_name: '', tags: ['eu', 'apps'], notes: 'Uses umlauts; UTF-8 test.' },
  { email: 'martins.ozolins@baltic.agency', mobile_number: '+37120000001', full_name: 'Mārtiņš Ozoliņš', company_name: 'Baltic Agency', tags: ['eu', 'marketing'], notes: 'Latvia market lead.' },
  { email: 'nora.khan@finlytics.ai', mobile_number: '+447900100014', full_name: 'Nora Khan', company_name: 'Finlytics AI', tags: ['ai', 'security'], notes: 'SOC 2 readiness chat.' },
  { email: 'omar.rashid@helixlabs.io', mobile_number: '', full_name: 'Omar Rashid', company_name: 'Helix Labs', tags: ['apps'], notes: 'API integration project.' },
  { email: 'priyanka.mehta@londonhealth.org', mobile_number: '+447900100016', full_name: 'Priyanka Mehta', company_name: 'London Health', tags: ['web', 'priority'], notes: 'NHS partner site.' },
  { email: 'qi.chen@neonbyte.cn', mobile_number: '+8613800000000', full_name: 'Qi Chen', company_name: 'NeonByte', tags: ['apps', 'global'], notes: 'China localization.' },
  { email: '', mobile_number: '+447900100018', full_name: 'Rafael Núñez', company_name: '', tags: ['lead', 'marketing'], notes: 'Spanish speaker.' },
  { email: 'sofia.rossi@aurora.it', mobile_number: '+393491234567', full_name: 'Sofia Rossi', company_name: 'Aurora', tags: ['eu', 'web'], notes: 'Italian market site.' },
  { email: 'tom.barker@greenfields.uk', mobile_number: '', full_name: 'Tom Barker', company_name: 'Greenfields Ltd', tags: ['security'], notes: 'WAF review.' }
]

# Create contacts from CSV data
created_contacts = []
csv_contacts_data.each do |contact_data|
  # Determine account type based on company_name presence
  account_type = contact_data[:company_name].present? ? :company : :individual
  
  # Set default values for required fields
  country = case contact_data[:mobile_number]
            when /^\+44/ then 'UK'
            when /^\+33/ then 'France'
            when /^\+39/ then 'Italy'
            when /^\+371/ then 'Latvia'
            when /^\+86/ then 'China'
            else 'UK'
            end
  
  # Skip contacts without email if email is required, or create with mobile only
  contact_attrs = {
    full_name: contact_data[:full_name],
    account_type: account_type,
    country: country,
    source: 'CSV Import',
    consent_status: :consented,
    tags: contact_data[:tags] || [],
    notes: contact_data[:notes]
  }
  
  # Add email if present and not empty
  contact_attrs[:email] = contact_data[:email] if contact_data[:email].present?
  
  # Add mobile if present and not empty  
  contact_attrs[:mobile_number] = contact_data[:mobile_number] if contact_data[:mobile_number].present?
  
  # Add company info if it's a company
  if account_type == :company && contact_data[:company_name].present?
    contact_attrs[:company_name] = contact_data[:company_name]
  end
  
  begin
    contact = Contact.create!(contact_attrs)
    created_contacts << contact
    puts "✓ Created: #{contact.full_name} (#{contact.email || contact.mobile_number})"
  rescue ActiveRecord::RecordInvalid => e
    puts "✗ Failed to create #{contact_data[:full_name]}: #{e.message}"
  end
end

puts "Created #{created_contacts.length} contacts from CSV data"

# Create a sample import batch using the actual CSV file
puts "Creating sample import batch..."

# Calculate stats
csv_file_path = Rails.root.join('Sample_contacts__20_rows_.csv')
failed_contacts = csv_contacts_data.length - created_contacts.length

# Try to create import batch with CSV file validation handled
begin
  import_batch = ImportBatch.new(
    user: admin,
    status: :completed,
    original_filename: 'Sample_contacts__20_rows_.csv',
    filename: 'Sample_contacts__20_rows_.csv',
    total_rows: csv_contacts_data.length,
    imported_count: created_contacts.length,
    updated_count: 0,
    skipped_count: failed_contacts,
    error_count: failed_contacts,
    started_at: 2.hours.ago,
    finished_at: 1.hour.ago,
    options: {
      update_existing: true,
      default_consent: 'consented',
      default_source: 'CSV Import',
      default_country: 'UK'
    }
  )

  # Attach the CSV file if it exists
  if File.exist?(csv_file_path)
    import_batch.csv_file.attach(
      io: File.open(csv_file_path),
      filename: 'Sample_contacts__20_rows_.csv',
      content_type: 'text/csv'
    )
    puts "✓ Attached CSV file to import batch"
  end

  # Save the import batch
  import_batch.save!
  puts "✓ Created sample import batch with #{import_batch.total_rows} total rows"
rescue ActiveRecord::RecordInvalid => e
  puts "⚠ Skipping import batch creation due to validation: #{e.message}"
  # Create a simple version without the CSV file
  import_batch = ImportBatch.create!(
    user: admin,
    status: :completed,
    original_filename: 'Sample_contacts__20_rows_.csv',
    total_rows: csv_contacts_data.length,
    imported_count: created_contacts.length,
    error_count: failed_contacts,
    started_at: 2.hours.ago,
    finished_at: 1.hour.ago
  )
  puts "✓ Created basic import batch record"
end

# Create audit logs
puts "Creating audit logs..."

AuditLog.create!(
  actor: super_admin,
  action: 'create_user',
  subject_type: 'User',
  subject_id: admin.id,
  data: { email: admin.email, role: admin.role }
)

AuditLog.create!(
  actor: admin,
  action: 'upload_csv',
  subject_type: 'ImportBatch',
  subject_id: import_batch.id,
  data: { 
    filename: import_batch.original_filename, 
    total_rows: import_batch.total_rows,
    imported_count: import_batch.imported_count,
    status: import_batch.status
  }
)

puts "Created audit logs"

# Create sample contact lists
puts "Creating sample contact lists..."

# Get some contacts to add to lists
sample_contacts = Contact.limit(10)

if sample_contacts.any?
  # Create lists for the admin user
  prospect_list = admin.lists.create!(
    name: 'High Value Prospects',
    description: 'Potential customers with high conversion probability',
    is_active: true
  )

  newsletter_list = admin.lists.create!(
    name: 'Monthly Newsletter',
    description: 'Subscribers for our monthly product updates',
    is_active: true
  )

  inactive_list = admin.lists.create!(
    name: 'Inactive Leads',
    description: 'Leads that need re-engagement',
    is_active: false
  )

  # Add contacts to lists
  sample_contacts[0..4].each do |contact|
    ContactListMembership.create!(contact: contact, list: prospect_list)
  end

  # Add contacts to lists based on their tags and attributes
  created_contacts.each_with_index do |contact, index|
    # Avoid duplicate memberships by checking if already exists
    case index % 3
    when 0
      unless ContactListMembership.exists?(contact: contact, list: prospect_list)
        ContactListMembership.create!(contact: contact, list: prospect_list)
      end
    when 1 
      unless ContactListMembership.exists?(contact: contact, list: newsletter_list)
        ContactListMembership.create!(contact: contact, list: newsletter_list)
      end
    when 2
      unless ContactListMembership.exists?(contact: contact, list: inactive_list)
        ContactListMembership.create!(contact: contact, list: inactive_list)
      end
    end
  end

  puts "Created #{admin.lists.count} contact lists with memberships"
end

# Create sample providers
puts "Creating sample providers..."

providers_data = [
  { name: 'SendGrid Email', channel: 'email', config: { api_key: 'your_sendgrid_api_key' } },
  { name: 'Mailgun Email', channel: 'email', config: { api_key: 'your_mailgun_api_key', domain: 'your-domain.com' } },
  { name: 'Twilio SMS', channel: 'sms', config: { account_sid: 'your_twilio_account_sid', auth_token: 'your_twilio_auth_token', from_number: '+1234567890' } },
  { name: 'WhatsApp Business', channel: 'whatsapp', config: { phone_number_id: 'your_phone_number_id', access_token: 'your_access_token' } },
  { name: 'Amazon SES', channel: 'email', config: { access_key_id: 'your_access_key', secret_access_key: 'your_secret_key', region: 'us-west-2' } },
  { name: 'Vonage SMS', channel: 'sms', config: { api_key: 'your_vonage_api_key', api_secret: 'your_vonage_secret' } },
  { name: 'Postmark Email', channel: 'email', config: { server_token: 'your_postmark_server_token' } },
  { name: 'MessageBird SMS', channel: 'sms', config: { access_key: 'your_messagebird_access_key' } }
]

providers_data.each do |provider_data|
  Provider.create!(provider_data)
end

puts "Created #{Provider.count} providers"

# Create sample templates
puts "Creating sample templates..."

# Get some providers for templates
email_providers = Provider.where(channel: 'email').limit(3)
sms_providers = Provider.where(channel: 'sms').limit(2)

if email_providers.any?
  # Welcome email template
  welcome_template = ::Template.create!(
    name: 'Welcome Email Series - Day 1',
    purpose: :welcome,
    default_provider: email_providers.first.name,
    subject: 'Welcome to DevCRM! Let\'s get you started 🚀',
    preheader_text: 'Your journey to better customer management begins now',
    html_content: %{
      <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #2563eb;">Welcome to DevCRM!</h1>
            <p>Hi {{full_name}}!</p>
            <p>We're thrilled to have you join our community of forward-thinking businesses who are serious about managing their customer relationships effectively.</p>
            <p>Here's what you can expect:</p>
            <ul>
              <li>Streamlined contact management</li>
              <li>Powerful email marketing campaigns</li>
              <li>Detailed analytics and reporting</li>
              <li>Multi-channel communication (Email, SMS, WhatsApp)</li>
            </ul>
            <div style="text-align: center; margin: 30px 0;">
              <a href="https://devcrm.com/getting-started" style="background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px;">Get Started Now</a>
            </div>
            <p>If you have any questions, just reply to this email. We're here to help!</p>
            <p>Best regards,<br>The DevCRM Team</p>
          </div>
        </body>
      </html>
    },
    text_content: %{
      Welcome to DevCRM!
      
      Hi {{full_name}}!
      
      We're thrilled to have you join our community of forward-thinking businesses who are serious about managing their customer relationships effectively.
      
      Here's what you can expect:
      • Streamlined contact management
      • Powerful email marketing campaigns
      • Detailed analytics and reporting
      • Multi-channel communication (Email, SMS, WhatsApp)
      
      Get started at: https://devcrm.com/getting-started
      
      If you have any questions, just reply to this email. We're here to help!
      
      Best regards,
      The DevCRM Team
    },
    description: 'First email in the welcome series for new users'
  )

  # Newsletter template
  newsletter_template = ::Template.create!(
    name: 'Monthly Product Updates',
    purpose: :newsletter,
    default_provider: email_providers.first.name,
    subject: 'DevCRM Updates: New Features & Success Stories 📈',
    preheader_text: 'See what\'s new this month and how customers are winning',
    html_content: %{
      <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #2563eb;">DevCRM Monthly Update</h1>
            <p>Hello {{full_name}}!</p>
            <p>We're excited to share what's new this month and highlight some amazing customer success stories.</p>
            
            <h2 style="color: #059669;">🚀 New Features</h2>
            <ul>
              <li>Enhanced contact segmentation</li>
              <li>Improved email template editor</li>
              <li>Advanced analytics dashboard</li>
              <li>SMS campaign scheduling</li>
            </ul>
            
            <h2 style="color: #dc2626;">📊 Customer Spotlight</h2>
            <p>TechCorp Inc increased their email open rates by 45% using our new segmentation features!</p>
            
            <div style="background-color: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0;">
              <h3>💡 Pro Tip of the Month</h3>
              <p>Use A/B testing on your subject lines to improve open rates. Start with testing 2 variations and gradually expand.</p>
            </div>
            
            <p>That's all for this month. Stay tuned for more updates!</p>
            <p>Happy CRM-ing!<br>The DevCRM Team</p>
          </div>
        </body>
      </html>
    },
    text_content: %{
      DevCRM Monthly Update
      
      Hello {{full_name}}!
      
      We're excited to share what's new this month and highlight some amazing customer success stories.
      
      🚀 NEW FEATURES:
      • Enhanced contact segmentation
      • Improved email template editor
      • Advanced analytics dashboard
      • SMS campaign scheduling
      
      📊 CUSTOMER SPOTLIGHT:
      TechCorp Inc increased their email open rates by 45% using our new segmentation features!
      
      💡 PRO TIP OF THE MONTH:
      Use A/B testing on your subject lines to improve open rates. Start with testing 2 variations and gradually expand.
      
      That's all for this month. Stay tuned for more updates!
      
      Happy CRM-ing!
      The DevCRM Team
    },
    description: 'Monthly newsletter template with product updates and tips'
  )

  # Promotional template
  promo_template = ::Template.create!(
    name: 'Special Offer - 25% Off Premium',
    purpose: :promotional,
    default_provider: email_providers.first.name,
    subject: '🎉 Limited Time: 25% OFF DevCRM Premium Features',
    preheader_text: 'Upgrade today and save big on advanced CRM features',
    html_content: %{
      <html>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px; margin-bottom: 20px;">
              <h1 style="margin: 0; font-size: 28px;">🎉 Special Offer!</h1>
              <p style="font-size: 18px; margin: 10px 0 0 0;">25% OFF Premium Features</p>
            </div>
            
            <p>Hi {{full_name}}!</p>
            <p>Ready to supercharge your customer relationship management? For a limited time, we're offering 25% off all premium features!</p>
            
            <h2 style="color: #2563eb;">Premium Features Include:</h2>
            <ul>
              <li>Advanced automation workflows</li>
              <li>Custom reporting and analytics</li>
              <li>Priority email and phone support</li>
              <li>White-label options</li>
              <li>API access and integrations</li>
            </ul>
            
            <div style="text-align: center; margin: 30px 0; padding: 20px; border: 2px dashed #2563eb; border-radius: 10px;">
              <h3 style="color: #dc2626; margin-top: 0;">Offer expires in 7 days!</h3>
              <a href="https://devcrm.com/upgrade?promo=SAVE25" style="background-color: #dc2626; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-size: 18px; font-weight: bold;">Upgrade Now & Save 25%</a>
            </div>
            
            <p>Don't miss out on this opportunity to take your CRM to the next level!</p>
            <p>Questions? Just reply to this email.</p>
            <p>Best regards,<br>The DevCRM Sales Team</p>
          </div>
        </body>
      </html>
    },
    text_content: %{
      🎉 SPECIAL OFFER: 25% OFF DevCRM Premium Features
      
      Hi {{full_name}}!
      
      Ready to supercharge your customer relationship management? For a limited time, we're offering 25% off all premium features!
      
      PREMIUM FEATURES INCLUDE:
      • Advanced automation workflows
      • Custom reporting and analytics
      • Priority email and phone support
      • White-label options
      • API access and integrations
      
      ⚠️ OFFER EXPIRES IN 7 DAYS!
      
      Upgrade now: https://devcrm.com/upgrade?promo=SAVE25
      
      Don't miss out on this opportunity to take your CRM to the next level!
      
      Questions? Just reply to this email.
      
      Best regards,
      The DevCRM Sales Team
    },
    description: 'Promotional template for premium feature upgrades'
  )

  puts "Created #{::Template.count} email templates"
end

# Create SMS templates if SMS providers exist
if sms_providers.any?
  # SMS welcome template
  sms_welcome = ::Template.create!(
    name: 'Welcome SMS',
    purpose: :welcome,
    default_provider: sms_providers.first.name,
    sms_content: 'Welcome to DevCRM! 🚀 Your account is ready. Get started: https://devcrm.com/start Reply STOP to opt out.',
    description: 'Welcome SMS for new user registrations'
  )

  # SMS reminder template
  sms_reminder = ::Template.create!(
    name: 'Payment Reminder SMS',
    purpose: :reminder,
    default_provider: sms_providers.first.name,
    sms_content: 'Hi {{full_name}}! Your DevCRM subscription renews in 3 days. Ensure your payment method is up to date: https://devcrm.com/billing',
    description: 'Payment reminder SMS for subscription renewals'
  )

  puts "Created #{::Template.where.not(sms_content: nil).count} SMS templates"
end

# Create sample schedules
puts "Creating sample schedules..."

if ::Template.any? && List.any?
  # Get some data for schedules
  templates = ::Template.limit(3)
  lists = List.limit(3)
  
  # Welcome campaign schedule (completed)
  if templates.find_by(purpose: :welcome) && lists.any?
    welcome_schedule = Schedule.create!(
      name: 'Q1 Welcome Campaign',
      template: templates.find_by(purpose: :welcome),
      target: lists.first,
      target_type: 'List',
      state: :completed,
      send_at: 2.weeks.ago,
      description: 'Welcome campaign for Q1 new signups - completed successfully with 34% open rate',
      user: admin
    )
  end

  # Newsletter schedule (scheduled)
  if templates.find_by(purpose: :newsletter) && lists.count >= 2
    newsletter_schedule = Schedule.create!(
      name: 'August Newsletter',
      template: templates.find_by(purpose: :newsletter),
      target: lists.second,
      target_type: 'List',
      state: :scheduled,
      send_at: 1.week.from_now,
      description: 'Monthly newsletter featuring August product updates and customer stories',
      user: admin
    )
  end

  # Promotional campaign (draft)
  if templates.find_by(purpose: :promotional) && lists.count >= 3
    promo_schedule = Schedule.create!(
      name: 'Premium Upgrade Campaign - Draft',
      template: templates.find_by(purpose: :promotional),
      target: lists.third,
      target_type: 'List',
      state: :draft,
      send_at: nil,
      description: 'Promotional campaign for premium feature upgrades - still in planning phase',
      user: admin
    )
  end

  # Another completed campaign
  if templates.any? && lists.any?
    past_schedule = Schedule.create!(
      name: 'Summer Special Campaign',
      template: templates.first,
      target: lists.first,
      target_type: 'List',
      state: :completed,
      send_at: 1.month.ago,
      description: 'Summer promotion campaign - achieved 28% open rate and 4.2% CTR',
      user: admin
    )
  end

  puts "Created #{Schedule.count} sample schedules"
end

puts "\n🎉 Seeding completed successfully!"
puts "\nDatabase Summary:"
puts "- Users: #{User.count}"
puts "- Contacts: #{Contact.count}"
puts "- Lists: #{List.count}"  
puts "- Providers: #{Provider.count}"
puts "- Templates: #{::Template.count}"
puts "- Schedules: #{Schedule.count}"
puts "- Import Batches: #{ImportBatch.count}"
puts "\nLogin credentials:"
puts "Super Admin: superadmin@devcrm.com / #{super_admin_password}"
puts "Admin: admin@devcrm.com / #{admin_password}"
puts "\nAccess the admin panel at: /admin"
