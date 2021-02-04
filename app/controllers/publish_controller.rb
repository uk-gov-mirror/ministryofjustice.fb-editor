class PublishController < FormController
  def index
    @publish_service_creation = PublishServiceCreation.new
  end

  def create
    @publish_service_creation = PublishServiceCreation.new(publish_service_params)

    if @publish_service_creation.save
      PublishServiceJob.perform_later(
        publish_service_id: @publish_service_creation.publish_service_id
      )
    else
      render :index
    end
  end

  private

  def publish_service_params
    params.require(:publish_service_creation).permit(
      :require_authentication,
      :username,
      :password,
      :deployment_environment
    ).merge(service_id: service.service_id)
  end
end
