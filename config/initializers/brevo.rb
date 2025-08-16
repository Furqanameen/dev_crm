# Brevo API Configuration
require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  # Use the API key from environment variable
  config.api_key['api-key'] = ENV['BREVO_API_KEY']
end

Rails.application.config.brevo = {
  api_key: ENV['BREVO_API_KEY'],
  # default_sender: {
  #   name: "DevCRM Admin local check brevo config to change it",
  #   email: "info@devhubsol.com"  # Replace with your verified sender email
  # }
}
