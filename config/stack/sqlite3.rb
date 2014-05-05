package :sqlite3 do
  description 'MySQL Database'
  pkgs = %w( sqlite-devel sqlite3-devel )

  pkgs.each do |pkg|
    runner "sudo yum install #{pkg} -y"
  end
  verify do
    has_executable 'sqlite3'
    has_yum 'sqlite-devel'
    has_yum 'sqlite3-devel'
  end
end
