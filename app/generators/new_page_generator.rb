class NewPageGenerator
  include ActiveModel::Model
  attr_accessor :page_type,
                :page_url,
                :component_type,
                :latest_metadata,
                :add_page_after

  def to_metadata
    latest_metadata.tap do
      latest_metadata['pages'].insert(insert_page_at, page_metadata)
      latest_metadata['pages'][0]['steps'].insert(insert_page_at, page_name)
    end
  end

  def page_metadata
    metadata = DefaultMetadata["page.#{page_type}"]

    metadata.tap do
      metadata['_id'] = page_name
      metadata['_uuid'] = SecureRandom.uuid
      metadata['url'] = page_url
      if component_type.present?
        metadata['components'].push(component)
      end
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

  INSERT_LAST = -1

  def insert_page_at
    if add_page_after.present?
      index = find_page_index_to_be_inserted_after

      return index + 1 if index
    end

    INSERT_LAST
  end

  def find_page_index_to_be_inserted_after
    latest_metadata['pages'].index(
      latest_metadata['pages'].find { |page| page['_uuid'] == add_page_after }
    )
  end
end
