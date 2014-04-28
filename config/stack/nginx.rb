package :nginx, :provides => :webserver do
  description 'Nginx web server.'
  REE_PATH = "/usr/local" unless defined?(REE_PATH)
  yum 'http://passenger.stealthymonkeys.com/rhel/6/passenger-release.noarch.rpm'
  requires :rpm_nginx

  verify do
    has_file "/etc/init.d/nginx"
  end

end

package :rpm_nginx do
  requires :build_essential, :bashrc
  runner 'rpm --import http://passenger.stealthymonkeys.com/RPM-GPG-KEY-stealthymonkeys.asc'

  verify do
    has_rpm 'passenger-release'
  end
end

package :passenger, :provides => :appserver do
  description 'Phusion Passenger (mod_rails)'
  version '4.0.35'
  binaries = %w(passenger-config passenger-install-nginx-module passenger-install-apache2-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test)
  yum 'nginx-passenger'

  gem 'passenger', :version => version do
    # Install nginx and the module
    binaries.each {|bin| post :install, "ln -s #{REE_PATH}/bin/#{bin} /usr/local/bin/#{bin}"}
    post :install, "sudo passenger-install-nginx-module --auto --auto-download --prefix=/usr/local/nginx"
  end

  verify do
    has_gem "passenger", version
  end

  requires :nginx, :ruby, :add_rbenv_bundler
end
