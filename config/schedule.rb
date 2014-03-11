# Use this file to easily define all of your cron jobs.

set :output, "./log/cron.log"

every :day, :at => '4:30 am' do
  command 'source ~/.bashrc'
  rake 'build:focus'
  rake 'build:countries'
  rake 'build:msrp'
end
