class Publisher
  module Adapters
    class CloudPlatform
      class ConfigFilesNotFound < StandardError; end
      attr_reader :service_provisioner
      delegate :service_id, :namespace, :service_slug, to: :service_provisioner

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
          raise ConfigFilesNotFound.new("Config files not found in #{config_dir}")
        end
      end

      def post_publishing
        Utils::KubeControl.execute(
          "patch deployment #{service_slug} -p '#{timestamp}'",
          namespace: namespace
        )
        Utils::KubeControl.execute(
          "rollout status deployment #{service_slug}",
          namespace: namespace
        )
      end

      def completed
      end

      private

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

      def timestamp
        {
          spec: {
            template: {
              metadata: {
                annotations: {
                  updated_at: "#{Time.now.to_i}"
                }
              }
            }
          }
        }.to_json
      end
    end
  end
end
