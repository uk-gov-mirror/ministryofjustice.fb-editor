class Publisher
  module Utils
    module Hostname
      def hostname
        root_url = Rails.application.config
          .platform_environments[platform_environment][:url_root]

        if deployment_environment == 'production'
          [service_slug, '.', root_url].join
        else
          [service_slug, '.', 'dev', '.', root_url].join
        end
      end

      def platform_environment
        ENV['PLATFORM_ENV']
      end
    end
  end
end
