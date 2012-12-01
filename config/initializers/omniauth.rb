Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '', ''
  provider :facebook, C[:facebook_api_key], C[:facebook_api_secret]
end