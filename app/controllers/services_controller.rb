class ServicesController < ApplicationController
  # before_action :require_user!

  def index
    @service_creation = ServiceCreation.new
  end

  def create
  end

  def edit
    @page_creation = PageCreation.new
  end

  def services
    @services ||= MetadataApiClient::Service.all(user_id: '1234')
  end
  helper_method :services

  private

  def service_creation_params
    params.require(
      :service_creation
    ).permit(:service_name).merge(current_user: current_user)
  end
end
