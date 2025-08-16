# DevCRM - Customer Relationship Management System

A comprehensive CRM application built with Ruby on Rails 8.x, featuring CSV import functionality, role-based access control, and a modern Tailwind CSS interface.

## Features

### 🔐 Authentication & Authorization
- **Devise** authentication with confirmable, trackable modules
- **Role-based access control** with Pundit policies
- Three user roles: Public, Ad### **Performance Tips**

1. **Batch Size**: Large lists are processed in batches of 1000
2. **Background Jobs**: Campaigns run asynchronously via Sidekiq
3. **Rate Limiting**: Brevo has API rate limits, system handles automatically
4. **Template Caching**: Templates are cached for better performance

## ⚡ Rails 8 Compatibility

### **Turbo Method Syntax**
This application uses Rails 8 with Turbo. If you encounter routing errors like:
```
No route matches [GET] "/admin/schedules/13/send_now"
```

The issue is likely deprecated `method:` syntax in links. Use:

```ruby
# ❌ Old Rails 7 syntax
link_to "Send Now", path, method: :post, confirm: "Are you sure?"

# ✅ New Rails 8 syntax
link_to "Send Now", path, data: { turbo_method: :post, turbo_confirm: "Are you sure?" }
```

**All views in this application have been updated to use the new syntax.**

### **Common Campaign Actions**
- **Send Now**: `data: { turbo_method: :post, turbo_confirm: "..." }` 
- **Test Send**: `data: { turbo_method: :post }`
- **Pause Campaign**: `data: { turbo_method: :post, turbo_confirm: "..." }`
- **Delete**: `data: { turbo_method: :delete, turbo_confirm: "..." }`

### Role Permissionser Admin
- Secure password management and email confirmation

### 👥 Contact Management
- Advanced contact management with email and mobile number support
- Individual and Company account types
- Custom fields and tags support (JSONB)
- Consent status tracking (GDPR-friendly)
- Advanced search and filtering
- Bulk export to CSV

### 📊 CSV Import System
- **Multi-step import process**: Upload → Map → Preview → Import
- **Intelligent column mapping** with auto-detection
- **Real-time progress tracking** with background jobs
- **Validation and error handling** with detailed error logs
- **Deduplication options**: Skip existing or update existing contacts
- **Batch processing** with Sidekiq for scalability

### 🎨 Modern UI/UX
- **Tailwind CSS** for responsive, modern design
- **Hotwire (Turbo + Stimulus)** for interactive features
- **Inline SVG icons** (no raster images)
- Mobile-responsive design
- Dark/light theme support

### 📈 Admin Dashboard
- Contact statistics and analytics
- Recent import history
- User activity monitoring
- Audit logging for compliance

### 📧 **Comprehensive Campaign Management**
- **Multi-channel campaigns**: Email (Brevo), SMS, and WhatsApp ready
- **Provider management**: Secure API configuration for service providers  
- **Template system**: Local templates + External Brevo template support
- **Advanced scheduling**: Immediate send, scheduled campaigns, timezone support
- **Smart personalization**: Dynamic variables with industry detection
- **Message tracking**: Complete delivery lifecycle monitoring
- **Webhook integration**: Real-time event tracking (delivered, opened, clicked, bounced)
- **Campaign analytics**: Open rates, click rates, bounce tracking
- **Background processing**: Scalable campaign execution with Sidekiq
- **Campaign lifecycle**: Draft → Test → Sending → Completed with full audit trail

## 🎯 **Brevo Email Integration** (Production Ready)

### **For Team Members - Quick Campaign Setup**

#### **1. Admin Dashboard Access** 
- Login to CRM Admin Panel
- Role required: Admin or Super Admin

#### **2. Create Email Provider**
```
Admin → Providers → New Provider
├── Name: "Brevo Email"  
├── Type: "Email"
├── Configuration:
    ├── api_key: [Your Brevo API Key]
    ├── sender_name: "Your Company"
    └── sender_email: "noreply@company.com"
```

#### **3. Create Campaign Template**
```
Option A - External Brevo Template (Recommended):
Admin → Templates → New Template
├── Name: "Website Audit Outreach"
├── Subject: "Your email subject"  
├── External Template ID: "4" (your Brevo template ID)
└── Leave HTML/Text empty

Option B - Local Template:
├── Fill HTML Body with template content
└── Leave External Template ID empty
```

#### **4. Import & Organize Contacts**
```
Admin → Contacts → Import CSV
├── Upload your contact file
├── Map columns (email, name, company, etc.)
└── Import to system

Admin → Lists → New List  
├── Create targeted lists
└── Add contacts to lists
```

#### **5. Create & Launch Campaign**
```
Admin → Schedules → New Schedule
├── Name: "Q1 Website Audit Campaign"
├── Template: [Select your template]
├── Provider: "Brevo Email"  
├── Target: [Select your contact list]
├── Test Send → ✅ Verify everything works
└── Send Now → 🚀 Launch campaign
```

#### **6. Monitor Campaign Performance**
```
Real-time Monitoring:
├── Admin → Schedules → [Campaign] (overview)
├── Admin → Messages (individual emails)
├── Admin → Message Events (opens, clicks)
└── Brevo Dashboard (detailed analytics)
```

---

### **For Developers - Technical Setup**

---

### **For Developers - Technical Setup**

#### **1. Environment Configuration**
Add to your `.env` file:
```bash
BREVO_API_KEY=xkeysib-your-actual-api-key-here
```

Restart your Rails server after adding the API key.

#### **2. Webhook Setup** (For delivery tracking)
```bash
# Install ngrok for local development
npm install -g ngrok

# Expose local Rails server  
ngrok http 3000

# In Brevo dashboard → Transactional → Webhooks:
# Add webhook URL: https://your-ngrok-url.ngrok-free.app/webhooks/brevo
# Enable events: delivered, opened, clicked, bounced, spam
```

#### **3. Template Variables** 
Use these in your Brevo templates:
```html
{{ params.contact_person_name }}  <!-- Full name with fallback -->
{{ params.company_name }}         <!-- Company name with fallback -->  
{{ params.their_industry }}       <!-- Smart industry detection -->
{{ params.first_name }}          <!-- First name only -->
{{ params.email }}               <!-- Contact email -->
{{ params.phone }}               <!-- Phone number -->
```

#### **4. Background Jobs Setup**
```bash
# Install Redis for Sidekiq
sudo apt-get install redis-server

# Start Sidekiq for campaign processing
bundle exec sidekiq

# Check job status
Admin → Sidekiq Web UI (if configured)
```

#### **5. Testing Commands**
```ruby
# Test API connection
rails runner "puts Brevo::ApiClient.new.test_connection"

# Test template variable mapping
rails runner "
contact = Contact.first
sender = Brevo::EmailSender.new
params = sender.send(:prepare_template_params, contact)  
puts params.inspect
"

# Send test campaign
rails runner "
schedule = Schedule.first
job = SendCampaignJob.perform_now(schedule.id)
puts 'Campaign sent!'
"
```

---

## 🚀 **Getting Started for New Team Members**

### **Prerequisites**
- Admin access to the CRM dashboard
- Basic understanding of email marketing concepts
- Access to your Brevo account (or ask admin for API key)

### **Your First Campaign in 10 Minutes**

1. **Login**: Access the CRM admin panel
2. **Provider**: Create Brevo email provider with API key
3. **Contacts**: Import your contact CSV file  
4. **List**: Create a contact list and add contacts
5. **Template**: Create template (use External Brevo template ID)
6. **Campaign**: Create new schedule linking template + provider + list
7. **Test**: Send test email to verify everything works
8. **Launch**: Click "Send Now" to start campaign
9. **Monitor**: Watch real-time delivery and engagement
10. **Analyze**: Review open rates, clicks, and bounces

### **Common Workflows**

#### **Weekly Newsletter Campaign**
```
1. Create template: "Weekly Newsletter Template"
2. Import new contacts (if any)
3. Create campaign: "Weekly Newsletter - [Date]"
4. Schedule for Tuesday 9 AM
5. Monitor engagement throughout week
```

#### **Product Launch Announcement**
```  
1. Segment contacts by industry/interest
2. Create personalized template with product details
3. Create multiple campaigns for different segments
4. A/B test subject lines
5. Send at optimal times per segment
```

#### **Follow-up Email Sequence**
```
1. Create engagement-based segments (opened/didn't open)
2. Create follow-up templates
3. Manual follow-up campaigns based on first campaign results
4. Track conversion through to website/sales
```

---

## 📊 **Campaign Analytics & Reporting**

### **Built-in Analytics**
- **Campaign Overview**: Total sent, delivered, opened, clicked
- **Individual Message Tracking**: Per-contact delivery status
- **Real-time Events**: Live webhook event processing
- **Provider Performance**: Success rates by email provider
- **Contact Engagement**: Historical interaction tracking

### **External Analytics**  
- **Brevo Dashboard**: Advanced analytics and heatmaps
- **Google Analytics**: Track website clicks from campaigns
- **CRM Integration**: Contact engagement scoring

---

## 🔧 **Advanced Configuration**

### **Custom Template Variables**
Add custom merge data to campaigns:
```ruby
# In schedule merge_data field:
{
  "promotion_code": "SAVE20",
  "webinar_date": "March 15, 2025",
  "sales_rep_name": "John Smith"
}

# Use in templates:
{{ params.promotion_code }}
{{ params.webinar_date }}  
{{ params.sales_rep_name }}
```

### **Provider Failover**
Set up multiple providers for redundancy:
```ruby
# Primary: Brevo
# Backup: SendGrid  
# Configure both providers, system auto-switches on failure
```

### **Advanced Scheduling**
```ruby
# Timezone-aware scheduling
schedule.send_at = 2.days.from_now.in_time_zone("America/New_York")

# Recurring campaigns (requires custom implementation)
# Daily, weekly, monthly options
```
Add to your `.env` file:
```bash
BREVO_API_KEY=your-brevo-api-key-here
```

#### 3. Create Brevo Provider
In Rails console:
```ruby
Provider.create!(
  name: "Brevo Email",
  channel: "email",
  configuration: {
    "api_key" => ENV['BREVO_API_KEY'],
    "sender_email" => "your-verified-sender@yourdomain.com",
    "sender_name" => "Your Company Name"
  }
)
```

#### 4. Create Template in Brevo Dashboard
1. Go to **Campaigns** → **Templates** in Brevo
2. Create new template with drag-and-drop editor
3. Use dynamic variables: `[Contact Person Name]`, `[Company Name]`, etc.
4. Note the template ID from URL (e.g., template/7 → ID is "7")

#### 5. Create Template in CRM
```ruby
Template.create!(
  name: "Your Campaign Name",
  purpose: :promotional,
  default_provider: "Brevo Email",
  external_template_id: "7",          # Your Brevo template ID
  subject: "Your Email Subject",
  merge_schema: {
    "Contact Person Name" => "string",
    "Company Name" => "string",
    "First Name" => "string",
    "Email" => "string",
    "Phone" => "string"
  }
)
```

#### 6. Launch Campaign
Through Admin Interface:
1. **Admin** → **Schedules** → **New Schedule**
2. Select your Brevo template
3. Choose target contact list
4. Click **"Send Now"** or **"Test Send"**

### Dynamic Variables Available
| Brevo Variable | Maps to CRM Field | Example |
|---|---|---|
| `[Contact Person Name]` | Contact full name | "John Smith" |
| `[Company Name]` | Contact company | "Tech Corp Ltd" |
| `[First Name]` | First name only | "John" |
| `[Email]` | Contact email | "john@techcorp.com" |
| `[Phone]` | Contact phone | "+44 1234 567890" |
| `[Tags]` | Contact tags | "lead, priority" |

### Testing Your Integration
```ruby
# Test API connection
api_client = Brevo::ApiClient.new
result = api_client.test_connection
puts result

# Send test email
template = Template.find_by(external_template_id: "7")
email_sender = Brevo::EmailSender.new
result = email_sender.send_test_email(
  template: template,
  to_email: "furqanbinameen@gmail.com",
  to_name: "Test User"
)
```

### ✅ Enhanced Navigation Structure
```
Admin Dashboard:
├── 📊 Dashboard (Overview & Statistics)
├── 📧 Campaigns
│   ├── Providers (Email/SMS/WhatsApp service configuration)
│   ├── Templates (Campaign templates with merge variables)
│   └── Schedules (Campaign execution & management)
├── 📋 Logs & Events  
│   ├── Messages (Delivery tracking & status monitoring)
│   └── Webhooks (Real-time event monitoring)
├── 👥 Contacts
│   ├── Contacts (Individual contact management)
│   ├── Contact Lists (Segmentation & targeting)
│   └── Imports (CSV import system)
└── 🔧 Administration
    └── Users (User management - Super Admin only)
```

### 🚀 Campaign Features
- **Provider Security**: Encrypted API credentials with masked display
- **Advanced Filtering**: Filter by channel, status, provider, date ranges
- **Real-time Statistics**: Live delivery rates, open rates, click tracking
- **Campaign Actions**: Materialize, Send Now, Pause, Resume operations
- **Professional UI**: Modern cards, responsive tables, comprehensive dashboards
- **Audit Trail**: Complete tracking of all campaign activities

## Technical Stack

- **Ruby**: 3.3.1
- **Rails**: 8.x (with modern enum syntax)
- **Database**: PostgreSQL with advanced features (citext, arrays, JSONB)
- **Background Jobs**: Sidekiq
- **Authentication**: Devise
- **Authorization**: Pundit
- **Campaign Management**: Multi-channel messaging system (Email/SMS/WhatsApp)
- **Frontend**: Tailwind CSS, Hotwire (Turbo + Stimulus)
- **File Uploads**: Active Storage
- **Pagination**: Kaminari
- **Email**: Action Mailer with letter_opener_web (development)

## Setup Instructions

### Prerequisites

- Ruby 3.3.1 (use RVM)
- PostgreSQL 12+
- Redis (for Sidekiq)
- Node.js (for asset compilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dev_crm
   ```

2. **Set up Ruby version**
   ```bash
   rvm use 3.3.1
   ```

3. **Install dependencies**
   ```bash
   bundle install
   ```

4. **Configure database**
   ```bash
   # Update config/database.yml with your PostgreSQL credentials
   # Create databases
   rails db:create
   rails db:migrate
   ```

5. **Seed the database**
   ```bash
   rails db:seed
   ```
   
   This will create:
   - Super Admin user
   - Admin user  
   - Sample contacts
   - Example import batch

6. **Start the services**
   ```bash
   # Terminal 1: Start Rails server
   rvm use && rails server
   
   # Terminal 2: Start Sidekiq (for background jobs)
   rvm use && bundle exec sidekiq
   
   # Terminal 3: Start Tailwind CSS watcher (if needed)
   rails tailwindcss:watch
   ```

### Default Login Credentials

After running `rails db:seed`, check the console output for generated passwords:

- **Super Admin**: superadmin@devcrm.com / [generated_password]
- **Admin**: admin@devcrm.com / [generated_password]

## Usage Guide

### For Admins

#### 1. CSV Import Process

1. **Upload CSV File**
   - Navigate to Admin → Imports → New Import
   - Upload a CSV file with contact data
   - Supported formats: email, mobile_number, full_name, company_name, role, country, city, source, tags

2. **Map Columns**
   - The system auto-detects common column headers
   - Map CSV columns to contact fields
   - Set options: update existing contacts, default consent status, default tags

3. **Preview & Validate**
   - Review first 20 rows with validation status
   - Fix any errors before proceeding
   - See real-time validation results

4. **Import & Monitor**
   - Start the background import process
   - Monitor real-time progress on the import detail page
   - Download error logs if needed

#### 2. Contact Management

- **View Contacts**: Browse all contacts with search and filters
- **Add Contacts**: Create individual contacts manually
- **Edit Contacts**: Update contact information and manage tags
- **Export Contacts**: Download contact lists as CSV

#### 3. Campaign Management

**Provider Configuration:**
- Navigate to Admin → Campaigns → Providers
- Add service providers (SendGrid, Twilio, WhatsApp Business API)
- Configure API credentials securely (credentials are masked in UI)
- Set provider status (Active/Inactive/Error)

**Template Creation:**
- Go to Admin → Campaigns → Templates
- Create reusable campaign templates with merge variables
- Support for HTML/Text email templates and SMS/WhatsApp messages
- Link templates to specific providers or use default

**Campaign Scheduling:**
- Navigate to Admin → Campaigns → Schedules
- Create new campaigns targeting contact lists
- Set send times with timezone support
- Monitor campaign lifecycle: Draft → Scheduled → Sending → Completed

**Message Tracking:**
- View all messages in Admin → Logs & Events → Messages
- Track delivery status: Queued → Sent → Delivered/Failed/Bounced
- Filter by status, channel, schedule, and date ranges

**Webhook Monitoring:**
- Monitor real-time events in Admin → Logs & Events → Webhooks
- Track opens, clicks, bounces, and delivery confirmations
- View detailed event data and timestamps

#### 4. User Management (Super Admin Only)

- **Manage Admin Users**: Create, edit, and deactivate admin accounts
- **View Audit Logs**: Track all user actions for compliance
- **System Settings**: Configure application-wide settings

### CSV Import Format

Your CSV file should include these columns (headers are case-insensitive):

| Column | Required | Description |
|--------|----------|-------------|
| email | * | Contact email address |
| mobile_number | * | Phone number (either email or mobile required) |
| full_name | Conditional | Required for individual contacts |
| company_name | Conditional | Required for company contacts |
| role | Optional | Job title or role |
| country | Optional | Country name |
| city | Optional | City name |
| source | Optional | Lead source |
| tags | Optional | Comma-separated tags |

**Example CSV:**
```csv
email,mobile_number,full_name,company_name,role,country,city,source,tags
john@example.com,+1234567890,John Doe,,Developer,USA,New York,Website,"lead,potential"
jane@techcorp.com,,Jane Smith,TechCorp Inc,CTO,USA,San Francisco,LinkedIn,"enterprise,tech"
```

---

## 🔧 **Troubleshooting Guide**

### **Campaign Issues**

#### ❌ **"Campaign not sending"**
**Symptoms**: Schedule shows "sending" but no emails go out
**Solutions**:
```bash
1. Check provider configuration: Admin → Providers → [Your Provider]
2. Verify API key: rails runner "puts ENV['BREVO_API_KEY']"
3. Test API connection: rails runner "puts Brevo::ApiClient.new.test_connection"
4. Check Sidekiq: Is background job processor running?
5. View logs: tail -f log/development.log
```

#### ❌ **"Template variables not working"**
**Symptoms**: Emails show {{ params.variable_name }} instead of values
**Solutions**:
```bash
1. Use correct format: {{ params.contact_person_name }}
2. Test parameter mapping: Admin → Templates → [Template] → Test Send
3. Check contact data completeness: Admin → Contacts → [Contact]
4. Verify external template ID matches Brevo template
```

#### ❌ **"No contacts found for campaign"**
**Symptoms**: Campaign shows 0 contacts to send to
**Solutions**:
```bash
1. Check contact consent: Admin → Contacts (filter by consent status)
2. Verify list membership: Admin → Lists → [List] → Contacts tab
3. Check contact email validity: Must have non-blank email
4. Update consent status: rails runner "Contact.update_all(consent_status: 'opted_in')"
```

#### ❌ **"401 Unauthorized Error"**
**Symptoms**: API calls fail with authentication error
**Solutions**:
```bash
1. Verify API key format: xkeysib-xxxxxxxxxxxxxxxxx
2. Check .env file: No spaces around = sign
3. Test in Rails console: ENV['BREVO_API_KEY']
4. Restart server after .env changes
5. Check API key permissions in Brevo dashboard
```

### **Webhook Issues**

#### ❌ **"Not receiving delivery updates"**
**Symptoms**: Messages stay "sent", never update to "delivered"
**Solutions**:
```bash
1. Configure webhook in Brevo dashboard:
   - URL: https://your-ngrok-url.ngrok-free.app/webhooks/brevo
   - Events: delivered, opened, clicked, bounced
2. Test webhook: curl -X GET "https://your-url/webhooks/brevo/test"
3. Check webhook logs: Admin → Message Events
4. Verify ngrok is running: ngrok http 3000
```

#### ❌ **"Webhook receiving but not processing"**
**Symptoms**: Webhook logs show events but messages not updating
**Solutions**:
```bash
1. Check message ID matching in logs
2. Verify webhook payload format
3. Test webhook status: GET /webhooks/brevo/status
4. Check Rails logs for webhook errors
```

### **Template Issues**

#### ❌ **"Brevo template not found"**
**Symptoms**: Error loading external template
**Solutions**:
```bash
1. Check template ID from Brevo URL (/template/7 → ID is "7")
2. Ensure template is published (not draft) in Brevo
3. Verify template belongs to your account
4. Test template exists: Check Brevo dashboard → Templates
```

#### ❌ **"Template rendering errors"**
**Symptoms**: Emails have broken layout or missing content
**Solutions**:
```bash
1. Test in Brevo dashboard first
2. Check template variable syntax: {{ params.variable }}
3. Use local template as fallback
4. Verify template has proper HTML structure
```

### **Performance Issues**

#### ❌ **"Campaigns sending slowly"**
**Symptoms**: Large campaigns take very long to complete
**Solutions**:
```bash
1. Check Sidekiq worker count: Default is 3 threads
2. Monitor Redis memory usage
3. Review Brevo API rate limits (600 emails/hour on free plan)
4. Consider batching large campaigns
5. Check server resources (CPU, memory)
```

#### ❌ **"High bounce rates"**  
**Symptoms**: Many emails bouncing or marked as spam
**Solutions**:
```bash
1. Verify sender domain authentication in Brevo
2. Check contact list quality and source
3. Implement double opt-in for new contacts
4. Review email content for spam triggers
5. Monitor sender reputation in Brevo dashboard
```

### **Development/Setup Issues**

#### ❌ **"Rails 8 Turbo errors"**
**Symptoms**: No route matches [GET] errors on POST actions
**Solutions**:
```ruby
# Use new Rails 8 syntax:
link_to "Send Now", schedule_path, 
  data: { turbo_method: :post, turbo_confirm: "Are you sure?" }

# Not old syntax:
link_to "Send Now", schedule_path, method: :post, confirm: "Are you sure?"
```

#### ❌ **"Background jobs not processing"**
**Symptoms**: Campaigns stay in "sending" state indefinitely
**Solutions**:
```bash
1. Start Sidekiq: bundle exec sidekiq
2. Check Redis connection: redis-cli ping
3. Monitor job queue: Admin → Sidekiq Web (if configured)
4. Check failed jobs: Sidekiq::FailedSet.new.size
```

### **Quick Debugging Commands**

```ruby
# Test full campaign flow
rails runner "
schedule = Schedule.find([ID])
puts 'Schedule: ' + schedule.name
puts 'Template: ' + schedule.template.name  
puts 'Contacts: ' + schedule.target.contacts.count.to_s
puts 'Provider: ' + schedule.provider.name
"

# Check webhook setup
curl -X GET "https://your-ngrok-url/webhooks/brevo/status"

# Test template variables
rails runner "
contact = Contact.first
api_client = Brevo::ApiClient.new
params = api_client.build_template_params(contact)
puts params.inspect
"

# Monitor campaign in real-time
tail -f log/development.log | grep -E "(Brevo|Campaign|SendCampaignJob)"
```

### **Getting Help**

1. **Check Logs First**: `tail -f log/development.log`
2. **Test Components Individually**: Provider → Template → Contact List → Campaign
3. **Use Admin Panel**: Most issues visible in Admin → Messages, Events
4. **Rails Console**: Perfect for testing individual components
5. **Brevo Dashboard**: External perspective on deliverability
6. **System Admin**: For API keys, webhook configuration, server issues

**Pro Tip**: Most campaign issues are due to incomplete contact data or provider configuration. Test with a single known-good contact first! 🎯
puts api_client.test_connection

# Check provider setup
provider = Provider.find_by(name: "Brevo Email")
puts provider.configuration

# Test template
template = Template.find_by(external_template_id: "YOUR_TEMPLATE_ID")
puts "Template found: #{template.present?}"

# Send test email
email_sender = Brevo::EmailSender.new
result = email_sender.send_test_email(
  template: template,
  to_email: "your-email@example.com",
  to_name: "Your Name"
)
puts result
```

### Checking Campaign Status

Monitor campaigns through:
1. **Admin → Schedules**: Campaign status and controls
2. **Admin → Messages**: Individual email delivery status  
3. **Brevo Dashboard**: Open rates, clicks, bounces
4. **Rails Logs**: `tail -f log/development.log`

### Performance Tips

1. **Batch Size**: Large lists are processed in batches of 1000
2. **Background Jobs**: Campaigns run asynchronously via Sidekiq
3. **Rate Limiting**: Brevo has API rate limits, system handles automatically
4. **Template Caching**: Templates are cached for better performance

### Role Permissions

| Feature | Public | Admin | Super Admin |
|---------|--------|-------|-------------|
| View public pages | ✅ | ✅ | ✅ |
| Access admin panel | ❌ | ✅ | ✅ |
| Manage contacts | ❌ | ✅ | ✅ |
| Import CSV | ❌ | ✅ | ✅ |
| Campaign management | ❌ | ✅ | ✅ |
| Provider configuration | ❌ | ✅ | ✅ |
| Template creation | ❌ | ✅ | ✅ |
| Schedule campaigns | ❌ | ✅ | ✅ |
| View message logs | ❌ | ✅ | ✅ |
| Monitor webhooks | ❌ | ✅ | ✅ |
| View own imports | ❌ | ✅ | ✅ |
| View all imports | ❌ | ❌ | ✅ |
| Manage users | ❌ | ❌ | ✅ |
| System settings | ❌ | ❌ | ✅ |

## Development

### Running Tests
```bash
rvm use && rails test
```

### Code Quality
```bash
# Run RuboCop
bundle exec rubocop

# Run Brakeman security scanner
bundle exec brakeman
```

### Background Jobs
The application uses Sidekiq for background job processing. Make sure Redis is running and start Sidekiq:

```bash
rvm use && bundle exec sidekiq
```

### Email Development
In development, emails are captured by letter_opener_web. Access at:
```
http://localhost:3000/letter_opener
```

## Deployment

### Production Setup

1. **Environment Variables**
   ```bash
   RAILS_ENV=production
   DEV_CRM_DATABASE_PASSWORD=<secure_password>
   SECRET_KEY_BASE=<generated_secret>
   ```

2. **Database Setup**
   ```bash
   RAILS_ENV=production rails db:create db:migrate
   ```

3. **Asset Compilation**
   ```bash
   RAILS_ENV=production rails assets:precompile
   ```

4. **Background Jobs**
   Configure Sidekiq with systemd or Docker for production

## Security Features

- **CSRF Protection**: Enabled for all forms
- **SQL Injection Prevention**: Parameterized queries
- **Rate Limiting**: Rack::Attack for file uploads and imports
- **Audit Logging**: All admin actions are logged
- **Input Validation**: Server-side validation for all data
- **GDPR Compliance**: Consent tracking and data export/deletion

## API Extensions (Future)

The application is designed with API extensibility in mind for:
- **LLM Integration**: Contact analysis and insights
- **LangChain**: Advanced data processing pipelines
- **Machine Learning**: Predictive contact scoring
- **External Integrations**: CRM sync, email marketing platforms

## Support

For technical support or feature requests:
- Email: support@devcrm.com
- Documentation: [Internal Wiki]
- Issue Tracker: [GitHub Issues]

## License

Copyright © 2025 DevCRM. All rights reserved.
# dev_crm
