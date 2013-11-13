class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    redirect_to :navigation if user_signed_in?
  end

  def navigation
  end
end
