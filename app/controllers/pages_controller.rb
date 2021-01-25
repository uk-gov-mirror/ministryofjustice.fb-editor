class PagesController < ApplicationController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def create
    @page_creation = PageCreation.new(page_creation_params)

    if @page_creation.create
      redirect_to edit_page_path(service_id, @page_creation.page_uuid)
    else
      render template: 'services/edit', status: :unprocessable_entity
    end
  end

  def edit
    @page = service.find_page_by_uuid(params[:page_uuid])
  end

  def update
    @page = service.find_page_by_uuid(params[:page_uuid])

    @metadata_updater = MetadataUpdater.new(page_update_params)

    if @metadata_updater.update
      redirect_to edit_page_path(service.service_id, params[:page_uuid])
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def page_creation_params
    params.require(
      :page
    ).permit(
      :page_url, :page_type, :component_type
    ).merge(common_params)
  end

  def page_update_params
    {
      id: @page.id
    }.merge(common_params).merge(page_attributes)
  end

  def page_attributes
    params.require(:page).permit(@page.editable_attributes.keys)
  end

  def common_params
    {
      latest_metadata: service_metadata,
      service_id: service_id
    }
  end

  def service_id
    service.service_id
  end
end
