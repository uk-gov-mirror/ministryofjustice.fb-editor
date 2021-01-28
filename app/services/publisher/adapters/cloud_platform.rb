class Publisher
  module Adapters
    class CloudPlatform
      attr_reader :service_provisioner
      delegate :service_id, to: :service_provisioner

      def initialize(service_provisioner)
        @service_provisioner = service_provisioner
      end

      def pre_publishing
        ::Publisher::Utils::KubernetesConfiguration.new(
          service_provisioner
        ).generate(destination: config_dir)
      end

      # provision pods (kubectl apply) in namespace formbuilder-services-test-dev
      #
      # kubectl apply -f ./dir
      # --context=#{@environment.kubectl_context}
      # --namespace=#{@environment.namespace}
      # --token=$KUBECTL_BEARER_TOKEN
      #
      def publishing
      end

      # restart the server
      #
      # kubectl patch deployment service_slug
      # -p timestamp
      # --context=#{@environment.kubectl_context}
      # --namespace=#{@environment.namespace}
      # --token=$KUBECTL_BEARER_TOKEN
      #
      # Run rollout status?
      # kubectl rollout status deployment service_slug
      # --context=#{@environment.kubectl_context}
      # --namespace=#{@environment.namespace}
      # --token=$KUBECTL_BEARER_TOKEN
      #
      def post_publishing
      end

      ## send slack notification
      ##
      def completed
      end

      private

      def config_dir
        FileUtils.mkdir_p(Rails.root.join('tmp', 'publisher', service_id))
      end
    end
  end
end
