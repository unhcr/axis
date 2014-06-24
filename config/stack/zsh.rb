package :ohmyzsh do
  description 'Installs ZSH for server'

  requires :zshrc, :default_shell

  runner "wget --no-check-certificate http://install.ohmyz.sh -O - | sh"

  verify do
    has_directory '/home/deploy/.oh-my-zsh'
  end
end

package :zsh do

  runner 'sudo yum install -y zsh'

  verify do
    has_yum 'zsh'
    has_executable 'zsh'
  end

end

package :default_shell do

  requires :zsh

  runner 'chsh -s /bin/zsh'

end
