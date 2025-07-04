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
alias llt "ll --tree"
alias g git
alias :q exit
alias vim $HOME/nvim-nightly/bin/nvim
alias cg gwen_custom_git_commands
alias gp "git pull"
alias gps "git push"
alias nb "npm run build"
alias nw "npm run watch"
alias ni "npm install"

# basically find what window are open
function ff
    aerospace list-windows --all | peco | read -l selected
    if test -n "$selected"
        set window_id (echo $selected | awk '{print $1}')
        aerospace focus --window-id "$window_id"
    end
end

# alias for gh commands
function gpch
  gh pr checkout $argv
end

function gcm
  g commit -m $argv
end

function grc
  gh repo clone $argv
end

function gbc
  g checkout -b $argv
end

# stripe m3u8 to mp3
function m3u8
  ffmpeg -i "$argv" -f mp3 mp3.mp3
end

if type -q eza
  alias ll "eza -l -g --icons"
  alias lla "ll -a"
end

## docker aliases
alias dcu "docker compose up -d"
alias dcd "docker compose down"
alias dce "docker compose exec php bash"

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

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end
starship init fish | source

# Automatically source our H5P config if present
if test -f $HOME/.config/fish/config.h5p.fish
  source $HOME/.config/fish/config.h5p.fish
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin
