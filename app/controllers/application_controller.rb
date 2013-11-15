class ApplicationController < ActionController::Base
  protect_from_forgery

  @@world = File.read("#{Rails.root}/public/world_50m.json")

  def index
    redirect_to :splash unless user_signed_in?
    @world = @@world
    render :layout => 'index'
  end

  def splash
    render :layout => 'application'
  end

end
