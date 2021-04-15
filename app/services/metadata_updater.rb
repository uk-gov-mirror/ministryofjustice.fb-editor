class MetadataUpdater
  attr_reader :id, :latest_metadata, :service_id, :attributes

  PAGES = 'pages'.freeze

  def initialize(attributes)
    @latest_metadata = attributes.delete(:latest_metadata).to_h.deep_dup
    @service_id = attributes.delete(:service_id)
    @id = attributes.delete(:id)
    @actions = attributes.delete(:actions)
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
    page_collection, index = find_page_collection_and_index(object)

    send(
      "#{action}_node",
      object: object,
      index: index,
      page_collection: page_collection
    )

    @latest_metadata
  end

  def component_added
    MetadataPresenter::Component.new(@component_added) if @component_added
  end

  private

  def find_page_collection_and_index(object)
    %w[pages standalone_pages].each do |collection|
      index = @latest_metadata[collection].index(object)
      return collection, index if index.present?
    end
  end

  def find_node_attribute_by_id
    @latest_metadata.extend Hashie::Extensions::DeepLocate

    @latest_metadata.deep_locate(find_id).first
  end

  def find_id
    lambda do |key, value, _object|
      key == '_id' && value == @id
    end
  end

  def update_node(object:, index:, page_collection:)
    new_object = object.merge(attributes)

    if @actions && @actions[:add_component].present?
      new_object[component_collection] ||= []
      component = NewComponentGenerator.new(
        component_type: @actions[:add_component],
        page_url: new_object['url'].gsub(/^\//, ''),
        components: new_object[component_collection]
      ).to_metadata
      new_object[component_collection].push(component)
      @component_added = component
    end

    @latest_metadata[page_collection][index] = new_object
    @latest_metadata
  end

  def destroy_node(object:, index:, page_collection:)
    # Don't delete start pages
    return @latest_metadata if object['_type'] == 'page.start'

    @latest_metadata[page_collection].delete_at(index)
    @latest_metadata['pages'][0]['steps'].delete(@id) if flow_page?(page_collection)
    @latest_metadata
  end

  def new_version(action)
    @new_version ||= MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata(action)
    )
  end

  def flow_page?(page_collection)
    page_collection == PAGES
  end

  def component_collection
    @component_collection ||= @actions[:component_collection]
  end
end
