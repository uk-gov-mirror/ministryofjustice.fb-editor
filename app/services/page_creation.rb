class PageCreation
  include ActiveModel::Model
  attr_accessor :page_url,
                :page_type,
                :component_type,
                :latest_metadata,
                :service_id,
                :version,
                :add_page_after

  validates :page_url, :page_type, presence: true
  validates :page_url, format: { with: /\A[\sa-zA-Z0-9-]*\z/ }

  validates :page_type, metadata_presence: { metadata_key: :page }
  validates :component_type, metadata_presence: { metadata_key: :component }
  validates :page_url, metadata_url: { metadata_method: :latest_metadata }

  def page_uuid
    @page_uuid ||= SecureRandom.uuid
  end

  def create
    return false if invalid?

    version = MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata
    )

    if version.errors?
      errors.add(:base, :invalid, message: version.errors)
      false
    else
      @version = version
    end
  end

  def metadata
    NewPageGenerator.new(
      page_type: page_type,
      page_url: page_url.strip,
      component_type: component_type,
      latest_metadata: latest_metadata,
      add_page_after: add_page_after,
      page_uuid: page_uuid
    ).to_metadata
  end
end
