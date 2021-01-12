class DefaultMetadata
  def self.[](key)
    Rails.application.config.default_metadata[key]
  end
end
