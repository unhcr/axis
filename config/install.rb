# Require our stack
%w(essential nginx scm ruby mysql services node zsh).each do |r|
  require File.join('./config/stack', r)
end


# What we're installing to your server
# Take what you want, leave what you don't
# Build up your own and strip down your server until you get it right.
policy :passenger_stack, :roles => :staging do
  requires :webserver               # Nginx

  requires :ruby # Ruby Enterprise edition
  requires :database                # MySQL or Postgres
  # requires :ruby_database_driver    # mysql or postgres gems
  requires :scm                     # Git
  requires :services                # Elasticsearch, redis, etc.
  requires :js_runtime
  requires :zsh
end

deployment do
  # mechanism for deployment
  delivery :ssh do
    user 'deploy'
    role :staging, '10.9.43.173'
  end
  #delivery :capistrano do
  #  recipes 'config/deploy'
  #end
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
