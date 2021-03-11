module UserEncryption
  def encrypt_attributes
    self.name = encrypt(raw_name)
    self.email = encrypt(raw_email)
  end

  def name
    decrypt(raw_name)
  end

  def email
    decrypt(raw_email)
  end

  def raw_name
    read_attribute :name
  end

  def raw_email
    read_attribute :email
  end

  def decrypt(value)
    EncryptionService.new.decrypt(value)
  end

  def encrypt(value)
    EncryptionService.new.encrypt(value)
  end
end
