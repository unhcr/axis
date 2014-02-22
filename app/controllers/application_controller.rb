class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery

  @@map = File.read("#{Rails.root}/public/world_50m_topo.json")
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

  def global_search
    query = ''
    if params[:query] && !params[:query].empty?
      query = "*#{params[:query].split('').join('*')}*"
    end

    render :json => {
      :indicators => Indicator.search_models(query),
      :operations => Operation.search_models(query)
    }
  end

  def algorithms
    render :layout => 'application'
  end
end
