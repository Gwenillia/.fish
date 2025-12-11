# Normalize HOME on macOS before any other plugins (like z) run
if test (uname) = "Darwin"
    set -l real_home /Users/(id -un)

    if test -d $real_home
        set -gx HOME $real_home
    end
end

# Make sure z's data path follows the corrected HOME
if test -n "$HOME"
    set -gx Z_DATA "$HOME/.local/share/z/data"
    mkdir -p (dirname $Z_DATA)
end

