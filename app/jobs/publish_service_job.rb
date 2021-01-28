class PublishServiceJob < ApplicationJob
  queue_as :default

  def perform(publish_service_id:)
  end
end
