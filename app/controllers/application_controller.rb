class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery

  before_filter :common, :only => [:index, :operation, :overview, :indicator]

  @@map = File.read("#{Rails.root}/public/world_50m_topo.json")
  @@mapMD5 = Digest::MD5.hexdigest(@@map)

  def index
    @mapMD5 = @@mapMD5
    render :layout => 'index'
  end

  def map
    render :json => @@map
  end

  def splash
    @stats = [
      {
        :name => 'Number of Global Strategies',
        :value => Strategy.global_strategies.count
      },
      {
        :name => 'Number of UNHCR Operations',
        :value => Operation.count
      },
      {
        :name => 'Number of Axis users',
        :value => User.count
      },
      {
        :name => 'Number of smiles?',
        :value => '∞'
      }
    ]
    render :layout => 'splash'
  end

  def create_guest_user
    render_403 and return unless current_user.admin

    user = User.where(:login => ENV['GUEST_USER']).first

    user = User.create(:login => ENV['GUEST_USER']) unless user

    render :json => user.to_json
  end

  def indicator
    @indicator = Indicator.find params[:indicator_id]
    @dashboard = nil
    if @indicator.is_performance
      @dashboard = @indicator.outputs.first
    else
      @dashboard = @indicator.problem_objectives.first
    end
    render :layout => 'dashboard'
  end

  def operation
    @dashboard = Operation.find params[:operation_id]
    render :layout => 'dashboard'
  end

  def overview
    @dashboard = Strategy.find(params[:strategy_id])
    render :layout => 'dashboard'
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
      :ldap => up?(ldap_config['host'], ldap_config['port']),
      :elasticsearch => up?('localhost', 9200),
      :phantomjs => service?('phantomjs'),
      :ant => service?('ant')
    }

    render :layout => 'application'
  end

  def reset_local_db
    User.reset_local_db(User.all)
    render :json => { :success => true }
  end

  def render_403
     respond_to do |format|
      format.html do
        render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
      end
      format.json do
        render :json =>
          { :error => true, :message => "Error 403, you don't have permissions for this operation." }
      end
     end
  end

  def common
    redirect_to :splash and return unless user_signed_in?
    @configuration = AdminConfiguration.first
    @mapMD5 = @@mapMD5
    @options = {
      :include => {
        :ids => true,
        :shared_users => true
      }
    }

    @strategies ||= Strategy.global_strategies.as_json
    @personal_strategies ||= current_user.strategies.as_json
    @shared_strategies ||= current_user.shared_strategies.as_json
  end

  protected
    def sanitize_query(str)
      # Escape special characters
      escaped_characters = Regexp.escape('\\+-&|!(){}[]^~*?:\/')
      str = str.gsub(/([#{escaped_characters}])/, ' ')
      str = str.sub('"', '')

      str
    end

  private
    def up?(server, port)
      cmd = `nc -v -z -w 2 #{server} #{port}`
      $?.exitstatus == 0
    end

    def service?(service)
      cmd = `which #{service}`
      $?.exitstatus == 0
    end
end
