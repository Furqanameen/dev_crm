# Brevo API Configuration
require 'sib-api-v3-sdk'

SibApiV3Sdk.configure do |config|
  # Use the API key from environment variable
  config.api_key['api-key'] = ENV['BREVO_API_KEY'] || 'xkeysib-1d22370f7cb248ad9bfe6c4a8fc7939965085854b94a2'
end

Rails.application.config.brevo = {
  api_key: ENV['BREVO_API_KEY'] || 'xkeysib-1d22370f7cb248ad9bfe6c4a8fc7939965085854b94a2',
  # default_sender: {
  #   name: "DevCRM Admin local check brevo config to change it",
  #   email: "info@devhubsol.com"  # Replace with your verified sender email
  # }
}
