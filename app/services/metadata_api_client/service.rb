module MetadataApiClient
  class Service < Resource
    def self.all(user_id:)
      response = connection.get("/services/users/#{user_id}").body['services']
      Array(response).map { |service| new(service) }
    end

    def self.latest_version(service_id)
      new(
        connection.get("/services/#{service_id}/versions/latest").body
      ).metadata
    end

    def self.create(metadata)
      response = connection.post('/services', metadata)
      new(response.body)
    rescue Faraday::UnprocessableEntityError => exception
      Sentry.capture_exception(exception)
      error_messages(exception)
    end
  end
end
