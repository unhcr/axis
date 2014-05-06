package :node, :provides => :js_runtime do
  description 'Install node for javascript runtime'

  version = 'v0.10.28'

  source "http://nodejs.org/dist/v0.10.28/node-#{version}.tar.gz" do
    install_command "sudo make install"
    prefix    '/usr/local'
    archives  '/home/deploy'
    builds    '/home/deploy'
  end
  verify do
    has_executable 'node'
  end
end
