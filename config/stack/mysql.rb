package :mysql, :provides => :database do
  description 'MySQL Database'
  yum %w( mysql-server mysql mysql-devel )

  verify do
    has_executable 'mysql'
  end
end

package :mysql_driver, :provides => :ruby_database_driver do
  description 'Ruby MySQL database driver'
  gem 'mysql'

  verify do
    has_gem 'mysql'
  end

  requires :mysql, :ruby
end
