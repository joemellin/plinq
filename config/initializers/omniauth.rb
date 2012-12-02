Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, '', ''
  provider :facebook, ENV['FACEBOOK_API_KEY'] || C[:facebook_api_key], ENV['FACEBOOK_API_SECRET'] || C[:facebook_api_secret],  {:scope => "publish_stream"}
end