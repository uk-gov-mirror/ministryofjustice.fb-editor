module Admin
  class PublishServicesController < Admin::ApplicationController
    ENVIRONMENTS = %w[production dev].freeze
    PER_PAGE = 20

    def index
      @environment = requested_environment
      @publish_services = Kaminari.paginate_array(current_state).page(params[:page]).per(PER_PAGE)
    end

    private

    def requested_environment
      ENVIRONMENTS.include?(params[:deployment_environment]) ? params[:deployment_environment] : 'production'
    end

    def current_state
      PublishService.where(deployment_environment: @environment)
                    .order(created_at: :desc)
                    .group_by(&:service_id)
                    .map { |_service_id, publishes| publishes.first }
    end
  end
end
