class PrivatePublicKeyValidator < ActiveModel::EachValidator
  PRIVATE_KEY = 'ENCODED_PRIVATE_KEY'.freeze
  PUBLIC_KEY = 'ENCODED_PUBLIC_KEY'.freeze

  def validate_each(record, attribute, configurations)
    return if configurations.blank?

    names = configurations.map(&:name)

    unless names.include?(PRIVATE_KEY) && names.include?(PUBLIC_KEY)
      record.errors.add(
        attribute,
        'Private and public keys not found in configuration'
      )
    end
  end
end
