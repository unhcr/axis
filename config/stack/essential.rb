package :build_essential do
  description 'Build tools'
  requires 'www'
  apt 'build-essential' do
    pre :install, 'yum update'
  end
end

package :bashrc do
  runner 'echo https_proxy=https://proxy.unhcr.local:8080 >> /home/deploy/.bashrc'
  runner 'echo http_proxy=http://proxy.unhcr.local:8080 >> /home/deploy/.bashrc'
  runner 'echo PATH=$HOME/.rbenv/bin:$PATH:$HOME/.bin >> /home/deploy/.bashrc'
  runner "chown 'deploy' /home/deploy/.bashrc"
  runner 'source /home/deploy/.bashrc'

  verify do
    has_file '/home/deploy/.bashrc'
    belongs_to_user '/home/deploy/.bashrc', 'deploy'
  end
end

package :cronrc do
  description 'Creates cronrc file for bash scripts that run in cron'

  runner 'echo https_proxy=https://proxy.unhcr.local:8080 >> /home/deploy/.cronrc'
  runner 'echo http_proxy=http://proxy.unhcr.local:8080 >> /home/deploy/.cronrc'
  runner 'echo PATH=$HOME/.rbenv/bin:$PATH:$HOME/.bin >> /home/deploy/.cronrc'
  runner 'echo eval "$(rbenv init -)"  >> ~/.cronrc'
  runner "chown 'deploy' /home/deploy/.cronrc"

  verify do
    has_file '/home/deploy/.cronrc'
    belongs_to_user '/home/deploy/.cronrc', 'deploy'
  end
end

package :www do
  description 'Creates www folder for deploy'

  runner 'sudo -A mkdir /var/www/'
  runner 'chown deploy /var/www'

  verify do
    has_directory '/var/www/'
    belongs_to_user '/var/www/', 'deploy'
  end
end
