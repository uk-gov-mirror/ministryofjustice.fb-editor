class NewPageGenerator
  include ActiveModel::Model
  attr_accessor :page_type, :page_url, :component_type, :latest_metadata

  def to_metadata
    latest_metadata.tap do
      latest_metadata['pages'].push(page_metadata)
      latest_metadata['pages'][0]['steps'].push(page_name)
    end
  end

  def page_metadata
    metadata = DefaultMetadata["page.#{page_type}"]

    metadata.tap do
      metadata['_id'] = page_name
      metadata['_uuid'] = SecureRandom.uuid
      metadata['url'] = page_url
      metadata['components'].push(component)
    end
  end

  private

  def page_name
    "page.#{page_url}"
  end

  def component
    NewComponentGenerator.new(
      component_type: component_type,
      page_url: page_url
    ).to_metadata
  end
end
