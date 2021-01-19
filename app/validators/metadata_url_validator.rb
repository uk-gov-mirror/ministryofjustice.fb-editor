class MetadataUrlValidator < ActiveModel::EachValidator
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

  def strip_url(url)
    url.to_s.chomp('/').reverse.chomp('/').reverse
  end
end
