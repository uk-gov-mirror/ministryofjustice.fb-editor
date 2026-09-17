module Admin
  class ServiceNameResolver
    def self.call(service_id)
      return if service_id.blank?

      MetadataApiClient::Service.latest_version(service_id)['service_name'].presence || service_id
    rescue StandardError
      service_id
    end
  end
end
