class PagesController < FormController
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :assign_required_objects, only: %i[edit update destroy]
  around_action :switch_locale, only: %i[edit update]

  COMPONENTS = 'components'.freeze
  EXTRA_COMPONENTS = 'extra_components'.freeze

  def edit
    return if @page.components.nil?

    if @page.autocomplete_component_present?
      items = autocomplete_items(@page.components)
      @page.assign_autocomplete_items(items)
    end
  end

  def create
    @page_creation = PageCreation.new(page_creation_params)

    if @page_creation.create
      redirect_to edit_page_path(service_id, @page_creation.page_uuid)
    else
      @pages_flow = PagesFlow.new(service).build
      render template: 'services/edit', status: :unprocessable_entity
    end
  end

  def update
    @metadata_updater = PageUpdater.new(page_update_params)

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
    @metadata_updater = PageDestroyer.new(common_params.merge(uuid: @page.uuid))

    @metadata_updater.destroy
    redirect_to edit_service_path(service.service_id)
  end

  def page_creation_params
    params.require(
      :page
    ).permit(
      :page_url, :page_type, :component_type, :add_page_after, :conditional_uuid
    ).merge(parameterize_url).merge(common_params)
  end

  def page_update_params
    update_params = ActiveSupport::HashWithIndifferentAccess.new({
      uuid: @page.uuid
    }.merge(common_params).merge(page_attributes))

    add_component_to_actions_params(update_params) if params[:page] && additional_component

    delete_components_from_actions_params(update_params) if params['delete_components'].present?

    parse_components(update_params)
  end

  def parse_components(update_params)
    %i[components extra_components].each do |collection|
      next if update_params[collection].blank?

      update_params[collection] = update_params[collection].each.map do |_, value|
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
      service_id:
    }
  end

  # used by multiupload template
  def uploads_remaining
    0
  end
  helper_method :uploads_remaining

  def uploads_count
    0
  end
  helper_method :uploads_count

  def answered?(component_id)
    false
  end
  helper_method :answered?

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

  def add_component_to_actions_params(update_params)
    update_params[:actions] = {
      add_component: additional_component,
      component_collection:
    }
  end

  def delete_components_from_actions_params(update_params)
    update_params[:actions] = (update_params[:actions] || {}).merge(
      delete_components: params['delete_components']
    )
  end

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

  def parameterize_url
    { page_url: params[:page][:page_url].parameterize }
  end

  def page_title
    if @page
      if @page.heading.present?
        cookies_page? ? page_heading_title : edit_page_title
      elsif @page.components.present?
        if component_label_present?
          component_label_title
        elsif component_legend_present?
          component_legend_title
        end
      else
        default_edit_page_title
      end
    else
      edit_form_title
    end
  end
  helper_method :page_title

  def edit_form_title
    "Edit form - #{service.service_name} - MoJ Forms"
  end

  def default_edit_page_title
    'Edit page - MoJ Forms'
  end

  def page_heading_title
    "#{@page.heading} - MoJ Forms"
  end

  def edit_page_title
    "Edit page - #{@page.heading} - MoJ Forms"
  end

  def component_legend_title
    "Edit page - #{@page.components.first['legend']} - MoJ Forms"
  end

  def component_label_title
    "Edit page - #{@page.components.first['label']} - MoJ Forms"
  end

  def cookies_page?
    @page['_type'] == 'page.standalone' && @page['_id'] == 'page.cookies'
  end

  def component_label_present?
    @page.components.first['label'].present?
  end

  def component_legend_present?
    @page.components.first['legend'].present?
  end
end
