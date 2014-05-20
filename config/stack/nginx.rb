package :nginx, :provides => :webserver do
  description 'Nginx web server.'
  REE_PATH = "/usr/local" unless defined?(REE_PATH)
  requires :passenger, :ruby, :add_rbenv_bundler, :gcc_cplusplus, :log_dir

  template_search_path('config/stack/templates')

  defaults :server_name => '10.9.43.173',
    :rails_env => 'staging'


  transfer 'config/stack/server_files/nginx', '/etc/init.d/nginx', :sudo => true
  runner 'sudo chmod +x /etc/init.d/nginx'

  runner 'sudo mkdir /usr/local/nginx/sites-enabled/'
  file '/usr/local/nginx/sites-enabled/visio',
    :contents => render('visio'),
    :sudo => true


  file '/usr/local/nginx/conf/nginx.conf',
    :contents => render('nginx.conf'),
    :sudo => true

  verify do
    has_executable "/usr/local/nginx/sbin/nginx"
    has_file "/etc/init.d/nginx"
    has_file "/usr/local/nginx/sites-enabled/visio"
    has_file "/usr/local/nginx/conf/nginx.conf"
  end
end

package :passenger do
  requires :passenger_release

  description 'Phusion Passenger (mod_rails)'
  version '4.0.35'

  binaries = %w(passenger-config passenger-install-nginx-module passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test)

  passenger_nginx_cmd = "sudo -E /home/deploy/.rbenv/versions/2.0.0-p353/bin/ruby /home/deploy/.rbenv/versions/2.0.0-p353/lib/ruby/gems/2.0.0/gems/passenger-4.0.35/bin/passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx"

  gem 'passenger', :version => version do
    # Install nginx and the module
    post :install, "rbenv rehash; export http_proxy=http://proxy.unhcr.local:8080;#{passenger_nginx_cmd}"
  end
  # Use runner to install by sudo, should be part of sprinkle options though...

  verify do
    has_gem "passenger", version
  end

end

package :passenger_release do
  requires :rpm_nginx
  yum 'http://passenger.stealthymonkeys.com/rhel/6/passenger-release.noarch.rpm'
  verify do
    has_rpm 'passenger-release'
  end

end

package :rpm_nginx do
  requires :build_essential, :bashrc
  runner 'rpm --httpproxy proxy.unhcr.local --httpport 8080 --import http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc'

  # Need to come up with verifier for this
  #verify do
  #end
end

package :gcc_cplusplus do
  description 'C++ compiler'
  runner 'sudo yum install gcc-c++ -y'

  verify do
    has_yum 'gcc-c++'
  end
end

package :log_dir do
  description 'Directory for logs'

  runner 'sudo mkdir -p /var/log/nginx'

  verify do
    has_directory '/var/log/nginx'
  end
end
