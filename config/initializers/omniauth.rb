OmniAuth.config.full_host = "http://localhost:3000"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '468716646474464', '3c8e5e8fc55cef0a9efc833641fb8776'
# If you don't need a refresh token -- if you're only using Google for account creation/auth and don't need google services -- set the access_type to 'online'.
  # Also, set the approval prompt to an empty string, since otherwise it will be set to 'force', which makes users manually approve to the Oauth every time they log in.
  # See http://googleappsdeveloper.blogspot.com/2011/10/upcoming-changes-to-oauth-20-endpoint.html
  provider :google_oauth2, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}
  provider :youtube, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w', 
    {:scope => 'https://www.googleapis.com/auth/userinfo.email', :access_type => 'online', :approval_prompt=> ''}

#  provider :google, '110446490946.apps.googleusercontent.com', 'vsTJ7b2JVCM_xb85lnaAHz5w'
end
