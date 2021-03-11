module ApplicationHelper
  include MetadataPresenter::ApplicationHelper

  # Used to display a thumbnail on form page with dynamic heading.
  # Due to complexity have created this helper to keep logic out
  # of the template.
  def flow_thumbnail(page, parent_id)
    if page.components.nil? || page.components.empty?
      type = page._type.gsub("page.", "")
      heading = page.heading
    else
      type = page.components[0]._type
      heading = page.components[0].label || page.components[0].legend
    end
    link_to edit_page_path(parent_id, page.uuid), class: "form-step_thumbnail #{type}", 'aria-hidden': true do
      concat image_pack_tag('thumbnails/thumbs_header.png', class: 'header')
      concat content_tag(:span, heading, class: 'text')
      concat image_pack_tag("thumbnails/thumbs_#{type}.jpg", class: 'body')
    end
  end

end
