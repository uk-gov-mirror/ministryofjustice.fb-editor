class Publisher
  module Utils
    class KubernetesConfiguration
      attr_reader :service_provisioner

      TEMPLATES = %w(
        service
        service_monitor
        ingress
        deployment
        config_map
      )

      def initialize(service_provisioner)
        @service_provisioner = service_provisioner
      end

      def generate(destination:)
        TEMPLATES.each do |template|
          template_content = File.open(
            Rails.root.join(
              'config',
              'publisher',
              'cloud_platform',
              "#{template}.yaml.erb"
            ),
            'r'
          ).read
          erb = ERB.new(template_content)
          content = erb.result(service_provisioner.get_binding)

          write_config_file(
            file: File.expand_path(File.join(destination, "#{template}.yaml")),
            content: content
          )
        end
      end

      private

      def write_config_file(file:, content:)
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'w+') do |f|
          f << content
        end
      end
    end
  end
end
