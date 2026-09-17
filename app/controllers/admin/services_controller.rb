module Admin
  class ServicesController < Admin::ApplicationController
    include MetadataVersionHelper

    def index
      response = MetadataApiClient::Service.all_services(
        page:,
        per_page:,
        query: params[:search]&.strip || ''
      )

      @services = Kaminari.paginate_array(
        response[:services],
        total_count: response[:total_services]
      ).page(page).per(per_page)
    end

    def show
      load_service_and_metadata_corresponding_to_id
      @service_creator = User.find(@service.created_by)
      @version_creator = version_creator
      @published_to_live = published('production')
      @published_to_test = published('dev')
      @versions = MetadataApiClient::Version.all(@service.service_id)
    end

    def create
      original_metadata = latest_version(params[:service_id])
      duplicate_name =  "#{original_metadata['service_name']} - COPY"
      service_creation = ServiceCreation.new(
        service_name: duplicate_name,
        current_user:
      )

      if service_creation.create
        duplicate_version = AdminMetadataVersion.new(
          service: OpenStruct.new(service_id: service_creation.service_id),
          metadata: original_metadata.merge(duplicate_attributes(service_creation))
        ).create_version

        if duplicate_version
          flash[:success] = "#{service_creation.service_name} duplicate successfully created"
        else
          flash[:error] = service_creation.errors.full_messages.join("\n")
        end
      else
        flash[:error] = if name_taken?(service_creation)
                          "'#{original_metadata['service_name']}' has already been duplicated"
                        else
                          service_creation.errors.full_messages.join("\n")
                        end
      end

      redirect_to admin_services_path
    end

    def edit
      load_service_and_metadata_corresponding_to_id
      @maintenance_mode_settings = MaintenanceModeSettings.new(
        service_id: @service.service_id,
        deployment_environment: 'production'
      )
    end

    def update
      load_service_and_metadata_corresponding_to_id
      @maintenance_mode_settings = MaintenanceModeSettings.new(
        maintenance_mode_params.merge(service_id: @service.service_id, deployment_environment: 'production')
      )

      if @maintenance_mode_settings.valid?
        MaintenanceModeSettingsUpdater.new(
          settings: @maintenance_mode_settings,
          service_id: @service.service_id
        ).create_or_update!

        redirect_to admin_services_path
      else
        render action: 'edit'
      end
    end

    def unpublish
      if queued?
        flash[:notice] = "Already queued for unpublishing from #{params[:deployment_environment]}"
      else
        publish_service = PublishService.find(params[:publish_service_id])
        version_metadata = get_version_metadata(publish_service)
        publish_service_creation = PublishServiceCreation.new(
          service_id: publish_service.service_id,
          version_id: version_metadata['version_id'],
          deployment_environment: params[:deployment_environment],
          user_id: current_user.id
        )
        if publish_service_creation.save
          UnpublishServiceJob.perform_later(
            publish_service_id: publish_service_creation.publish_service_id,
            service_slug: service_slug(publish_service.service_id, version_metadata)
          )
          flash[:success] = "Service queued for unpublishing from #{params[:deployment_environment]}. Refresh in a minute"
        else
          flash[:error] = @publish_service_creation.errors.full_messages.join("\n")
        end
      end

      service_id = publish_service&.service_id || params[:service_id]
      redirect_to admin_service_path(service_id)
    end

    def republish
      if queued?
        flash[:notice] = "Already queued for republishing from #{params[:deployment_environment]}"
      else
        publish_service = PublishService.find(params[:publish_service_id])
        version_metadata = get_version_metadata(publish_service)
        publish_service_creation = PublishServiceCreation.new(
          service_id: publish_service.service_id,
          version_id: version_metadata['version_id'],
          user_id: current_user.id,
          deployment_environment: params[:deployment_environment],
          require_authentication:,
          username:,
          password:
        )
        if publish_service_creation.save
          PublishServiceJob.perform_later(
            publish_service_id: publish_service_creation.publish_service_id
          )
          flash[:success] = "Service queued for re-publishing to #{params[:deployment_environment]}. Re-publishing version: #{version_metadata['version_id']}. Refresh in a minute"
        else
          flash[:error] = @publish_service_creation.errors.full_messages.join("\n")
        end
      end

      service_id = publish_service&.service_id || params[:service_id]
      redirect_to admin_service_path(service_id)
    end

    def approve
      service_id = params[:service_id]
      approval = ServiceConfiguration.find_or_initialize_by(
        service_id:,
        deployment_environment: 'production',
        name: 'APPROVED_TO_GO_LIVE'
      )
      revoke = ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'production',
        name: 'REVOKED'
      )
      awaiting = ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'production',
        name: 'AWAITING_APPROVAL'
      )

      if approval.new_record?
        # have to give it a value to save, but can't find by the value as it will be encrypted
        approval.value = '1'
        approval.save!
      end
      revoke&.delete
      awaiting&.delete

      if unpublish_review_service(service_id)
        flash[:success] = 'Service approved for go live - queueing for unpublish'
      else
        flash[:error] = 'Issue with saving record or queueing service for unpublish'
      end

      redirect_to admin_service_path(service_id)
    end

    def revoke_approval
      service_id = params[:service_id]
      approval = ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'production',
        name: 'APPROVED_TO_GO_LIVE'
      )
      revoke = ServiceConfiguration.find_or_initialize_by(
        service_id:,
        deployment_environment: 'production',
        name: 'REVOKED'
      )
      awaiting = ServiceConfiguration.find_by(
        service_id:,
        deployment_environment: 'production',
        name: 'AWAITING_APPROVAL'
      )

      if revoke.new_record?
        # have to give it a value to save, but can't find by the value as it will be encrypted
        revoke.value = '1'
        revoke.save!
      end
      approval&.delete
      awaiting&.delete

      if unpublish_review_service(service_id)
        flash[:success] = 'Service requires changes - queueing for unpublish'
      else
        flash[:error] = 'Issue with saving record or queueing service for unpublish'
      end
      redirect_to admin_service_path(service_id)
    end

    def unpublish_review_service(service_id)
      if review_service_queued?(service_id)
        true
      else
        publish_service = PublishService.find_by(service_id:)
        version_metadata = get_version_metadata(publish_service)
        publish_service_creation = PublishServiceCreation.new(
          service_id: publish_service.service_id,
          version_id: version_metadata['version_id'],
          deployment_environment: 'production',
          user_id: current_user.id
        )
        if publish_service_creation.save
          UnpublishServiceJob.perform_later(
            publish_service_id: publish_service_creation.publish_service_id,
            service_slug: service_slug(publish_service.service_id, version_metadata)
          )
          true
        else
          false
        end
      end
    end

    def is_already_approved?
      ServiceConfiguration.find_by(
        service_id: params[:id],
        deployment_environment: 'production',
        name: 'APPROVED_TO_GO_LIVE'
      ).present?
    end
    helper_method :is_already_approved?

    def search_term
      params[:search] || ''
    end
    helper_method :search_term

    def destroy
      service_id = params[:id]
      load_service_and_metadata_corresponding_to_id
      if has_ever_been_live?
        flash[:error] = 'We cannot delete a form that has ever been live'
        redirect_to admin_service_path(service_id)
      elsif unpublished?('dev') || Rails.env.development?
        MetadataApiClient::Service.delete(service_id)
        ServiceConfiguration.where(service_id:).destroy_all
        SubmissionSetting.where(service_id:).destroy_all
        PublishService.where(service_id:).destroy_all
        message = "Service #{service_id} has been deleted"
        flash[:success] = message
        NotificationService.notify(message, webhook:) if webhook.present?
        redirect_to admin_services_path
      else
        flash[:error] = 'Please unpublish before deleting a service'
        redirect_to admin_service_path(service_id)
      end
    end

    private

    def version_creator
      if @service_creator.id == @latest_metadata['created_by']
        @service_creator
      else
        User.find(@latest_metadata['created_by'])
      end
    end

    def published(environment)
      return {} if unpublished?(environment)

      publish_service = PublishService.where(
        service_id: @service.service_id,
        deployment_environment: environment
      ).completed.desc.first

      return {} if publish_service.nil?

      {
        id: publish_service.id,
        published_by: published_by(publish_service.user_id)&.name,
        created_at: publish_service.created_at,
        version_id: publish_service.version_id
      }
    end

    def published_by(user_id)
      return @service_creator if user_id == @service_creator&.id

      return @version_creator if user_id == @version_creator&.id

      User.find_by(id: user_id)
    end

    def duplicate_attributes(service_creation)
      {
        'service_name' => service_creation.service_name,
        'service_id' => service_creation.service_id,
        'created_by' => current_user.id
      }
    end

    def name_taken?(service_creation)
      service_creation.errors.first.type == :taken
    end

    def page
      params[:page] || 1
    end

    def per_page
      params[:per_page] || 20
    end

    def queued?
      publish_service = PublishService.where(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment]
      ).last
      publish_service.queued? || publish_service.unpublishing?
    end

    def review_service_queued?(service_id)
      publish_service = PublishService.where(
        service_id:,
        deployment_environment: 'production'
      ).last

      return true if publish_service.nil?

      publish_service.queued? || publish_service.unpublishing?
    end

    def unpublished?(environment)
      PublishService.where(
        service_id: @service.service_id,
        deployment_environment: environment
      ).last&.unpublished?
    end

    def maintenance_mode_params
      params.require(:maintenance_mode_settings).permit(
        :maintenance_mode,
        :maintenance_page_heading,
        :maintenance_page_content
      )
    end

    def username
      @username ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment],
        name: 'BASIC_AUTH_USER'
      )&.decrypt_value
    end

    def password
      @password ||= ServiceConfiguration.find_by(
        service_id: params[:service_id],
        deployment_environment: params[:deployment_environment],
        name: 'BASIC_AUTH_PASS'
      )&.decrypt_value
    end

    def require_authentication
      password.present? && username.present? ? '1' : '0'
    end

    def service_slug_config(service_id)
      ServiceConfiguration.find_by(
        service_id:,
        name: 'SERVICE_SLUG',
        deployment_environment: 'dev'
      )&.decrypt_value
    end

    def service_slug_from_name(version_metadata)
      service = MetadataPresenter::Service.new(version_metadata, editor: true)
      service.service_slug
    end

    def service_slug(service_id, version_metadata)
      service_slug_config(service_id).presence || service_slug_from_name(version_metadata)
    end

    def load_service_and_metadata_corresponding_to_id
      service_id = params[:id]
      @latest_metadata = MetadataApiClient::Service.latest_version(service_id)
      @service = MetadataPresenter::Service.new(@latest_metadata, editor: true)
    end

    def webhook
      ENV['SLACK_NOTIFICATION_WEBHOOK']
    end

    def has_ever_been_live?
      PublishService.exists?(service_id: @service.service_id, deployment_environment: 'production')
    end
  end
end
