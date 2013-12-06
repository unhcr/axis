class ApplicationController < ActionController::Base
  protect_from_forgery

  @@map = File.read("#{Rails.root}/public/world_50m.json")
  @@mapMD5 = Digest::MD5.hexdigest(@@map)

  def index
    redirect_to :splash and return unless user_signed_in?
    @mapMD5 = @@mapMD5
    options = {
      :include => {
        :ids => true
      }
    }
    @strategies = Strategy.all.as_json(options)
    render :layout => 'index'
  end

  # Used for testing
  def mapMD5
    render :json => { :mapMD5 => @@mapMD5 }

  end

  def map
    render :json => @@map
  end

  def splash
    render :layout => 'application' and return
  end

  def overview
    options = {
      :include => {
        :ids => true
      }
    }
    @strategies ||= Strategy.all.as_json(options)
    @strategy ||= Strategy.find(params[:strategy_id])
    render :layout => 'index'
  end
end
