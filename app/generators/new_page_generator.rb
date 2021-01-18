class NewPageGenerator
  include ActiveModel::Model
  attr_accessor :page_type, :page_url, :component_type, :latest_metadata

  # add to pages array the page object after the start page
  # add the component into the page object
  # add page name to steps array in page.start
  #
  def to_metadata
    latest_metadata.tap do
      latest_metadata['pages'].push(page_metadata)
    end
  end

  def page_metadata
    metadata = DefaultMetadata["page.#{page_type}"]

    metadata.tap do
      metadata['_id'] = page_name
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
      page_id: page_name
    ).to_metadata
  end
end
