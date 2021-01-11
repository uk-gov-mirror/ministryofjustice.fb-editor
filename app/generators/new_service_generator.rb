class NewServiceGenerator
  attr_reader :name, :current_user

  def initialize(name:, current_user:)
    @name = name
    @current_user = current_user
  end

  def to_metadata
    metadata = DefaultMetadata['service.base']

    metadata.tap do
      metadata['configuration']['service'] = DefaultMetadata['config.service']
      metadata['configuration']['meta'] = DefaultMetadata['config.meta']
      metadata['service_name'] = name
      metadata['created_by'] = current_user.id
    end
  end
end
