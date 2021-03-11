class ServiceConfiguration < ApplicationRecord
  SECRETS = %w(BASIC_AUTH_USER BASIC_AUTH_PASS ENCODED_PRIVATE_KEY).freeze
  SUBMISSION = %w(
    SERVICE_EMAIL_OUTPUT
    SERVICE_EMAIL_FROM
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
    SERVICE_EMAIL_PDF_SUBHEADING
  )
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

  def do_not_send_submission?
    name.in?(SUBMISSION) &&
      SubmissionSetting.find_by(
        service_id: service_id,
        deployment_environment: deployment_environment
      ).try(:send_email?).blank?
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
