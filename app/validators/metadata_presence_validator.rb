class MetadataPresenceValidator < ActiveModel::EachValidator
  # Validate the existence of the attribute based on the default metadata.
  #
  # class MyClass
  #   include ActiveModel::Model
  #
  #   validates :page_type, metadata_presence: { metadata_key: 'page' }
  #   validates :component_type, metadata_presence: { metadata_key: 'component' }
  # end
  #
  # So if we try to: MyClass.new(page_type: 'some-page-type') and there is
  # no page.some-page-type in the default metadata then there should be errors.
  #
  def validate_each(record, attribute, value)
    return if value.blank?

    default_metadata_key = "#{options[:metadata_key]}.#{value}"
    if DefaultMetadata[default_metadata_key].blank?
      record.errors.add attribute, "Key '#{default_metadata_key}' not found in default metadata"
    end
  end
end
