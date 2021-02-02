class PublishController < FormController
  def index
    @publish_service = PublishService.new
  end

  def create
    @publish_service = PublishService.new(
      params.require(:publish_service).permit(
        :deployment_environment
      ).merge(service_id: service.service_id, status: :queued)
    )

    @publish_service.save!
    PublishServiceJob.perform_later(publish_service_id: @publish_service.id)
  end

  def presenter
    PublishServicePresenter.new(view_context)
  end
  helper_method :presenter
end
