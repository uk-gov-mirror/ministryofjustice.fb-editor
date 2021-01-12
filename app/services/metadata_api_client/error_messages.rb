module MetadataApiClient
  class ErrorMessages
    attr_reader :errors

    def initialize(errors)
      @errors = errors
    end

    def ==(other)
      errors == other.errors
    end

    def errors?
      errors.present?
    end
  end
end
