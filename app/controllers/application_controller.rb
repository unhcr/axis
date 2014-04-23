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
    redirect_to :splash and return unless user_signed_in?
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

  def healthz
    resque_up = true
    begin
      workers = Resque.workers
    rescue
      workers = []
      resque_up = false
    end

    ldap_config = YAML.load(ERB.new(File.read(::Devise.ldap_config || "#{Rails.root}/config/ldap.yml")).result)[Rails.env]
    @checks = {
      :resque => resque_up,
      :resque_workers => workers.length,
      :database_connected => ActiveRecord::Base.connected?,
      :ldap => up?("#{ldap_config['host']}:#{ldap_config['port']}")
    }

    render :layout => 'application'
  end

  def reset_local_db
    User.reset_local_db(User.all)
    render :json => { :success => true }
  end

  private
    def up?(server)
      cmd = `ping -c -q  2 #{server}`
      $?.exitstatus == 0
    end
end
