# Use this file to easily define all of your cron jobs.

set :output, "./logs/cron.log"

every :day, :at => '4:30 am' do
  rake 'build:focus'
  rake 'build:countries'
  rake 'build:msrp'
end
