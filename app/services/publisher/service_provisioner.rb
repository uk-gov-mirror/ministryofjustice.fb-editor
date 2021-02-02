require 'securerandom'

class Publisher
  class ServiceProvisioner
    include ActiveModel::Model
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

    def service_metadata
      service.to_json
    end

    def get_binding
      binding
    end

    def service_slug
      service.service_name.parameterize
    end

    def namespace
      Rails.application.config.platform_environments[:common][:namespace] % {
        platform_environment: platform_environment,
        deployment_environment: deployment_environment
      }
    end

    def hostname
      root_url = Rails.application.config
        .platform_environments[platform_environment][:url_root]

      if deployment_environment == 'production'
        [service_slug, '.', root_url].join
      else
        [service_slug, '.', 'dev', '.', root_url].join
      end
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
      Rails.application.config.platform_environments[:common][:user_datastore_url] % {
        platform_environment: platform_environment,
        deployment_environment: deployment_environment
      }
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

    private

    def service
      @service ||= MetadataPresenter::Service.new(
        MetadataApiClient::Service.latest_version(service_id)
      )
    end
  end
end
