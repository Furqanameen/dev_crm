# 🎯 Brevo Template Variables Reference

## Your Template Variables (From Your DevHubSol Template)

Based on your actual Brevo template, these variables are now mapped:

### � **Main Template Variables**
- `[Contact Person Name]` - Full name or "Dear Customer" as fallback
- `[Company Name]` - Company name or "Your Company" as fallback  
- `[Their Industry]` - Smart industry detection or "your industry" fallback

### 👤 **Additional Contact Variables Available**
- `[First Name]` - First name from full_name or "Dear" as fallback  
- `[Last Name]` - Last name from full_name or "Customer" as fallback
- `[Full Name]` - Complete full_name or "Dear Customer" as fallback
- `[Display Name]` - Intelligent name (company_name for companies, full_name for individuals)

### � **Contact Details**
- `[Email]` - Contact's email address
- `[Phone]` - Mobile number
- `[Mobile Number]` - Mobile number

### � **Business Information**  
- `[Account Type]` - "Individual" or "Company"
- `[Tags]` - Comma-separated contact tags

## 🧠 **Smart Industry Detection**

The `[Their Industry]` variable now intelligently detects industry from:

### **1. Contact Tags** (Priority 1)
If contact has tags like: `["technology", "marketing"]`
- Result: `[Their Industry]` = "technology"

### **2. Company Name Analysis** (Priority 2)
- "DevHub Software" → "technology"
- "Smith & Partners Law" → "legal" 
- "Downtown Restaurant" → "restaurant"
- "HealthCare Clinic" → "healthcare"
- "ABC Construction" → "construction"
- "Marketing Pro Agency" → "marketing"
- "Elite Consulting" → "consulting"
- "City Bank Financial" → "financial"

### **3. Supported Industry Detection**
- **Technology**: tech, software, digital, dev, app, web
- **Legal**: law, legal, attorney, solicitor
- **Restaurant**: restaurant, food, cafe, dining
- **Healthcare**: medical, health, clinic, doctor
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
