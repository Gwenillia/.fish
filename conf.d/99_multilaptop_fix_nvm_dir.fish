# Ensure NVM_DIR follows the real HOME, regardless of previous env or plugin defaults
if test -n "$HOME"
    # XDG_DATA_HOME: default under HOME if missing or pointing elsewhere
    if set -q XDG_DATA_HOME
        if not string match -q "$HOME"* -- "$XDG_DATA_HOME"
            set -gx XDG_DATA_HOME "$HOME/.local/share"
        end
    else
        set -gx XDG_DATA_HOME "$HOME/.local/share"
    end

    # NVM_DIR: always under XDG_DATA_HOME/nvm
    set -gx NVM_DIR "$XDG_DATA_HOME/nvm"

    # Most fish nvm plugins use a global nvm_data variable internally
    set -g nvm_data "$NVM_DIR"

    # Ensure directory exists
    mkdir -p "$NVM_DIR"
end

