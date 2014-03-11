# Use this file to easily define all of your cron jobs.

set :output, "./log/cron.log"
env :PATH, '$HOME/.rbenv/bin:$PATH'
env :http_proxy, 'http://proxy.unhcr.local:8080'
env :https_proxy, 'https://proxy.unhcr.local:8080'

every :day, :at => '4:30 am' do
  rake 'build:focus'
  rake 'build:countries'
  rake 'build:msrp'
end
