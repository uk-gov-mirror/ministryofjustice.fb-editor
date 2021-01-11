class NewServiceGenerator
  attr_reader :name, :current_user

  def initialize(name:, current_user:)
    @name = name
    @current_user = current_user
  end

  def to_metadata
    default_metadata = Rails.application.config.default_metadata['service.base']
    default_metadata['configuration']['service'] = Rails.application.config.default_metadata['config.service']
    default_metadata['configuration']['meta'] = Rails.application.config.default_metadata['config.meta']
    default_metadata['service_name'] = name
    default_metadata['created_by'] = current_user.id
    default_metadata
  end
end
