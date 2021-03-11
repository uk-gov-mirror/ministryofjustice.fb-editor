class User < ApplicationRecord
  include UserEncryption
  encrypt_fields :name, :email

  has_many :identities, dependent: :destroy

  def has_identity?(identity)
    identities.any? do |id|
      id.uid == identity.uid &&
      id.provider == identity.provider
    end
  end
end
