class MetadataUrlValidator < ActiveModel::EachValidator
  include ApplicationHelper

  def validate_each(record, attribute, value)
    return if value.blank?

    metadata = record.send(options[:metadata_method])

    urls = metadata['pages'].map do |page|
      strip_url(page['url'])
    end

    if urls.include?(strip_url(value))
      record.errors.add(attribute, :taken)
    end
  end
end
