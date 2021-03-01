class Settings < Editor::Service
  attr_accessor :current_user

  def update
    return false if invalid? || latest_metadata.blank?

    version = MetadataApiClient::Version.create(
      service_id: service_id,
      payload: metadata
    )

    add_errors(version) if version.errors?

    !version.errors?
  end

  def metadata
    latest_metadata.merge(
      service_name: service_name,
      created_by: current_user.id
    )
  end
end
