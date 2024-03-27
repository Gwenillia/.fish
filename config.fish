set fish_greeting ""

set -gx TERM xterm-256color

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias :q exit

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

# export mac stuff
export STARSHIP_DISTRO=""
export MUSIC_APP="Music"

# set global  variables
set -gx EDITOR vim
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx MYVIMRC ~/.config/vim/.vimrc
set -gx H5P_NO_UPDATES 1

# NodeJS
set -gx PATH node_modules/.bin $PATH

# OpenAI 
set -gx OPENAI_API_KEY $OPENAI_API_KEY

# Pyenv
set -gx PYENV_ROOT $HOME/.pyenv/shims
set -gx PATH $PYENV_ROOT:$PATH
set -gx PIPENV_PYTHON $PYENV_ROOT/python

set -gx PATH $HOME/.jenv/bin $PATH
# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
  status --is-command-substitution; and return

  if test -f .nvmrc; and test -r .nvmrc;
    nvm use
  else
  end
end

function gitRtm -d "Will merge specific branch to master"
  set branch $argv[1]
  set target_branch $argv[2]
  
  if test -z "$branch"
    echo "Usage: gitRtm <branch> [target_branch]"
    return 1
  end

  if test -z "$target_branch"
    set target_branch "master"
  end

  echo "Checking out $branch..."
  g checkout $branch
  g pull

  echo "Checking out $target_branch..."
  g checkout $target_branch
  g pull

  echo "Merging $branch into $target_branch..."
  g merge $branch
  g push

  echo "Done."
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end
starship init fish | source

