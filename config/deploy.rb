require 'bundler/capistrano'
require "capistrano-rbenv"
set :rbenv_ruby_version, "1.9.3-p484"
set :rbenv_repository, "https://github.com/sstephenson/rbenv.git"

set :application, "visio"


load 'deploy/assets'

# Deploy from your local Git repo by cloning and uploading a tarball
set :scm, :git
set :repository,  "git@github.com:unhcr/visio.git"
require '/Users/benrudolph/Dropbox/credientials/capcreds-unhcr.rb'
set :deploy_via, :copy
set :branch, "master"
set :rails_env,     "production"


set :user, :deploy
set :deploy_to, "/var/www/#{application}"
set :use_sudo, false

set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true

role :web, "10.9.43.153"                          # Your HTTP server, Apache/etc
role :app, "10.9.43.153"                          # This may be the same as your `Web` server
role :db,  "10.9.43.153", :primary => true # This is where Rails migrations will run

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
  run "wget www.google.com"
end

