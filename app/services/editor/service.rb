module Editor
  class Service
    include ActiveModel::Model
    attr_accessor :service_name, :current_user, :service_id, :latest_metadata
    validates :service_name, presence: true
    validates :service_name, length: { minimum: 3, maximum: 128 }, allow_blank: true
    validates :service_name, format: { with: /\A[\sa-zA-Z0-9-]*\z/ }, allow_blank: true

    def add_errors(service)
      service.errors.each do |error_message|
        self.errors.add(:service_name, :taken)
      end
    end
  end
end
