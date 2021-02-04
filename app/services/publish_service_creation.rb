class PublishServiceCreation
  include ActiveModel::Model
  REQUIRE_AUTHENTICATION = '1'.freeze
  USERNAME = 'USERNAME'.freeze
  PASSWORD = 'PASSWORD'.freeze

  attr_accessor :service_id,
                :deployment_environment,
                :require_authentication,
                :username,
                :password,
                :publish_service_id

  validates :service_id, presence: true
  validates :username,
            :password,
            presence: true,
            if: :require_authentication?
  validates :username, :password,
            length: { minimum: 6, maximum: 50 },
            if: :require_authentication?,
            allow_blank: true

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      create_publish_service

      if require_authentication?
        create_service_configurations
      else
        delete_service_configurations
      end
    end

    true
  end

  def create_publish_service
    publish_service.save!
    @publish_service_id = publish_service.id
  end

  def create_service_configurations
    create_or_update_configuration(name: USERNAME, value: username)
    create_or_update_configuration(name: PASSWORD, value: password)
  end

  def delete_service_configurations
    delete_service_configuration(name: USERNAME)
    delete_service_configuration(name: PASSWORD)
  end

  def publish_service
    @publish_service ||= PublishService.new(
      service_id: service_id,
      deployment_environment: deployment_environment,
      status: :queued
    )
  end

  private

  def create_or_update_configuration(name:, value:)
    service_configuration = ServiceConfiguration.find_or_initialize_by(
      service_id: service_id,
      deployment_environment: deployment_environment,
      name: name
    )
    service_configuration.value = Base64.strict_encode64(value)
    service_configuration.save!
  end

  def delete_service_configuration(name:)
    ServiceConfiguration.destroy_by(
      service_id: service_id,
      deployment_environment: deployment_environment,
      name: name
    )
  end

  def require_authentication?
    require_authentication == REQUIRE_AUTHENTICATION
  end
end
