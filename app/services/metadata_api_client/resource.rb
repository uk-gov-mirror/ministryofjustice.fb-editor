module MetadataApiClient
  class Resource
    attr_accessor :id, :name, :metadata

    def initialize(attributes={})
      @id = attributes['service_id']
      @name = attributes['service_name']
      @metadata = attributes
    end

    def self.connection
      Connection.new
    end

    def self.error_messages(exception)
      errors = JSON.parse(
        exception.response_body, symbolize_names: true
      )[:message]

      MetadataApiClient::ErrorMessages.new(errors)
    end

    def ==(other)
      id == other.id
    end

    def errors?
      false
    end
  end
end

