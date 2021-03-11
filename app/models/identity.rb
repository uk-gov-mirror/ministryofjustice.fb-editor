class Identity < ApplicationRecord
  belongs_to :user

  include UserEncryption

  encrypt_fields :name, :email
end
