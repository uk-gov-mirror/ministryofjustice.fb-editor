class ServicesController < ApplicationController
  before_action :require_user!

  def index
    @services = MetadataApiClient::Service.all(user_id: current_user.id)
  end
end
