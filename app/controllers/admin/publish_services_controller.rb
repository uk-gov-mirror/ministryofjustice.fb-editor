module Admin
  class PublishServicesController < Admin::ApplicationController
    ENVIRONMENTS = %w[production dev].freeze
    PER_PAGE = 20

    def index
      @environment = requested_environment
      @publish_services = current_state_scope.page(params[:page]).per(PER_PAGE)
    end

    def default_sorting_attribute
      :created_at
    end

    def default_sorting_direction
      :desc
    end

    private

    def requested_environment
      ENVIRONMENTS.include?(params[:deployment_environment]) ? params[:deployment_environment] : 'production'
    end

    def current_state_scope
      latest_ids = PublishService
        .where(deployment_environment: @environment)
        .select('DISTINCT ON (service_id) id')
        .order('service_id, created_at DESC')
        .map(&:id)

      PublishService.where(id: latest_ids).order(created_at: :desc)
    end
  end
end
