module ServiceVerifier
  def has_service(service)
    @commands << "sudo service --status-all | grep #{service}"
  end
end

Sprinkle::Verify.register(ServiceVerifier)

package :services do
  description 'Provides services for the app'
  requires :elasticsearch, :phantomjs, :redis, :whenever

end

package :elasticsearch do
  description 'Elasticsearch'

  version = '1.1.1'
  runner "wget -cq https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{version}.noarch.rpm"
  runner "sudo rpm -i elasticsearch-#{version}.noarch.rpm"

  verify do
    has_service 'elasticsearch'
  end
end

package :whenever do
  description 'Whenever gem'
  gem 'whenever'
  runner 'rbenv rehash'

  verify do
    has_gem 'whenever'
    has_executable 'whenever'
  end
end

package :phantomjs do
  description 'Phantomjs'

  version = '1.9.7'
  runner "wget -cq https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-#{version}-linux-x86_64.tar.bz2"
  runner "tar xvjf phantomjs-#{version}-linux-x86_64.tar.bz2"
  runner "sudo cp phantomjs-#{version}-linux-x86_64/bin/phantomjs /usr/local/bin"

  verify do
    has_executable 'phantomjs'
  end
end

package :redis do
  description 'Redis'

  source 'http://download.redis.io/redis-stable.tar.gz' do
    configure_command 'echo '
    install_command 'sudo cp src/redis-benchmark /usr/local/bin/ &&
      sudo cp src/redis-cli /usr/local/bin/ &&
      sudo cp src/redis-server /usr/local/bin/ &&
      sudo cp redis.conf /etc/ &&
      sudo sed -i \'s/daemonize no/daemonize yes/\' /etc/redis.conf &&
      sudo sed -i \'s/^pidfile \/var\/run\/redis.pid/pidfile \/tmp\/redis.pid/\' /etc/redis.conf '
    prefix    '/usr/local'
    archives  '/home/deploy'
    builds    '/home/deploy'
  end

  verify do
    has_executable 'redis-server'
    has_executable 'redis-cli'
    has_executable 'redis-benchmark'
  end
end
