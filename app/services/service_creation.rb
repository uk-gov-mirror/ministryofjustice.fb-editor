class ServiceCreation < Editor::Service
  def create
    return false if invalid?

    service = MetadataApiClient::Service.create(metadata)

    if service.errors?
      add_errors(service)
      false
    else
      assign_service_attributes(service)
    end
  end

  def assign_service_attributes(service)
    self.tap do
      self.service_id = service.id
    end
  end

  def metadata
    {
      metadata: NewServiceGenerator.new(
        service_name: service_name.strip,
        current_user: current_user
      ).to_metadata
    }
  end
end
