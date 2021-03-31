class UserSessionsController < ApplicationController
  before_action :require_user!, except: %i[signup_not_allowed signup_error]

  def destroy
    reset_session
    flash[:success] = I18n.t(:success, scope: %i[user_sessions destroy])
    redirect_to root_path
  end

  def signup_not_allowed
    @valid_emails = Auth0UserSession::VALID_EMAIL_DOMAINS
  end

  def signup_error
    @error_type = params[:error_type]
  end
end
