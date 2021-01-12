module MetadataApiClient
  class Service
    attr_accessor :id, :name, :metadata

    def initialize(attributes={})
      @id = attributes['service_id']
      @name = attributes['service_name']
      @metadata = attributes
    end

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
      errors = JSON.parse(
        exception.response_body, symbolize_names: true
      )[:message]

      MetadataApiClient::ErrorMessages.new(errors)
    end

    def self.connection
      Connection.new
    end

    def ==(other_service)
      id == other_service.id
    end

    def errors?
      false
    end
  end
end
