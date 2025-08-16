# 🎯 Brevo Template Variables & Campaign Setup Guide

## 📋 **Quick Start for Team Members**

This guide will help you set up and run email campaigns using our CRM's Brevo integration. Follow these steps in order:

### **1. Prerequisites** ✅
- Admin access to the CRM dashboard
- Your Brevo API key (contact system admin if needed)
- Email templates created in your Brevo account

---

## 🔧 **Step 1: Create a Provider**

1. **Navigate**: Admin Dashboard → **Providers** → **New Provider**
2. **Fill out the form**:
   - **Name**: "Brevo Email" (or your preferred name)
   - **Type**: Select "Email"  
   - **Active**: Check ✅
   - **Configuration**: Click "Add Configuration" and set:
     ```
     api_key: your-brevo-api-key-here
     sender_name: Your Company Name
     sender_email: noreply@yourcompany.com
     ```
3. **Save**: Your provider is now ready!

---

## 📝 **Step 2: Create a Template**

### **Option A: Use Brevo External Template** (Recommended)
1. **Create template in Brevo dashboard first**
2. **In CRM**: Admin Dashboard → **Templates** → **New Template**
3. **Fill out**:
   - **Name**: "Website Audit Outreach" (descriptive name)
   - **Subject**: "Is Your Website Invisible to Your Ideal Customers?"
   - **External Template ID**: Your Brevo template ID (e.g., "3", "4", etc.)
   - Leave HTML/Text body empty when using external templates

### **Option B: Local Template**
1. **In CRM**: Admin Dashboard → **Templates** → **New Template** 
2. **Fill out all fields including HTML and text body**
3. **Leave External Template ID empty**

---

## � **Step 3: Set Up Contact Lists**

1. **Import Contacts**: Admin Dashboard → **Contacts** → **Import CSV**
2. **Create Lists**: Admin Dashboard → **Lists** → **New List**
   - Add your imported contacts to lists
   - Use descriptive names like "Tech Prospects", "Healthcare Leads"

---

## ⚡ **Step 4: Create a Campaign Schedule**

1. **Navigate**: Admin Dashboard → **Schedules** → **New Schedule**
2. **Campaign Details**:
   - **Name**: "Q1 Website Audit Outreach"
   - **Description**: Brief description of campaign goals
   - **Template**: Select the template you created
   - **Provider**: Select your Brevo provider
   - **Target List**: Choose your contact list
3. **Advanced Settings** (optional):
   - **Merge Data**: Custom variables for this campaign
   - **Send Time**: Leave blank for immediate sending
4. **Save as Draft**: Campaign is created but not sent

---

## 🚀 **Step 5: Test & Launch Campaign**

### **Testing** 🧪
1. **Go to your campaign**: Admin Dashboard → **Schedules** → [Your Campaign]
2. **Click "Test Send"**: Sends test email to verify everything works
3. **Check logs**: Watch for any errors in the activity feed

### **Launch** 🎯
1. **Click "Send Now"**: Starts the campaign immediately
2. **Or Schedule**: Set future send time if needed
3. **Monitor Progress**: Watch the campaign dashboard for real-time stats

---

## 📈 **Step 6: Monitor Campaign Performance**

### **Campaign Overview**
- **Admin → Schedules → [Your Campaign]**: Overall campaign status
- **Messages Tab**: See individual email delivery status
- **Events Tab**: Track opens, clicks, bounces

### **Individual Message Details**  
- **Admin → Messages**: View all sent emails
- **Click any message**: See detailed delivery timeline
- **Admin → Message Events**: Track email engagement

---

## 🎨 **Template Variables Reference**

### **Updated Variable Format** (Use these in Brevo templates):
```html
{{ params.contact_person_name }}  <!-- Contact's full name -->
{{ params.company_name }}         <!-- Company name -->  
{{ params.their_industry }}       <!-- Smart industry detection -->
{{ params.first_name }}          <!-- First name only -->
{{ params.last_name }}           <!-- Last name only -->
{{ params.email }}               <!-- Email address -->
{{ params.phone }}               <!-- Phone number -->
```

### **Smart Industry Detection** 🧠
The system automatically detects industry from:

1. **Contact Tags** (Priority 1): If tagged as "technology", "healthcare", etc.
2. **Company Name** (Priority 2): "DevHub Software" → "technology"
3. **Fallbacks**: "your industry" (individuals) / "business" (companies)

**Supported Industries**: technology, legal, restaurant, healthcare, construction, marketing, consulting, education, automotive, real estate, financial, retail

---

## ✅ **Campaign Checklist**

Before launching any campaign, verify:

- [ ] **Provider Setup**: Brevo provider created and API key working
- [ ] **Template Ready**: Template created (external Brevo template preferred)
- [ ] **Contacts Imported**: Target contacts uploaded and in lists
- [ ] **List Created**: Contact list set up and populated  
- [ ] **Campaign Created**: Schedule created with proper template/provider/list
- [ ] **Test Sent**: Test email sent and received successfully
- [ ] **Variables Working**: Template variables populated correctly in test
- [ ] **Webhook URL**: Set in Brevo dashboard for delivery tracking
- [ ] **Monitoring Ready**: Know where to check campaign progress

---

## 🔍 **Template Example**

### **In your Brevo template**:
```html
<h1>Is Your Website Invisible to Your Ideal Customers?</h1>
<p>Hi {{ params.contact_person_name }},</p>

<div class="intro-text">
    While {{ params.company_name }} delivers exceptional 
    {{ params.their_industry }} services, your website might be 
    buried on page 2+ of Google...
</div>

<p>Best regards,<br>
The Team</p>
```

### **Will render as**:
```html
<h1>Is Your Website Invisible to Your Ideal Customers?</h1>
<p>Hi John Smith,</p>

<div class="intro-text">
    While Acme Tech Solutions delivers exceptional 
    technology services, your website might be 
    buried on page 2+ of Google...
</div>

<p>Best regards,<br>
The Team</p>
```

---

## 🚨 **Troubleshooting**

### **Campaign Not Sending**
- Check provider API key is correct
- Verify template has external template ID or content
- Ensure target list has contacts

### **Variables Not Working**  
- Use new format: `{{ params.variable_name }}`
- Check contact data is complete (name, company, etc.)
- Test with "Send Test Email" first

### **No Delivery Status Updates**
- Configure webhook URL in Brevo dashboard
- URL: `https://your-ngrok-url.ngrok-free.app/webhooks/brevo`
- Enable events: delivered, opened, clicked, bounced

### **Getting Support**
- Check Rails logs: `tail -f log/development.log`
- Admin → Message Events: See webhook activity
- Contact system admin with campaign ID and error details

---

## 💡 **Pro Tips for Better Campaigns**

1. **Tag Contacts**: Add industry tags for better personalization
2. **Test Everything**: Always send test emails before campaigns  
3. **Monitor Early**: Check first 10-20 sends for issues
4. **Segment Lists**: Create targeted lists for better engagement
5. **Track Performance**: Use Admin → Messages and Events for insights
6. **Optimal Timing**: Send during business hours for B2B contacts
7. **Follow Up**: Create follow-up campaigns based on engagement

---

## 📞 **Need Help?**

- **System Admin**: For API keys, webhooks, technical issues
- **Campaign Questions**: This guide covers 90% of use cases
- **Brevo Support**: For template design, deliverability issues
- **Rails Logs**: Most helpful for debugging campaign issues

**Happy Campaigning!** 🎉
- **Construction**: construction, building, contractor
- **Marketing**: marketing, advertising, seo, digital
- **Consulting**: consulting, advisory, strategy
- **Education**: education, school, university, training
- **Automotive**: automotive, car, vehicle
- **Real Estate**: real estate, property, realty
- **Financial**: finance, banking, investment, accounting
- **Retail**: retail, shop, store, commerce

### **4. Fallbacks**
- If no industry detected: "your industry" (individual) or "business" (company)

## 📝 **Your Template Example**

### In your Brevo template:
```html
<h1>Is Your Website Invisible to Your Ideal Customers?</h1>
<p>Hi <span class="editable">[Contact Person Name]</span>,</p>

<div class="intro-text">
    While <span class="editable">[Company Name]</span> delivers exceptional 
    <span class="editable">[Their Industry]</span> services, your website might be 
    buried on page 2+ of Google...
</div>
```

### Will become (for a tech company contact):
```html
<h1>Is Your Website Invisible to Your Ideal Customers?</h1>
<p>Hi John Smith,</p>

<div class="intro-text">
    While Acme Tech Solutions delivers exceptional 
    technology services, your website might be 
    buried on page 2+ of Google...
</div>
```

## � **Contact Type Handling**

### For Individual Contacts:
- Contact Person Name = "John Smith"
- Company Name = "Your Company" (fallback)
- Their Industry = detected from tags/name or "your industry"

### For Company Contacts:  
- Contact Person Name = "John Smith" or "Dear Sir/Madam"
- Company Name = "Acme Tech Solutions"
- Their Industry = detected from company name/tags or "business"

## 🚀 **Testing Your Variables**

1. **Use "Send Test Email"** - Will show:
   - Contact Person Name: Your name
   - Company Name: "Test Company Ltd"
   - Their Industry: "technology"

2. **Check Rails Logs** - Every email shows parameter mapping:
   ```
   Template params for john@example.com: {
     "Contact Person Name"=>"John Smith", 
     "Company Name"=>"Acme Tech", 
     "Their Industry"=>"technology",
     "Email"=>"john@example.com"
   }
   ```

## ✅ **What's Fixed**

- ✅ **Contact Person Name**: Maps to contact's full_name
- ✅ **Company Name**: Maps to contact's company_name with fallback
- ✅ **Their Industry**: Smart detection from company/tags with fallback
- ✅ **Professional Fallbacks**: No broken variables in emails
- ✅ **Individual vs Company**: Handles both contact types properly
- ✅ **Debug Logging**: See exactly what data is sent to Brevo

## � **Pro Tips**

1. **Add Industry Tags**: Tag your contacts with industry terms for better targeting
2. **Company Name Matters**: Include industry keywords in company names when possible
3. **Test First**: Always use "Send Test Email" before campaigns
4. **Check Logs**: Monitor Rails logs to see parameter mapping in action
5. **Custom Variables**: Add merge_data to schedules for additional custom variables

Your DevHubSol template will now personalize perfectly! 🎉
