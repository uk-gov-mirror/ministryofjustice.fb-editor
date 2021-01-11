class ServiceCreation
  include ActiveModel::Model
  attr_accessor :name, :current_user, :service_id
  validates :name, presence: true
  validates :name, length: { minimum: 3, maximum: 128 }, allow_blank: true

  def create
    return false if invalid?

    service = MetadataApiClient::Service.create(metadata)

    self.tap do
      self.service_id = service.id
    end
  end

  def metadata
    {
      metadata: NewServiceGenerator.new(
        name: name,
        current_user: current_user
      ).to_metadata
    }
  end
end
