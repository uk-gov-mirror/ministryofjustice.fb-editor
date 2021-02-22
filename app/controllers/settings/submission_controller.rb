class Settings::SubmissionController < FormController
  def index
    @settings = Settings.new(service_name: service.service_name)
  end
end
