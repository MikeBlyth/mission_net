OmniAuth.config.full_host = "http://localhost:3000" unless Rails.env == 'production' 

#Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :facebook, '468716646474464', '3c8e5e8fc55cef0a9efc833641fb8776'
## If you don't need a refresh token -- if you're only using Google for account creation/auth and don't need google services -- set the access_type to 'online'.
#  # Also, set the approval prompt to an empty string, since otherwise it will be set to 'force', which makes users manually approve to the Oauth every time they log in.
#  # See http://googleappsdeveloper.blogspot.com/2011/10/upcoming-changes-to-oauth-20-endpoint.html
#  provider :google_oauth2, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
#    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
#  provider :youtube, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
#    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
#end

google_id = ENV['OMNIAUTH_GOOGLE_1']
google_key = ENV['OMNIAUTH_GOOGLE_2']
puts "**** google_id=#{google_id}"
if google_key == 'vsTJ7b2JVCM_xb85lnaAHz5w'
  puts "**** Match ****"
else
  puts "**** " + google_key

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['OMNIAUTH_FB_1'], ENV['OMNIAUTH_FB_2']
  provider :google_oauth2, google_id, google_key, 
    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
end
