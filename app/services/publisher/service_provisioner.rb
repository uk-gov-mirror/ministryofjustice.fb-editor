require 'securerandom'

class Publisher
  class ServiceProvisioner
    include ActiveModel::Model
    include ::Publisher::Utils::Hostname

    attr_accessor :service_id,
                  :platform_environment,
                  :deployment_environment,
                  :service_configuration

    validates :service_id,
              :platform_environment,
              :deployment_environment,
              :service_configuration,
              presence: true

    validates :service_configuration, private_public_key: true

    LIVE_PRODUCTION = 'live-production'.freeze

    def service_metadata
      service.to_json.inspect
    end

    def get_binding
      binding
    end

    delegate :service_slug, to: :service

    delegate :service_name, to: :service

    def namespace
      sprintf(Rails.application.config.platform_environments[:common][:namespace], platform_environment: platform_environment, deployment_environment: deployment_environment)
    end

    def container_port
      Rails.application.config.platform_environments[:common][:container_port]
    end

    def secret_key_base
      SecureRandom.hex(64)
    end

    def config_map_name
      "fb-#{service_slug}-config-map"
    end

    def secret_name
      "fb-#{service_slug}-secrets"
    end

    def service_monitor_name
      "formbuilder-form-#{service_slug}-service-monitor-#{platform_environment}-#{deployment_environment}"
    end

    def service_monitor_network_policy_name
      "formbuilder-form-#{service_slug}-service-monitor-ingress-#{platform_environment}-#{deployment_environment}"
    end

    def replicas
      if platform_environment == 'live' && deployment_environment == 'production'
        2
      else
        1
      end
    end

    def user_datastore_url
      sprintf(Rails.application.config.platform_environments[:common][:user_datastore_url], platform_environment: platform_environment, deployment_environment: deployment_environment)
    end

    def submitter_url
      sprintf(Rails.application.config.platform_environments[:common][:submitter_url], platform_environment: platform_environment, deployment_environment: deployment_environment)
    end

    def submission_encryption_key
      ENV['SUBMISSION_ENCRYPTION_KEY']
    end

    def resource_limits_cpu
      '150m'
    end

    def resource_limits_memory
      '300Mi'
    end

    def resource_requests_cpu
      '10m'
    end

    def resource_requests_memory
      '128Mi'
    end

    def service_sentry_dsn
      if live_production?
        ENV['SERVICE_SENTRY_DSN_LIVE']
      else
        # test-dev, test-production and live-dev
        ENV['SERVICE_SENTRY_DSN_TEST']
      end
    end

    def live_production?
      platform_deployment == LIVE_PRODUCTION
    end

    def config_map
      service_configuration.reject(&:secrets?).reject(&:do_not_send_submission?)
    end

    def secrets
      service_configuration.select(&:secrets?)
    end

    private

    def service
      @service ||= MetadataPresenter::Service.new(
        MetadataApiClient::Service.latest_version(service_id)
      )
    end

    def platform_deployment
      "#{platform_environment}-#{deployment_environment}"
    end
  end
end
