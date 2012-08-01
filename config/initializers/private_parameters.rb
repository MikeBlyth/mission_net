## This file is where all the private info should be kept, i.e. what should
#  not go into the public respository. Passwords, API tokens, etc.

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Joslink::Application.config.secret_token = '6fa4809a8ecb535dbbd407382fcd4615174ef8b0accaae12f17a001ee04b62bb3b6cae10232fd7c1f80d76dd367c69e914df7cb17b26a2cd03aaabc3'

# Heroku API Key
silence_warnings {ENV['HEROKU_API_KEY'] = 'd758366a60299d3bb593d2aae9ae3b7455eacd14'}

# IronWorker (background processing service) credentials
  ENV['IRON_WORKER_TOKEN'] = 'KMJAbRfCQE9RxbtZDusj5SpgOhQ'
  ENV['IRON_WORKER_PROJECT_ID'] = '5015152f0948514e68009db3'
  
# Action Mailer SMTP Settings
ActionMailer::Base.smtp_settings = {
  :address        => 'gator31.hostgator.com',
  :port           => '587',
  :authentication => :plain,
  :user_name      => 'joslink+livinginnigeria.org',
  :password       => 'wmbayouessexghettorick5W',
  :domain         => 'joslink.herokuapp.com',
  :openssl_verify_mode => 'none'
}  

#OmniAuth.config.full_host = "http://localhost:3000" unless Rails.env == 'production' 

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :facebook, '468716646474464', '3c8e5e8fc55cef0a9efc833641fb8776'
## If you don't need a refresh token -- if you're only using Google for account creation/auth and don't need google services -- set the access_type to 'online'.
#  # Also, set the approval prompt to an empty string, since otherwise it will be set to 'force', which makes users manually approve to the Oauth every time they log in.
#  # See http://googleappsdeveloper.blogspot.com/2011/10/upcoming-changes-to-oauth-20-endpoint.html
#  provider :google_oauth2, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
#    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
#  provider :youtube, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
#    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}

##  provider :google, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w'
#end
