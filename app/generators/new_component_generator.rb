class NewComponentGenerator
  attr_reader :component_type, :page_id

  def initialize(component_type:, page_id:)
    @component_type = component_type
    @page_id = page_id
  end

  def to_metadata
    metadata = DefaultMetadata["component.#{component_type}"]

    metadata.tap do
      metadata['_id'] = component_id
    end
  end

  private

  def component_id
    # This is currently using the same structure as the old editor generates
    # should we create something else?
    # page.page_id.text.auto_name_1, for example?
    "page.#{page_id}--#{component_type}.auto_name__1"
  end
end
