# Require our stack
%w(essential nginx scm ruby mysql).each do |r|
  require File.join('./config/stack', r)
end

# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right.
policy :passenger_stack, :roles => :app do
  requires :webserver               # Nginx

  requires :appserver               # Passenger
  requires :ruby # Ruby Enterprise edition
  requires :database                # MySQL or Postgres
  # requires :ruby_database_driver    # mysql or postgres gems
  requires :scm                     # Git
end

deployment do
  # mechanism for deployment
  delivery :ssh do
    user 'deploy'
    role :app, '10.9.43.173'
  end

  # source based package installer defaults
  source do
    prefix   '/usr/local'
    archives '/usr/local/sources'
    builds   '/usr/local/build'
  end
end

# Depend on a specific version of sprinkle
begin
  gem 'sprinkle', ">= 0.2.1"
rescue Gem::LoadError
  puts "sprinkle 0.2.1 required.\n Run: `sudo gem install sprinkle`"
  exit
end
