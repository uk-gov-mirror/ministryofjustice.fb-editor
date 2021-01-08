Fb::Jwt::Auth.configure do |config|
  config.issuer = 'fb-editor'
  config.namespace = "formbuilder-saas-#{ENV['PLATFORM_ENV']}"
  config.encoded_private_key = ENV['ENCODED_PRIVATE_KEY']
end
