class ServiceCreation
  include ActiveModel::Model
  attr_accessor :name, :current_user, :service_id
  validates :name, presence: true
  validates :name, length: { minimum: 3, maximum: 128 }, allow_blank: true

  def create
    return false if invalid?

    service = MetadataApiClient::Service.create(metadata)

    if service.errors?
      service.errors.each do |error_message|
        self.errors.add(:base, :invalid, message: error_message)
      end

      false
    else
      self.tap do
        self.service_id = service.id
      end
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
