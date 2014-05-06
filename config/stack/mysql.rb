package :mysql, :provides => :database do
  description 'MySQL Database'
  pkgs = %w( mysql-server mysql mysql-devel )

  pkgs.each do |pkg|
    runner "sudo yum install #{pkg} -y"
  end

  verify do
    has_executable 'mysql'
  end
  requires :database_yml
end

package :mysql_driver, :provides => :ruby_database_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'

  verify do
    has_gem 'mysql'
  end

  requires :mysql, :ruby, :sqlite3
end

package :database_yml do
  CONFIG = YAML::load(File.open("config/application.yml"))
  description 'Sets up database yml'

  template_search_path('config/stack/templates')

  defaults :rails_env => 'staging',
    :password => CONFIG['RAILS_DB_PASSWORD']

  file '/home/deploy/database.yml',
    :contents => render('database.yml')

  verify do
    has_file '/home/deploy/database.yml'
    file_contains '/home/deploy/database.yml', "password: #{CONFIG['RAILS_DB_PASSWORD'][:staging]}"
    file_contains '/home/deploy/database.yml', "password: #{CONFIG['RAILS_DB_PASSWORD'][:production]}"
  end
end
