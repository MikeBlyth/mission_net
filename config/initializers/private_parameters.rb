# This is for private info that should not go onto the public repository. However, with Heroku,
# the actual secrets can be kept on the Heroku server. See
# https://devcenter.heroku.com/articles/config-vars

# Be sure to restart your server when you modify this file.

needed_parameters = %w{ SMTP_ADDRESS SMTP_PORT SMTP_AUTHENTICATION SMTP_USER_NAME SMTP_PASSWORD SMTP_DOMAIN
      SMTP_OPENSSL_VERIFY_MODE OMNIAUTH_FB_1 OMNIAUTH_FB_2 OMNIAUTH_GOOGLE_1 OMNIAUTH_GOOGLE_2 RAILS_SECRET_TOKEN}
if Rails.env != 'production'
  File.open("#{Rails.root}/.env") do |file|
    file.each_line do |line|
      if line =~ /(.*?)=(.*)/
        ENV[$1] = $2 if needed_parameters.include? $1
      end
    end
  end
end

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
  provider :google_oauth2,ENV['OMNIAUTH_GOOGLE_1'], ENV['OMNIAUTH_GOOGLE_2'], 
    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
end
