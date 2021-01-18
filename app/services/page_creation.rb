class PageCreation
  include ActiveModel::Model
  attr_accessor :page_url,
                :page_type,
                :component_type,
                :latest_metadata,
                :service_id
  validates :page_url, presence: true

  def create
    return false if invalid?

    metadata = NewPageGenerator.new(
      page_type: page_type,
      page_url: page_url.strip,
      component_type: component_type,
      latest_metadata: latest_metadata
    ).to_metadata

    version = MetadataApiClient::Version.create(
      service_id: service_id,
      metadata: { metadata: metadata }
    )

    if version.errors?
      self.errors.add(:base, :invalid, message: version.errors)
    else
      version
    end
  end
end
