# Use this file to easily define all of your cron jobs.
#
job_type :rake_env, "source ~/.cronrc; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"

set :output, "./log/cron.log"

every 3.day, :at => '11 pm' do
  rake_env 'build'
end
