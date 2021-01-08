class ServiceAccessToken
  ISSUER = 'fb-editor'
  attr_reader :encoded_private_key, :issuer, :platform_env

  def initialize(encoded_private_key: ENV['ENCODED_PRIVATE_KEY'], platform_env: ENV['PLATFORM_ENV'])
    @encoded_private_key = encoded_private_key
    @issuer = ISSUER
    @platform_env = platform_env
  end

  def generate
    return '' if encoded_private_key.blank?

    private_key = OpenSSL::PKey::RSA.new(Base64.strict_decode64(encoded_private_key.chomp))

    JWT.encode(
      token,
      private_key,
      'RS256'
    )
  end

  private

  def token
    payload = {
      iss: issuer,
      iat: Time.current.to_i
    }
    payload[:namespace] = namespace if namespace.present?
    payload
  end

  def namespace
    return if platform_env.blank?

    "formbuilder-saas-#{platform_env}"
  end
end
