class Publisher
  module Adapters
    class CloudPlatform
      class ConfigFilesNotFound < StandardError; end
      attr_reader :service_provisioner

      delegate :service_id,
               :namespace,
               :service_slug,
               :hostname,
               :service_name,
               :deployment_environment,
               :live_production?,
               to: :service_provisioner

      def initialize(service_provisioner)
        @service_provisioner = service_provisioner
      end

      def pre_publishing
        ::Publisher::Utils::KubernetesConfiguration.new(
          service_provisioner
        ).generate(destination: create_config_dir)
      end

      def publishing
        if config_dir? && config_files?
          Utils::KubeControl.execute(
            "apply -f #{config_dir}", namespace: namespace
          )
        else
          raise ConfigFilesNotFound, "Config files not found in #{config_dir}"
        end
      end

      def post_publishing
        Utils::KubeControl.execute(
          "rollout restart deployment #{service_slug}",
          namespace: namespace
        )
        Utils::KubeControl.execute(
          "rollout status deployment #{service_slug}",
          namespace: namespace
        )
      end

      def completed
        if live_production? && first_published?
          NotificationService.notify(message)
        end
      end

      private

      def first_published?
        PublishService.completed
        .where(
          service_id: service_id,
          deployment_environment: deployment_environment
        ).count == 1
      end

      def message
        "#{service_name} has been published to #{namespace}.\n#{hostname}"
      end

      def create_config_dir
        FileUtils.mkdir_p(config_dir)
      end

      def config_dir
        Rails.root.join('tmp', 'publisher', service_id)
      end

      def config_dir?
        File.exist?(config_dir)
      end

      def config_files?
        Dir["#{config_dir}/*"].any?
      end
    end
  end
end
