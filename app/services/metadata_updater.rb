class MetadataUpdater
  attr_reader :id, :latest_metadata, :service_id, :attributes

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @service_id = attributes.delete(:service_id)
    @id = attributes.delete(:id)
    @attributes = attributes
  end

  def update
    version = new_version(:update)

    return version.metadata unless version.errors?

    false
  end

  def destroy
    version = new_version(:destroy)

    version.metadata
  end

  def metadata(action)
    object = find_node_attribute_by_id
    index = @latest_metadata['pages'].index(object)

    send("#{action}_node", object: object, index: index)

    @latest_metadata
  end

  private

  def find_node_attribute_by_id
    @latest_metadata.extend Hashie::Extensions::DeepLocate

    @latest_metadata.deep_locate(find_id).first
  end

  def find_id
    lambda do |key, value, object|
      key == '_id' && value == @id
    end
  end

  def update_node(object:, index:)
    new_object = object.merge(attributes)
    @latest_metadata['pages'][index] = new_object
  end

  def destroy_node(object:, index:)
    # Don't delete start pages
    return @latest_metadata if object['_type'] == 'page.start'

    @latest_metadata['pages'].delete_at(index)
    @latest_metadata['pages'][0]['steps'].delete(@id)
  end

  def new_version(action)
    @new_version ||= MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata(action)
    )
  end
end
