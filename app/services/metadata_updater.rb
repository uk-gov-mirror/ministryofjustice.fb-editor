class MetadataUpdater
  attr_reader :id, :latest_metadata, :service_id, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h
    @service_id = attributes.delete(:service_id)
    @id = attributes.delete(:id)
    @attributes = attributes
  end

  def update
    version = MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata
    )

    return version.metadata unless version.errors?

    false
  end

  def metadata
    @latest_metadata.extend Hashie::Extensions::DeepLocate

    object = @latest_metadata.deep_locate(find_id).first
    new_object = object.merge(attributes)
    index = @latest_metadata['pages'].index(object)
    @latest_metadata['pages'][index] = new_object

    @latest_metadata
  end

  def find_id
    lambda do |key, value, object|
      key == '_id' && value == @id
    end
  end
end
