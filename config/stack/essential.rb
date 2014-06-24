module GitConfigVerifier
  def has_git_property(property, value)
    @commands << "git config --get #{property} | grep #{value}"
  end
end

Sprinkle::Verify.register(GitConfigVerifier)

package :build_essential do
  description 'Build tools'

  HTTP_PROXY = 'http://proxy.unhcr.local:8080'
  HTTPS_PROXY = 'https://proxy.unhcr.local:8080'
  PATH = "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH:$HOME/.bin"

  requires :www, :proxy
  runner 'sudo yum update -y --skip-broken'
end

package :bashrc do
  push_text "export https_proxy=#{HTTPS_PROXY}", '/home/deploy/.bashrc'
  push_text "export http_proxy=#{HTTP_PROXY}", '/home/deploy/.bashrc'
  push_text "export PATH=#{PATH}", '/home/deploy/.bashrc'
  runner "chown 'deploy' /home/deploy/.bashrc"

  verify do
    has_file '/home/deploy/.bashrc'
    belongs_to_user '/home/deploy/.bashrc', 'deploy'
    file_contains '/home/deploy/.bashrc', "https_proxy=#{HTTPS_PROXY}"
    file_contains '/home/deploy/.bashrc', "http_proxy=#{HTTP_PROXY}"
    file_contains '/home/deploy/.bashrc', "PATH=#{PATH}"
  end
end

package :zshrc do
  push_text "export https_proxy=#{HTTPS_PROXY}", '/home/deploy/.zshrc'
  push_text "export http_proxy=#{HTTP_PROXY}", '/home/deploy/.zshrc'
  push_text "export PATH=#{PATH}", '/home/deploy/.zshrc'
  push_text 'eval "$(rbenv init - )"', '/home/deploy/.zshrc'
  runner "chown 'deploy' /home/deploy/.zshrc"

  verify do
    has_file '/home/deploy/.zshrc'
    belongs_to_user '/home/deploy/.zshrc', 'deploy'
    file_contains '/home/deploy/.zshrc', "https_proxy=#{HTTPS_PROXY}"
    file_contains '/home/deploy/.zshrc', "http_proxy=#{HTTP_PROXY}"
    file_contains '/home/deploy/.zshrc', "PATH=#{PATH}"
    file_contains '/home/deploy/.zshrc', 'rbenv init'
  end
end

package :cronrc do
  description 'Creates cronrc file for bash scripts that run in cron'

  push_text "export https_proxy=#{HTTPS_PROXY}", '/home/deploy/.cronrc'
  push_text "export http_proxy=#{HTTP_PROXY}", '/home/deploy/.cronrc'
  push_text "export PATH=#{PATH}", '/home/deploy/.cronrc'

  runner "chown 'deploy' /home/deploy/.cronrc"

  verify do
    has_file '/home/deploy/.cronrc'
    belongs_to_user '/home/deploy/.cronrc', 'deploy'
    file_contains '/home/deploy/.cronrc', "https_proxy=#{HTTPS_PROXY}"
    file_contains '/home/deploy/.cronrc', "http_proxy=#{HTTP_PROXY}"
    file_contains '/home/deploy/.cronrc', "PATH=#{PATH}"
  end
end

package :www_dir do

  runner 'sudo mkdir /var/www/'
  verify do
    has_directory '/var/www/'
  end
end

package :www do
  description 'Creates www folder for deploy'
  requires :bashrc, :www_dir

  runner 'sudo chown deploy /var/www'

  verify do
    has_directory '/var/www/'
    belongs_to_user '/var/www/', 'deploy'
  end
end

package :proxy do
  description 'Setup proxy'

  requires :wget_proxy, :gem_proxy

  push_text "proxy=#{HTTP_PROXY}", '/etc/yum.conf', :sudo => true

  verify do
    file_contains '/etc/yum.conf', "proxy=#{HTTP_PROXY}"
  end
end

package :wget_proxy do
  description 'Setup wget proxy'

  push_text "http_proxy=#{HTTP_PROXY}", '/etc/wgetrc', :sudo => true
  push_text "https_proxy=#{HTTPS_PROXY}", '/etc/wgetrc', :sudo => true

  verify do
    file_contains '/etc/wgetrc', "http_proxy=#{HTTP_PROXY}"
    file_contains '/etc/wgetrc', "https_proxy=#{HTTPS_PROXY}"
  end
end

package :gem_proxy do
  description 'Setup gem proxy'

  push_text "http_proxy: #{HTTP_PROXY}", '/home/deploy/.gemrc'
  push_text "https_proxy: #{HTTPS_PROXY}", '/home/deploy/.gemrc'

  verify do
    file_contains '/home/deploy/.gemrc', "http_proxy: #{HTTP_PROXY}"
    file_contains '/home/deploy/.gemrc', "https_proxy: #{HTTPS_PROXY}"
  end
end

package :git_proxy do
  description 'Setup git proxy'

  requires :git

  runner "git config --global http.proxy #{HTTP_PROXY}"
  runner "git config --global https.proxy #{HTTPS_PROXY}"

  verify do
    has_git_property 'http.proxy', HTTP_PROXY
    has_git_property 'https.proxy', HTTPS_PROXY
  end
end

