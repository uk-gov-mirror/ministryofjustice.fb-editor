class Publisher
  include ActiveModel::Model
  attr_accessor :publish_service, :service_provisioner, :adapter

  MAIN = 'publisher.main'.freeze
  STEPS = %w(
    pre_publishing
    publishing
    post_publishing
    completed
  ).freeze

  def call(steps: STEPS)
    ActiveSupport::Notifications.instrument(MAIN) do
      steps.each do |step|
        action[step]
      end
    end
  end

  def action
    lambda do |action_name|
      ActiveSupport::Notifications.instrument("publisher.#{action_name}") do
        publish_service.update!(status: action_name)
        adapter.new(service_provisioner).method(action_name).call
      end
    end.curry
  end
end
