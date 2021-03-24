module ApplicationHelper
  include MetadataPresenter::ApplicationHelper

  # Used to display a thumbnail on form page with dynamic heading.
  # Due to complexity have created this helper to keep logic out
  # of the template.
  def flow_thumbnail(page, parent_id)
    heading = flow_thumbnail_heading(page)
    type = if page.components.nil? || page.components.empty?
             page._type.gsub('page.', '')
           else
             page.components[0]._type
           end
    link_to edit_page_path(parent_id, page.uuid), class: "form-step_thumbnail #{type}", 'aria-hidden': true do
      concat image_pack_tag('thumbnails/thumbs_header.png', class: 'header')
      concat content_tag(:span, heading, class: 'text')
      concat image_pack_tag("thumbnails/thumbs_#{type}.jpg", class: 'body')
    end
  end

  def flow_thumbnail_heading(page)
    if page.components.nil? || page.components.empty?
      page.heading
    else
      if page._type == 'page.multiplequestions'
        page.heading
      else
        page.components[0].label || page.components[0].legend
      end
    end
  end

end
