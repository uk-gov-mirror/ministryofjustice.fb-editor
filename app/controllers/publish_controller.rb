class PublishController < FormController
  before_action :assign_form_objects

  ACCEPTANCE_TESTS_EMAIL = 'fb-acceptance-tests@digital.justice.gov.uk'.freeze

  def index
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
    declarations
  end

  def create
    return unless authorised_to_publish?

    @publish_service_creation = PublishServiceCreation.new(publish_service_params)

    return attach_ms_list_error unless prepare_ms_list_integration(publish_service_params[:deployment_environment])

    if @publish_service_creation.save
      if previous_service_slug.present?
        unpublish_previous_version
      end

      PublishServiceJob.perform_later(
        publish_service_id: @publish_service_creation.publish_service_id
      )

      notify_of_publish

      redirect_to publish_index_path(service.service_id)
    else
      update_form_objects
      render :index
    end
  end

  def publish_for_review
    declarations
    declarations.checked(publish_for_review_params['declarations_checkboxes'].reject(&:blank?))

    @publish_service_creation = PublishServiceCreation.new(publish_for_review_params.except('authenticity_token', 'declarations_checkboxes'))

    unless @declarations.valid?
      update_form_objects
      render :index, status: :unprocessable_entity and return
    end

    return attach_ms_list_error unless prepare_ms_list_integration('production')

    if @publish_service_creation.valid?
      if @publish_service_creation.save
        # not sure if it should ever be present
        if previous_service_slug.present?
          unpublish_previous_version
        end

        queue_publish_and_notify_review unless current_user.email == ACCEPTANCE_TESTS_EMAIL

        create_awaiting_approval_record
      end

      update_form_objects
      redirect_to "#{publish_index_path(service.service_id)}#publish-to-live" and return
    end
  end

  def can_publish_to_live
    if revoked?
      false
    elsif approved_to_go_live?
      true
    elsif awaiting_approval?
      false
    else
      previously_published_to_production?
    end
  end
  helper_method :can_publish_to_live

  def show_confirmation?
    awaiting_approval?
  end
  helper_method :show_confirmation?

  def text_for_environment(env)
    env == 'dev' ? 'Test' : 'Live'
  end
  helper_method :text_for_environment

  def form_url(env)
    "https://#{hostname(env)}"
  end
  helper_method :form_url

  def prepare_ms_list_integration(env)
    ms_site_id_config = ms_site_id_configuration(env)

    return true if skip_ms_list_integration?(ms_site_id_config, env)

    latest = latest_publish_for(env)

    return true unless latest&.published?
    return true if latest.version_id == service.version_id

    created = create_ms_list_and_drive(ms_site_id_config.decrypt_value, service, env)
    notify_list_created(env) if created
    created
  end

  def create_ms_list_and_drive(site_id, service, env)
    adapter = MicrosoftGraphAdapter.new(site_id:, service:, env:)

    list_response = adapter.post_list_columns

    list_created = false
    drive_created = false

    list_created = store_ms_resource_id(list_response, 'MS_LIST_ID', env) if list_response.status == 201

    drive_response = adapter.create_drive(ms_drive_name(service, env))

    drive_created = store_ms_resource_id(drive_response, 'MS_DRIVE_ID', env) if drive_response.status == 201

    list_created && drive_created
  end

  private

  def create_or_update_the_service_configuration(config, env)
    find_or_initialize_setting(config, env)
  end

  def find_or_initialize_setting(config, env)
    ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: env,
      name: config
    )
  end

  def hostname(env)
    root_url = Rails.application.config
      .platform_environments[platform_environment][:url_root]

    if env == 'production'
      [service_slug, '.', root_url].join
    else
      [service_slug, '.', 'dev', '.', root_url].join
    end
  end

  def platform_environment
    ENV['PLATFORM_ENV']
  end

  def service_autocomplete_items
    @service_autocomplete_items ||= MetadataApiClient::Items.all(service_id: service.service_id)
  end

  def publish_service_params
    params.require(:publish_service_creation).permit(
      :require_authentication,
      :username,
      :password,
      :deployment_environment
    ).merge(
      service_id: service.service_id,
      user_id: current_user.id,
      version_id: service.version_id
    )
  end

  def publish_for_review_params
    params.require(:publish_for_review_declarations).permit(
      :authenticity_token,
      declarations_checkboxes: []
    ).merge(
      require_authentication: '1',
      username: ENV['PUBLISH_FOR_REVIEW_USERNAME'],
      password: ENV['PUBLISH_FOR_REVIEW_PASSWORD'],
      deployment_environment: 'production',
      service_id: service.service_id,
      user_id: current_user.id,
      version_id: service.version_id
    )
  end

  def review_message
    if platform_environment == 'test'
      "#{service.service_name} has been published for review *in the test environment* by #{current_user.email} using the review credentials.\n#{hostname('production')}"
    else
      "#{service.service_name} has been published for review by #{current_user.email} using the review credentials.\n#{hostname('production')}"
    end
  end

  def publish_message
    "#{service.service_name} has been published to live by #{current_user.email}"
  end

  def assign_form_objects
    @publish_page_presenter_dev = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'dev',
      service_autocomplete_items:,
      grid:
    )
    @publish_page_presenter_production = PublishingPagePresenter.new(
      service:,
      deployment_environment: 'production',
      service_autocomplete_items:,
      grid:
    )
  end

  def publishes_dev
    @publishes_dev ||= PublishService.where(
      service_id: service.service_id
    ).dev
  end

  def publishes_production
    @publishes_production ||= PublishService.where(
      service_id: service.service_id
    ).production
  end

  def update_form_objects
    @published_dev = PublishServicePresenter.new(publishes_dev, service)
    @published_production = PublishServicePresenter.new(publishes_production, service)
    if @publish_service_creation.deployment_environment == 'dev'
      @publish_page_presenter_dev.publish_creation = @publish_service_creation
    else
      @publish_page_presenter_production.publish_creation = @publish_service_creation
    end
    declarations
  end

  def declarations
    @declarations ||= PublishForReviewDeclarations.new
  end

  def published_service
    PublishService.where(
      service_id: service.service_id,
      deployment_environment: 'dev'
    ).completed.desc.first
  end

  def previous_service_slug
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end

  def all_previous_service_slugs
    ServiceConfiguration.where(
      service_id: service.service_id,
      name: 'PREVIOUS_SERVICE_SLUG'
    )
  end

  def page_title
    "Publishing - #{service.service_name} - MoJ Forms"
  end
  helper_method :page_title

  def attach_ms_list_error
    @publish_service_creation.errors.add(:ms_list, message: 'We were unable to create a new Microsoft List. Your form changes have not been published. Contact us to resolve this issue.')
    update_form_objects
    render :index, status: :unprocessable_entity
  end

  def unpublish_previous_version
    UnpublishServiceJob.perform_later(
      publish_service_id: published_service.id,
      service_slug: previous_service_slug.decrypt_value
    )
    all_previous_service_slugs.destroy_all
  end

  def authorised_to_publish?
    can_publish_to_live || publish_service_params[:deployment_environment] == 'dev'
  end

  def queue_publish_and_notify_review
    PublishServiceJob.perform_later(
      publish_service_id: @publish_service_creation.publish_service_id
    )
    NotificationService.notify(review_message, webhook: ENV['SLACK_NOTIFICATION_WEBHOOK'])
  end

  def notify_of_publish
    return if current_user.email == ACCEPTANCE_TESTS_EMAIL
    return unless publish_service_params[:deployment_environment] == 'production'

    NotificationService.notify(publish_message, webhook: ENV['SLACK_NOTIFICATION_WEBHOOK'])
  end

  def create_awaiting_approval_record
    approval = ServiceConfiguration.find_or_initialize_by(
      service_id: service.service_id,
      deployment_environment: 'production',
      name: 'AWAITING_APPROVAL'
    )
    if approval.new_record?
      approval.value = '1'
      approval.save
    end
  end

  def service_configuration_exists?(name)
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      name:
    ).present?
  end

  def revoked?
    service_configuration_exists?('REVOKED')
  end

  def approved_to_go_live?
    service_configuration_exists?('APPROVED_TO_GO_LIVE')
  end

  def awaiting_approval?
    service_configuration_exists?('AWAITING_APPROVAL')
  end

  def ms_site_id_configuration(env)
    ServiceConfiguration.find_by(
      service_id: service.service_id,
      deployment_environment: env,
      name: 'MS_SITE_ID'
    )
  end

  def skip_ms_list_integration?(ms_site_id_config, env)
    return true if ms_site_id_config.nil?

    send_to_graph = SubmissionSetting.find_by(
      service_id: service.service_id,
      deployment_environment: env
    ).try(:send_to_graph_api?)

    send_to_graph == false
  end

  def previously_published_to_production?
    PublishService.find_by(
      service_id: service.service_id,
      deployment_environment: 'production'
    ).present?
  end

  def latest_publish_for(env)
    if env == 'dev'
      publishes_dev&.last
    else
      publishes_production&.last
    end
  end

  def notify_list_created(env)
    NewListMailer.new_ms_list_created(
      user: current_user,
      form_name: service.service_name,
      list_name: "#{service.service_name}-#{text_for_environment(env).downcase}-#{service.version_id}",
      drive_name: "#{service.service_name}-#{text_for_environment(env).downcase}-#{service.version_id}-attachments"
    ).deliver_later
  end

  def store_ms_resource_id(response, config_name, env)
    service_config = create_or_update_the_service_configuration(config_name, env)
    service_config.value = JSON.parse(response.body)['id']
    service_config.save!
  end

  def ms_drive_name(service, env)
    CGI.escape("#{service.service_name}-#{text_for_environment(env).downcase}-#{service.version_id}-attachments")
  end
end
