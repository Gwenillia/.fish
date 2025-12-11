# ---------------------------------
# Workaround many laptops laptops
# Normalize HOME on macOS: use /Users/<username> on this machine
if test (uname) = "Darwin"
    set real_home /Users/(id -un)

    # If HOME doesn't match the real home but the real dir exists, fix it
    if test -d $real_home; and test "$HOME" != "$real_home"
        set -gx HOME $real_home
    end
end

# If we're in a container or on macOS, prefer $HOME if valid.
# If HOME is invalid (e.g. /root in a container), fall back to something under /Users.
if test -d $HOME
    cd $HOME
else if test -d /Users/(id -un)
    # If the current user also has a /Users/<username> directory, use that
    cd /Users/(id -un)
else if test -d /Users
    # Generic fallback: pick the first directory under /Users (for mounted host homes in containers)
    set first_user (ls /Users | head -n 1)
    if test -n "$first_user"; and test -d /Users/$first_user
        cd /Users/$first_user
    end
end
# ---------------------------------


set fish_greeting ""

set -gx TERM xterm-256color

set -g fish_term_title_use_path no
set -g fish_term_title_use_command no

# Detect platform
set -l os (uname)

# Set HOME_MAC and HOME_LINUX manually (optional but clean)
if test $os = "Darwin"
    set -gx DOTFILES_HOME $HOME
    alias vim $DOTFILES_HOME/nvim-nightly/bin/nvim
else if test $os = "Linux"
  # In containers, prefer the same mac home as above
  if test -d $MAC_HOME
      set -gx DOTFILES_HOME $MAC_HOME
  else
      set -gx DOTFILES_HOME $MAC_HOME_H5P
  end

  ln -sfn $DOTFILES_HOME/.config/nvim ~/.config/nvim
  alias vim /usr/bin/nvim
end

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
  # Long list, group, icons — like `ls -l`
  alias ll "eza -l --git --icons"

  # Add dotfiles
  alias lla "eza -la --git --icons"

  # Tree view from current dir
  alias llt "eza --tree --icons"

  # Simple list, still colorful
  alias ls "eza --icons"

  # Show all files
  alias la "eza -a --icons"
else
  # Fallback to ls with color
  set -l os (uname)
  if test "$os" = "Darwin"
    alias ls "ls -Gp"
  else if test "$os" = "Linux"
    alias ls "ls -p --color=auto"
  end
  alias la "ls -A"
  alias ll "ls -l"
  alias lla "ll -A"
  alias llt "ll --tree"
end

## docker aliases
alias dcu "docker compose up -d"
alias dcd "docker compose down"
alias dce "docker compose exec php bash"

# Starship distro
if command -q starship
  switch (uname)
    case Darwin
      set -gx STARSHIP_DISTRO ""
    case Linux
      set -gx STARSHIP_DISTRO ""
  end

  starship init fish | source
end

# export mac stuff
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
set -gx PYENV_ROOT $DOTFILES_HOME/.pyenv/shims
set -gx PATH $PYENV_ROOT:$PATH
set -gx PIPENV_PYTHON $PYENV_ROOT/python

set -gx PATH $DOTFILES_HOME/.jenv/bin $PATH
# NVM
function __check_rvm --on-variable PWD --description 'Do nvm stuff'
  status --is-command-substitution; and return

  if test -f .nvmrc; and test -r .nvmrc;
    nvm use
  else
    set -gx nvm_default_version v22
  end
end

set LOCAL_CONFIG (dirname (status --current-filename))/config-local.fish
if test -f $LOCAL_CONFIG
  source $LOCAL_CONFIG
end

# Automatically source our H5P config if present
if test -f $DOTFILES_HOME/.config/fish/config.h5p.fish
  source $DOTFILES_HOME/.config/fish/config.h5p.fish
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $DOTFILES_HOME/.lmstudio/bin
