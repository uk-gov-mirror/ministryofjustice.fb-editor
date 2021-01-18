class PagesController < ApplicationController
  def create
    @page_creation = PageCreation.new(page_creation_params)

    if @page_creation.create
      redirect_to edit_page_path(service_id, @page_creation.page_url)
    else
      render template: 'services/edit', status: :unprocessable_entity
    end
  end

  def update
    # find correct page object
    # update object
  end

  def page_creation_params
    params.require(
      :page
    ).permit(
      :page_url, :page_type, :component_type
    ).merge(latest_metadata: service_metadata, service_id: service_id)
  end

  def service_id
    service.service_id
  end
end
