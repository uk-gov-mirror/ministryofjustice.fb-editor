class NewComponentGenerator
  DEFAULT_VALIDATION = { 'required' => true }.freeze
  attr_reader :component_type, :page_url, :components

  def initialize(component_type:, page_url:, components: [])
    @component_type = component_type
    @page_url = page_url
    @components = components
  end

  def to_metadata
    metadata = DefaultMetadata["component.#{component_type}"]

    metadata.tap do
      metadata['_id'] = component_id
      metadata['name'] = component_id

      if metadata['validation'].present?
        metadata['validation'].merge!(DEFAULT_VALIDATION)
      else
        metadata['validation'] = DEFAULT_VALIDATION
      end
    end
  end

  private

  def component_id
    @component_id ||= "#{page_url}_#{component_type}_#{increment}"
  end

  def increment
    components.select { |c| c['_type'] == component_type }.size + 1
  end
end
