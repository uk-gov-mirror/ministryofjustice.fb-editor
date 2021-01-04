class ApplicationController < ActionController::Base
  include Auth0Helper

  def service
    @service ||= MetadataPresenter::Service.new(service_metadata)
  end

  def save_user_data
    return {} if params[:answers].blank? || params[:service_id].blank?

    service_id = params[:service_id]
    session[service_id] ||= {}
    session[service_id]['user_data'] ||= {}

    params[:answers].each do |field, answer|
      session[service_id]['user_data'][field] = answer
    end
  end

  def load_user_data
    user_data = session[params[:service_id]] || {}

    user_data['user_data'] || {}
  end

  private

  def service_metadata
    JSON.parse(File.read(Rails.root.join('service.json')))
  end
end
