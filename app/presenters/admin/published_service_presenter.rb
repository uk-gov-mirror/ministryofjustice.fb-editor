module Admin
  class PublishedServicePresenter
    ENVIRONMENT_LABELS = {
      'production' => 'Live',
      'dev' => 'Test'
    }.freeze

    attr_reader :publish_service

    delegate :service_id, :deployment_environment, :user, to: :publish_service

    def initialize(publish_service)
      @publish_service = publish_service
    end

    def environment_label
      ENVIRONMENT_LABELS.fetch(deployment_environment, deployment_environment)
    end

    def service_name
      @service_name ||= fetch_service_name
    end

    def status
      if maintenance_mode?
        'Maintenance mode'
      elsif publish_service.published?
        'Published'
      else
        'Unpublished'
      end
    end

    def status_modifier
      status.parameterize
    end

    private

    def maintenance_mode?
      ServiceConfiguration.exists?(
        service_id:,
        deployment_environment:,
        name: 'MAINTENANCE_MODE'
      )
    end

    def fetch_service_name
      MetadataApiClient::Service.latest_version(service_id)['service_name'].presence || service_id
    rescue StandardError
      service_id
    end
  end
end
