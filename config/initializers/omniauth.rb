Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '468716646474464', '3c8e5e8fc55cef0a9efc833641fb8776'
end
