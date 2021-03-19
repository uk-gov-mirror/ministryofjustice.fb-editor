class ApplicationController < ActionController::Base
  include Auth0Helper

  def service
    @service ||= MetadataPresenter::Service.new(service_metadata, editor: editable?)
  end
  helper_method :service

  def editable?
    !request.script_name.include?('preview')
  end
  helper_method :editable?

  def back_link
  end
  helper_method :back_link

  def save_user_data
    return {} if params[:answers].blank? || params[:id].blank?

    service_id = params[:id]
    session[service_id] ||= {}
    session[service_id]['user_data'] ||= {}

    params[:answers].each do |field, answer|
      session[service_id]['user_data'][field] = answer
    end
  end

  def load_user_data
    user_data = session[params[:id]] || {}

    user_data['user_data'] || {}
  end

  def service_metadata
    @service_metadata ||= MetadataApiClient::Service.latest_version(params[:id])
  end

  def user_name
    if current_user
      current_user.name.split(' ').tap do |full_name|
        return "#{full_name.first[0]}. #{full_name.last}"
      end
    end
  end
  helper_method :user_name
end
