package :zsh do
  description 'Installs ZSH for server'

  requires :zshrc

  runner "export ZSH=/home/deploy; wget --no-check-certificate http://install.ohmyz.sh -O - | sh"

  verify do
    has_file '/bin/zsh'
  end
end
