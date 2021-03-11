class PermissionsController < ApplicationController
  before_action :require_user!
end
