class PublishServiceCreation
  include ActiveModel::Model
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
            length: { minimum: 6, maximum: 50 },
            if: :require_authentication?

  def save
    return false if invalid?
    # wrap in a transaction
    create_publish_service
    create_service_configurations

    true
  end

  def create_publish_service
    publish_service.save!
    @publish_service_id = publish_service.id
  end

  def create_service_configurations
    create_or_update_configuration(name: 'USERNAME', value: username)
    create_or_update_configuration(name: 'PASSWORD', value: password)
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

  def require_authentication?
    require_authentication == '1'
  end
end
