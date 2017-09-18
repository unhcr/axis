if Rails.env.development?
  # ENV['ant'] = '/usr/local/Cellar/ant/1.9.4/bin/ant'
  ENV['ant'] = 'ant' # Works with ant version 1.10.1
else
  ENV['ant'] = 'ant'
end
