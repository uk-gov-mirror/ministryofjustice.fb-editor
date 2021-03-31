class PublishServicePresenter
  include ::Publisher::Utils::Hostname
  attr_reader :view, :publish_service

  delegate :deployment_environment, to: :publish_service

  def self.hostname_for(deployment_environment:, view:)
    publish_service = completed_published_service(
      service_id: view.service.service_id,
      deployment_environment: deployment_environment
    )

    if publish_service.present?
      host = new(publish_service, view: view).hostname
      view.link_to host, "https://#{host}", target: '_blank', class: 'govuk-link', rel: 'noopener'
    end
  end

  def self.completed_published_service(service_id:, deployment_environment:)
    PublishService.completed.where(
      deployment_environment: deployment_environment,
      service_id: service_id
    ).desc.first
  end

  def initialize(publish_service, view:)
    @publish_service = publish_service
    @view = view
  end

  def service_slug
    view.service.service_slug
  end
end
