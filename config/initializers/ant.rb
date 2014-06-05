if Rails.env.development?
  ENV['ant'] = '/usr/local/Cellar/ant/1.9.4/bin/ant'
else
  ENV['ant'] = 'ant'
end

