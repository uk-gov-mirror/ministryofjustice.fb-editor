module MetadataApiClient
  class Version < Resource
    def self.create(service_id:, metadata:)
      new(
        connection.post("/services/#{service_id}/versions", metadata).body
      )
    rescue Faraday::UnprocessableEntityError => exception
      error_messages(exception)
    end
  end
end
