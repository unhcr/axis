require 'bundler/capistrano'
require "capistrano-rbenv"
require "whenever/capistrano"
require "capistrano-resque"
load 'config/deploy/recipes/redis'

#set :whenever_command, 'bundle exec whenever'
#set :whenever_environment, defer { rails_env }
#require 'whenever/capistrano'
load 'deploy/assets'
set :rbenv_ruby_version, "2.0.0-p353"
set :rbenv_repository, "https://github.com/sstephenson/rbenv.git"
set :bundle_flags, "--deployment --quiet --binstubs"

set :application, "visio"



# Deploy from your local Git repo by cloning and uploading a tarball
set :scm, :none
set :repository, "."
set :local_repository, "."
require './config/capistrano_credentials.rb'
set :deploy_via, :copy
set :branch, "master"
set :rails_env,     "production"


set :user, :deploy
set :deploy_to, "/var/www/#{application}"
set :use_sudo, false
set :sudo_user, "resque_worker"

set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true

role :web, "10.9.43.153"                          # Your HTTP server, Apache/etc
role :app, "10.9.43.153"                          # This may be the same as your `Web` server
role :db,  "10.9.43.153", :primary => true # This is where Rails migrations will run
role :resque_worker, "10.9.43.153"

set :workers, { "shrimp" => 5 }

# ensure http_proxy variables are set
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH",
  'BASH_ENV' => '$HOME/.bashrc',
  'https_proxy' => 'https://proxy.unhcr.local:8080',
  'http_proxy' => 'http://proxy.unhcr.local:8080'
}

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

task :query_interactive do
  run "[[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'"
end

task :query_login do
  run "shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'"
end

namespace :db do
  task :config, :except => { :no_release => true }, :role => :app do
    run "cp -f ~/database.yml #{release_path}/config/database.yml"
  end
end
after "deploy:finalize_update", "db:config"
after "deploy", "deploy:migrate"
after "deploy", "whenever:clear_crontab"
after "deploy", "redis:stop"
after "deploy", "redis:start"
after "deploy", "resque:restart"
after "whenever:clear_crontab", "whenever:update_crontab"

