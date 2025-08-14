# DevCRM - Customer Relationship Management System

A comprehensive CRM application built with Ruby on Rails 8.x, featuring CSV import functionality, role-based access control, and a modern Tailwind CSS interface.

## Features

### 🔐 Authentication & Authorization
- **Devise** authentication with confirmable, trackable modules
- **Role-based access control** with Pundit policies
- Three user roles: Public, Admin, Super Admin
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

### 📧 Campaign Management System
- **Multi-channel campaigns**: Email, SMS, and WhatsApp support
- **Provider management**: Secure configuration for service providers (SendGrid, Twilio, etc.)
- **Template system**: Reusable campaign templates with merge variables
- **Campaign scheduling**: Advanced scheduling with timezone support
- **Message tracking**: Complete delivery status monitoring
- **Webhook integration**: Real-time event tracking (delivered, opened, clicked, bounced)
- **Campaign lifecycle**: Draft → Scheduled → Sending → Completed/Failed

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
