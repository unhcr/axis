# Use this file to easily define all of your cron jobs.
#
job_type :rake_env, "source ~/.cronrc; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"

set :output, "./log/cron.log"

every :day, :at => '11 pm' do
  rake_env 'build:focus'
  rake_env 'build:countries'
  rake_env 'build:msrp'
end
