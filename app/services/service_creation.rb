class ServiceCreation
  include ActiveModel::Model
  attr_accessor :name, :current_user, :service_id
  validates :name, presence: true

  def create
    return false if invalid?

    service = MetadataApiClient::Service.create(metadata)

    self.tap do
      self.service_id = service.id
    end
  end

  def metadata
    {
      metadata: {
        _id: 'service.base',
        _type: 'service.base',
        service_name: name,
        created_by: current_user.id,
        configuration: {
          service: {
            _id: 'config.service',
            _type: 'config.service'
          },
          meta: {
            _id: 'config.meta',
            _type: 'config.meta'
          }
        },
        pages: [
          {
            _id: 'page.start',
            _type: 'page.start',
            body: "**This is the main content section of your start page**\r\n\r\n[Edit this page](/edit) with content for your own service.\r\n\r\n## Adding more content\r\n\r\nYou can add multiple headings, links and paragraphs - all in this one content section.\r\n\r\nUse [markdown](https://www.gov.uk/guidance/how-to-publish-on-gov-uk/markdown) to format headings, bullet lists and links.",
            heading: 'This is your start page heading',
            lede: 'This is your start page first paragraph. You can only have one paragraph here.',
            steps: [],
            url: '/'
          }
        ],
        locale: 'en'
      }
    }
#    MetadataGenerator.new(type: :start_page).to_metadata
  end
end
