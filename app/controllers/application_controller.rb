class ApplicationController < ActionController::Base
  protect_from_forgery

  @@world = File.read("#{Rails.root}/public/world_50m.json")
  @@world_MD5 = Digest::MD5.hexdigest(@@world)

  def index
    redirect_to :splash and return unless user_signed_in?
    @world_MD5 = @@world_MD5
    render :layout => 'index'
  end

  def map
    render :json => @@world
  end

  def splash
    render :layout => 'application' and return
  end

end
