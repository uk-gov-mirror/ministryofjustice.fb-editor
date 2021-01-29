class PublishServiceJob < ApplicationJob
  queue_as :default

  def perform(publish_service_id:)
    publish_service = PublishService.find(publish_service_id)

    service_provisioner = Publisher::ServiceProvisioner.new(
      service_id: publish_service.service_id,
      deployment_environment: publish_service.deployment_environment,
      platform_environment: ENV['PLATFORM_ENV']
    )

    if service_provisioner.valid?
      Publisher.new(
        publish_service: publish_service,
        service_provisioner: service_provisioner,
        adapter: Publisher::Adapters::CloudPlatform
      ).call
    else
      raise "Parameters invalid: #{service_provisioner.errors.full_messages}"
    end
  end
end
