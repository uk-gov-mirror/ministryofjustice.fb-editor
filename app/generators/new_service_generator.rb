class NewServiceGenerator
  attr_reader :service_name, :current_user

  def initialize(service_name:, current_user:)
    @service_name = service_name
    @current_user = current_user
  end

  def to_metadata
    metadata = DefaultMetadata['service.base']

    metadata.tap do
      metadata['configuration']['service'] = DefaultMetadata['config.service']
      metadata['configuration']['meta'] = DefaultMetadata['config.meta']
      metadata['pages'].push(DefaultMetadata['page.start'])
      metadata['pages'][0]['_uuid'] = SecureRandom.uuid
      metadata['standalone_pages'] = footer_pages
      metadata['service_name'] = service_name
      metadata['created_by'] = current_user.id
    end
  end

  private

  def footer_pages
    I18n.t('footer').map do |key, attributes|
      NewStandalonePageGenerator.new(
        page_type: 'standalone',
        page_url: attributes[:url],
        latest_metadata: service_metadata,
      ).to_metadata
    end
  end
end
