class Identity < ApplicationRecord
  belongs_to :user

  include UserEncryption

  before_save :encrypt_attributes
end
