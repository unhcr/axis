package :rbenv, :provides => :ruby_env do
  description 'Install rubies using rbenv'
  requires :git, :bashrc, :cronrc

  runner "sudo -u deploy -i git clone git://github.com/sstephenson/rbenv.git /home/deploy/.rbenv"
  runner "source /home/deploy/.bashrc"
  runner "chown 'deploy' /home/deploy/.bashrc"

  verify do
    has_executable "/home/deploy/.rbenv/bin/rbenv"
  end

end

package :ruby_build do
  description 'Helper for installing ruby versions'
  requires :rbenv

  runner "sudo -u deploy -i https://github.com/sstephenson/ruby-build.git /home/deploy/.rbenv/plugins/ruby-build"
  runner '/home/deploy/.rbenv/bin/rbenv rehash'

  verify do
    has_file '/home/deploy/.rbenv/plugins/ruby-build/bin/rbenv-install'
  end

end

package :ruby do
  requires :ruby_build

  runner 'rbenv install 2.0.0-p353'

  verify do
    has_executable 'ruby'
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
  runner "/home/deploy/.rbenv/versions/2.0.0-p353/bin/gem install bundler"
  runner "/home/deploy/.rbenv/bin/rbenv rehash"

  verify do
    @commands << "/home/deploy/.rbenv/versions/2.0.0-p353/bin/gem list | grep bundler"
  end
end
