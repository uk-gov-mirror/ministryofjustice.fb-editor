class EmailSettingsUpdater
  attr_reader :email_settings, :service

  CONFIG_WITHOUT_DEFAULTS = %w(
    SERVICE_EMAIL_OUTPUT
    SERVICE_EMAIL_PDF_SUBHEADING
  ).freeze

  CONFIG_WITH_DEFAULTS = %w(
    SERVICE_EMAIL_SUBJECT
    SERVICE_EMAIL_BODY
    SERVICE_EMAIL_PDF_HEADING
    SERVICE_EMAIL_FROM
  ).freeze

  def initialize(email_settings:, service:)
    @email_settings = email_settings
    @service = service
  end

  def create_or_update!
    ActiveRecord::Base.transaction do
      save_submission_setting
      save_config_without_defaults
      save_config_with_defaults
    end
  end

  def save_submission_setting
    submission_setting = SubmissionSetting.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: email_settings.deployment_environment
    )
    submission_setting.send_email = email_settings.send_by_email?
    submission_setting.save!
  end

  def save_config_without_defaults
    CONFIG_WITHOUT_DEFAULTS.each do |config|
      if params(config).present?
        create_or_update_the_service_configuration(config)
      else
        remove_the_service_configuration(config)
      end
    end
  end

  def save_config_with_defaults
    CONFIG_WITH_DEFAULTS.each do |config|
      if params(config).present?
        create_or_update_the_service_configuration(config)
      else
        create_or_update_the_service_configuration_adding_default_value(config)
      end
    end
  end

  def params(config)
    email_settings.params(config.downcase.to_sym)
  end

  def create_or_update_the_service_configuration(config)
    setting = find_or_initialize_setting(config)
    setting.value = params(config)
    setting.save!
  end

  def create_or_update_the_service_configuration_adding_default_value(config)
    setting = find_or_initialize_setting(config)
    setting.value = email_settings.default_value(config.downcase.to_sym)
    setting.save!
  end

  def remove_the_service_configuration(config)
    setting = find_or_initialize_setting(config)
    setting.destroy!
  end

  def find_or_initialize_setting(config)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: email_settings.deployment_environment,
      name: config
    )
  end
end
