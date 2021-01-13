class NewServiceGenerator
  attr_reader :service_name, :current_user

  def initialize(service_name:, current_user:)
    @service_name = service_name
    @current_user = current_user
  end

  def to_metadata
    metadata = DefaultMetadata['service.base']

    metadata.tap do
      metadata['configuration']['service'] = DefaultMetadata['config.service']
      metadata['configuration']['meta'] = DefaultMetadata['config.meta']
      metadata['service_name'] = service_name
      metadata['created_by'] = '1234'
    end
  end
end
