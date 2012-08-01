# This is for private info that should not go onto the public repository. However, with Heroku,
# the actual secrets can be kept on the Heroku server. See
# https://devcenter.heroku.com/articles/config-vars

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Joslink::Application.config.secret_token = ENV['RAILS_SECRET_TOKEN']

# Action Mailer SMTP Settings
ActionMailer::Base.smtp_settings = {
  :address        => ENV['SMTP_ADDRESS'],
  :port           => ENV['SMTP_PORT'],
  :authentication => ENV['SMTP_AUTHENTICATION'],
  :user_name      => ENV['SMTP_USER_NAME'],
  :password       => ENV['SMTP_PASSWORD'],
  :domain         => ENV['SMTP_DOMAIN'],
  :openssl_verify_mode => ENV['SMTP_OPENSSL_VERIFY_MODE']
}  

OmniAuth.config.full_host = "http://localhost:3000" unless Rails.env == 'production' 

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['OMNIAUTH_FB_1'], ENV['OMNIAUTH_FB_2']
  provider :google_oauth2, ENV['OMNIAUTH_GOOGLE_1'], ENV['OMNIAUTH_GOOGLE_2'], 
    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
end
