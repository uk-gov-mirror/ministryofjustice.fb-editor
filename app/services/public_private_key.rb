class PublicPrivateKey
  attr_reader :rsa_key

  def initialize
    @rsa_key = OpenSSL::PKey::RSA.new(2048)
  end

  def public_key
    rsa_key.public_key.to_pem
  end

  def private_key
    rsa_key.to_pem
  end
end
