module MetadataApiClient
  class Version < Resource
    def self.create(service_id:, payload:)
      new(
        connection.post(
          "/services/#{service_id}/versions", { metadata: payload }
        ).body
      )
    rescue Faraday::UnprocessableEntityError => e
      Sentry.capture_exception(e)
      error_messages(e)
    end
  end
end
