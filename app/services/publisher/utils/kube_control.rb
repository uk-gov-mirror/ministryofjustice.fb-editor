class Publisher
  module Utils
    class KubeControl
      def self.execute(command, namespace:)
        Shell.exec(
          kubectl_binary,
          command,
          "--namespace=#{namespace}",
          '--token=$EDITOR_SERVICE_ACCOUNT_TOKEN'
          # --context=?
        )
      end

      def self.kubectl_binary
        '$(which kubectl)'
      end
    end
  end
end
