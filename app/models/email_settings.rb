class EmailSettings
  include ActiveModel::Model
  attr_accessor :deployment_environment,
                :service,
                :send_by_email,
                :service_email_output,
                :service_email_from,
                :service_email_subject,
                :service_email_body,
                :service_email_pdf_heading,
                :service_email_pdf_subheading

  validates :deployment_environment, inclusion: {
    in: Rails.application.config.deployment_environments
  }

  validates :service_email_output, presence: true, if: :send_by_email?

  validates :service_email_output, format: { with: URI::MailTo::EMAIL_REGEXP },
    allow_blank: true

  def send_by_email_checked?
    send_by_email? || SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment
    ).try(:send_email?)
  end

  def send_by_email?
    send_by_email == '1'
  end

  def service_email_output
    settings_for(:service_email_output)
  end

  def service_email_from
    settings_for(:service_email_from)
  end

  def service_email_subject
    settings_for(:service_email_subject)
  end

  def service_email_body
    settings_for(:service_email_body)
  end

  def service_email_pdf_heading
    settings_for(:service_email_pdf_heading)
  end

  def service_email_pdf_subheading
    settings_for(:service_email_pdf_subheading)
  end

  def settings_for(setting_name)
    params(setting_name).presence ||
      database(setting_name) ||
        default_value(setting_name)
  end

  def database(setting_name)
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: deployment_environment,
      name: setting_name.upcase,
    ).try(:decrypt_value)
  end

  def default_value(setting_name)
    I18n.t("default_values.#{setting_name}", service_name: service.service_name)
  end

  def params(setting_name)
    self.instance_variable_get(:"@#{setting_name}")
  end
end
