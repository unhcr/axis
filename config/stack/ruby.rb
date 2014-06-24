package :rbenv, :provides => :ruby_env do
  description 'Install rubies using rbenv'
  requires :git, :git_proxy, :bashrc, :cronrc

  runner "git clone https://github.com/sstephenson/rbenv.git /home/deploy/.rbenv"

  verify do
    has_executable "/home/deploy/.rbenv/bin/rbenv"
  end

end

package :ruby_build do
  description 'Helper for installing ruby versions'
  requires :rbenv

  runner "git clone https://github.com/sstephenson/ruby-build.git /home/deploy/.rbenv/plugins/ruby-build"
  runner '/home/deploy/.rbenv/bin/rbenv rehash'

  verify do
    has_file '/home/deploy/.rbenv/plugins/ruby-build/bin/rbenv-install'
  end

end

package :ruby do
  requires :ruby_build
  version = '2.0.0-p353'

  runner "export http_proxy=http://proxy.unhcr.local:8080; rbenv install #{version}", :sudo => false
  runner 'rbenv rehash'

  verify do
    has_directory "/home/deploy/.rbenv/versions/#{version}"
  end
end

package :set_default_ruby do
  requires :ruby

  push_text '2.0.0-p353', "/home/deploy/.rbenv/global"

  verify do
    file_contains "/home/deploy/.rbenv/global", '2.0.0-p353'
  end
end

package :add_rbenv_bundler do
  runner "gem install bundler"
  runner "rbenv rehash"

  verify do
    @commands << "/home/deploy/.rbenv/versions/2.0.0-p353/bin/gem list | grep bundler"
  end
end

package :rubygems do
  runner "sudo yum -y install rubygems"

  verify do
    has_executable 'gem'
  end
end
