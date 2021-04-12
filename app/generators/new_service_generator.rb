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
      metadata['service_name'] = service_name
      metadata['created_by'] = current_user.id
    end

    metadata['standalone_pages'] = footer_pages
    metadata
  end

  private

  def footer_pages
    I18n.t('footer').map do |attributes|
      metadata = NewPageGenerator.new(
        page_type: 'standalone',
        page_url: attributes[:url],
        page_uuid: SecureRandom.uuid
      ).to_metadata

      metadata.tap do
        metadata['heading'] = attributes[:heading]
        metadata['body'] = attributes[:body]
      end
    end
  end
end
