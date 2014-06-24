package :git, :provides => :scm do
  description 'Git Distributed Version Control'
  version '1.9.2'
  source "https://www.kernel.org/pub/software/scm/git/git-1.9.2.tar.gz" do
    install_command "sudo make install"
    prefix    '/usr/local'
    archives  '/home/deploy'
    builds    '/home/deploy'
  end


  requires :git_dependencies

  runner 'which git'

  verify do
    has_file '/usr/local/bin/git'
    has_executable 'git'
  end
end

package :git_dependencies do
  description 'Git Build Dependencies'
  pkgs = %w(expat-devel curl curl-devel zlib-devel openssl-devel gcc)

  pkgs.each do |pkg|
    runner "sudo yum install #{pkg} -y"
  end

  verify do
    has_yum 'expat-devel'
    has_yum 'curl'
    has_yum 'zlib-devel'
    has_yum 'openssl-devel'
    has_yum 'gcc'
  end
end
