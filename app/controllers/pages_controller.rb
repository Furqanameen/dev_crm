class PagesController < ApplicationController
  def home
    @services_count = 3  # You can make this dynamic later
    @clients_count = Contact.count
  end

  def services
    @seo_services = [
      {
        title: "SEO Optimization",
        description: "Improve your website's search engine ranking with our comprehensive SEO strategies.",
        features: ["Keyword Research", "On-page Optimization", "Link Building", "Analytics Reporting"]
      },
      {
        title: "Content Marketing",
        description: "Create engaging content that drives traffic and converts visitors into customers.",
        features: ["Content Strategy", "Blog Writing", "Social Media Content", "Email Campaigns"]
      },
      {
        title: "Technical SEO",
        description: "Optimize your website's technical foundation for better search performance.",
        features: ["Site Speed Optimization", "Mobile Optimization", "Schema Markup", "Crawl Optimization"]
      }
    ]

    @software_services = [
      {
        title: "Custom Software Development",
        description: "Build scalable, robust software solutions tailored to your business needs.",
        features: ["Web Applications", "Mobile Apps", "API Development", "Database Design"]
      },
      {
        title: "CRM Solutions",
        description: "Streamline your customer relationships with our powerful CRM platforms.",
        features: ["Contact Management", "Lead Tracking", "Email Integration", "Analytics Dashboard"]
      },
      {
        title: "E-commerce Development",
        description: "Create powerful online stores that drive sales and enhance customer experience.",
        features: ["Shopping Cart", "Payment Integration", "Inventory Management", "Order Tracking"]
      }
    ]
  end

  def contact
    @contact_info = {
      email: "info@devcrm.com",
      phone: "+1 (555) 123-4567",
      address: "123 Tech Street, Digital City, DC 12345"
    }
  end
end
