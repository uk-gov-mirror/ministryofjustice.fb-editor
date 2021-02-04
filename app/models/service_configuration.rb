class ServiceConfiguration < ApplicationRecord
  SECRETS = %w(BASIC_AUTH_USER BASIC_AUTH_PASS ENCODED_PRIVATE_KEY).freeze
  BASIC_AUTH_USER = 'BASIC_AUTH_USER'.freeze
  BASIC_AUTH_PASS = 'BASIC_AUTH_PASS'.freeze

  before_save :encrypt_value

  validates :name, :value, :service_id, :deployment_environment, presence: true
  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :name, uniqueness: {
    scope: [:service_id, :deployment_environment],
    case_sensitive: false
  }

  def secrets?
    name.in?(SECRETS)
  end

  def decrypt_value
    @decrypt_value ||=
      EncryptionService.new.decrypt(value) if value.present?
  end

  def encode64
    Base64.strict_encode64(decrypt_value) if decrypt_value.present?
  end

  private

  def encrypt_value
    self.value = EncryptionService.new.encrypt(value)
  end
end
