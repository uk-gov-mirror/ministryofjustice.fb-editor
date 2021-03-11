module UserEncryption
  extend ActiveSupport::Concern

  class_methods do
    def encrypt_fields(*fields)
      fields.each do |field|
        define_method(field) do
          decrypt("raw_#{field}")
        end

        define_method("raw_#{field}") do
          read_attribute(field)
        end
      end

      self.before_save do |record|
        fields.each do |field|
          self.send("#{field}=", encrypt("raw_#{field}"))
        end
      end
    end
  end

  def decrypt(value)
    EncryptionService.new.decrypt(value)
  end

  def encrypt(value)
    EncryptionService.new.encrypt(value)
  end
end
