package :sqlite3 do
  description 'MySQL Database'
  pkgs = %w( sqlite3-devel )

  pkgs.each do |pkg|
    runner "sudo yum install #{pkg} -y"
  end
  verify do
    has_executable 'sqlite3'
  end
end
