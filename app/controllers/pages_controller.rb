class PagesController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  before_action :assign_required_objects, only: %i[edit update destroy]

  COMPONENTS = 'components'.freeze
  EXTRA_COMPONENTS = 'extra_components'.freeze

  def create
    @page_creation = PageCreation.new(page_creation_params)

    if @page_creation.create
      redirect_to edit_page_path(service_id, @page_creation.page_uuid)
    else
      render template: 'services/edit', status: :unprocessable_entity
    end
  end

  def update
    @metadata_updater = MetadataUpdater.new(page_update_params)

    if @metadata_updater.update
      redirect_to edit_page_path(
        service.service_id,
        params[:page_uuid],
        anchor: @metadata_updater.component_added.try(:id)
      )
    else
      @page.errors.add(:base, :unprocessable)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @metadata_updater = MetadataUpdater.new(common_params.merge(id: @page.id))

    @metadata_updater.destroy
    redirect_to edit_service_path(service.service_id)
  end

  def page_creation_params
    params.require(
      :page
    ).permit(
      :page_url, :page_type, :component_type, :add_page_after
    ).merge(common_params)
  end

  def page_update_params
    update_params = ActiveSupport::HashWithIndifferentAccess.new({
      id: @page.id
    }.merge(common_params).merge(page_attributes))

    if params[:page] && additional_component
      update_params[:actions] = {
        add_component: additional_component,
        component_collection: component_collection
      }
    end

    if update_params[:components]
      update_params[:components] = update_params[:components].each.map do |_, value|
        JSON.parse(value)
      end
    end

    update_params
  end

  def page_attributes
    params.require(:page).permit!
  end

  def common_params
    {
      latest_metadata: service_metadata,
      service_id: service_id
    }
  end

  delegate :service_id, to: :service

  def change_answer_path(url:)
    ''
  end
  helper_method :change_answer_path

  def reserved_submissions_path
    ''
  end
  helper_method :reserved_submissions_path

  def pages_presenters
    MetadataPresenter::PageAnswersPresenter.map(
      view: view_context,
      pages: service.pages,
      answers: {}
    )
  end
  helper_method :pages_presenters

  private

  # The metadata presenter gem requires this objects to render a page
  #
  def assign_required_objects
    @page = service.find_page_by_uuid(params[:page_uuid])
    @page_answers = MetadataPresenter::PageAnswers.new(@page, {})
  end

  def additional_component
    @additional_component ||= add_component || add_extra_component
  end

  def add_component
    @add_component ||= params[:page][:add_component]
  end

  def add_extra_component
    @add_extra_component ||= params[:page][:add_extra_component]
  end

  def component_collection
    add_extra_component ? EXTRA_COMPONENTS : COMPONENTS
  end
end
