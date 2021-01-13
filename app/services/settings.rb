class Settings < Editor::Service
  def update
    return false if invalid? || latest_metadata.blank?

    version = MetadataApiClient::Version.create(
      service_id: service_id,
      metadata: metadata
    )

    add_errors(version) if version.errors?

    !version.errors?
  end

  def metadata
    {
      metadata: latest_metadata.merge(
        service_name: service_name,
        created_by: '1234' # current_user
      )
    }
  end
end
