Rails.application.reloader.to_prepare do
  [Publisher::MAIN, Publisher::STEPS].flatten.each do |step|
    event_name = step.include?('publisher') ? step : "publisher.#{step}"

    ActiveSupport::Notifications.subscribe(event_name) do |name, start, finish, _, _|
      duration = finish - start
      Rails.logger.info("Event '#{name}' duration: (%.3f s)" % [duration])
    end
  end
end
