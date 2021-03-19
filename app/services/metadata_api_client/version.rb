module MetadataApiClient
  class Version < Resource
    def self.create(service_id:, payload:)
      new(
        connection.post(
          "/services/#{service_id}/versions", { metadata: payload }
        ).body
      )
    rescue Faraday::UnprocessableEntityError => exception
      Sentry.capture_exception(exception)
      error_messages(exception)
    end
  end
end
