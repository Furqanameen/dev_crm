#!/usr/bin/env ruby

puts 'Creating templates...'

email_providers = Provider.where(channel: 'email').limit(3)
sms_providers = Provider.where(channel: 'sms').limit(2)

if email_providers.any?
  # Welcome email template
  welcome_template = ::Template.create!(
    name: 'Welcome Email Series - Day 1',
    purpose: :welcome,
    default_provider: email_providers.first.name,
    subject: 'Welcome to DevCRM! Let\'s get you started 🚀',
    html_body: %{
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
    text_body: %{
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
    meta: { description: 'First email in the welcome series for new users', preheader_text: 'Your journey to better customer management begins now' }
  )

  # Newsletter template
  newsletter_template = ::Template.create!(
    name: 'Monthly Product Updates',
    purpose: :newsletter,
    default_provider: email_providers.first.name,
    subject: 'DevCRM Updates: New Features & Success Stories 📈',
    html_body: %{
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
    text_body: %{
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
    meta: { description: 'Monthly newsletter template with product updates and tips', preheader_text: 'See what\'s new this month and how customers are winning' }
  )

  # Promotional template
  promo_template = ::Template.create!(
    name: 'Special Offer - 25% Off Premium',
    purpose: :promotional,
    default_provider: email_providers.first.name,
    subject: '🎉 Limited Time: 25% OFF DevCRM Premium Features',
    html_body: %{
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
    text_body: %{
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
    meta: { description: 'Promotional template for premium feature upgrades', preheader_text: 'Upgrade today and save big on advanced CRM features' }
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
    text_body: 'Welcome to DevCRM! 🚀 Your account is ready. Get started: https://devcrm.com/start Reply STOP to opt out.',
    meta: { description: 'Welcome SMS for new user registrations', channel: 'sms' }
  )

  # SMS reminder template
  sms_reminder = ::Template.create!(
    name: 'Payment Reminder SMS',
    purpose: :reminder,
    default_provider: sms_providers.first.name,
    text_body: 'Hi {{full_name}}! Your DevCRM subscription renews in 3 days. Ensure your payment method is up to date: https://devcrm.com/billing',
    meta: { description: 'Payment reminder SMS for subscription renewals', channel: 'sms' }
  )

  puts "Created #{::Template.where('meta @> ?', {channel: 'sms'}.to_json).count} SMS templates"
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
      channel: :email,
      state: :completed,
      send_at: 2.weeks.ago,
      meta: { description: 'Welcome campaign for Q1 new signups - completed successfully with 34% open rate' }
    )
  end

  # Newsletter schedule (scheduled)
  if templates.find_by(purpose: :newsletter) && lists.count >= 2
    newsletter_schedule = Schedule.create!(
      name: 'August Newsletter',
      template: templates.find_by(purpose: :newsletter),
      target: lists.second,
      target_type: 'List',
      channel: :email,
      state: :scheduled,
      send_at: 1.week.from_now,
      meta: { description: 'Monthly newsletter featuring August product updates and customer stories' }
    )
  end

  # Promotional campaign (draft)
  if templates.find_by(purpose: :promotional) && lists.count >= 3
    promo_schedule = Schedule.create!(
      name: 'Premium Upgrade Campaign - Draft',
      template: templates.find_by(purpose: :promotional),
      target: lists.third,
      target_type: 'List',
      channel: :email,
      state: :draft,
      send_at: nil,
      meta: { description: 'Promotional campaign for premium feature upgrades - still in planning phase' }
    )
  end

  # SMS campaign (completed)
  sms_template = ::Template.where('meta @> ?', {channel: 'sms'}.to_json).first
  if sms_template && lists.any?
    sms_schedule = Schedule.create!(
      name: 'SMS Welcome Campaign',
      template: sms_template,
      target: lists.first,
      target_type: 'List',
      channel: :sms,
      state: :completed,
      send_at: 1.month.ago,
      meta: { description: 'SMS welcome campaign - achieved 78% delivery rate' }
    )
  end

  puts "Created #{Schedule.count} sample schedules"
end

puts "\n🎉 Templates and Schedules created successfully!"
puts "\nFinal Database Summary:"
puts "- Users: #{User.count}"
puts "- Contacts: #{Contact.count}"
puts "- Lists: #{List.count}"  
puts "- Providers: #{Provider.count}"
puts "- Templates: #{::Template.count}"
puts "- Schedules: #{Schedule.count}"
puts "- Import Batches: #{ImportBatch.count}"
