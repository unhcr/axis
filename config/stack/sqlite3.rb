package :sqlite3, :provides => :database do
  description 'MySQL Database'
  yum %w( sqlite3-devel )

  verify do
    has_executable 'sqlite3'
  end
end
