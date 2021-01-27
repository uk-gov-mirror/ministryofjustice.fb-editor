class SettingsController < FormController
  def form_information
    @settings = Settings.new(service_name: service.service_name)
  end

  def update_form_information
    @settings = Settings.new(service_params)

    if @settings.update
      redirect_to form_information_settings_path(service.service_id)
    else
      render :form_information
    end
  end

  private

  def service_params
    params.require(:service).permit(:service_name).merge(
      service_id: service.service_id,
      latest_metadata: service.to_h
    )
  end
end
