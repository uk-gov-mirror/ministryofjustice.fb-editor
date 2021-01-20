module MetadataApiClient
  class Version < Resource
    def self.create(service_id:, payload:)
      new(
        connection.post("/services/#{service_id}/versions", payload).body
      )
    rescue Faraday::UnprocessableEntityError => exception
      error_messages(exception)
    end
  end
end
