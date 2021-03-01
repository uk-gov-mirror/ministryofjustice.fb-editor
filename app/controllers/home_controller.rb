class HomeController < ApplicationController
  def show
    redirect_to services_path if user_signed_in?

    if Rails.env.development?
      @sign_in_url = '/auth/developer'
    else
      @sign_in_url = '/auth/auth0'
    end
  end
end
