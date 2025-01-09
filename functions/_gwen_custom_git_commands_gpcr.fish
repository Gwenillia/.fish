function _gwen_custom_git_commands_gpcr -d "Create a pull request on GitHub"
    # Function to detect the default branch using multiple methods
    function detect_default_branch
        # Attempt to get HEAD branch from remote
        set remote_info (git remote show origin ^/dev/null)
        if test -n "$remote_info"
            for line in $remote_info
                if string match -q "HEAD branch:" $line
                    echo (string trim (string replace "HEAD branch:" "" $line))
                    return
                end
            end
        end

        # Fallback: Check if 'main' exists locally
        if git show-ref --verify --quiet "refs/heads/main"
            echo "main"
            return
        end

        # Fallback: Check if 'master' exists locally
        if git show-ref --verify --quiet "refs/heads/master"
            echo "master"
            return
        end

        # Fallback: Use the current branch
        set current_branch (git symbolic-ref --short HEAD 2>/dev/null)
        if test -n "$current_branch"
            echo "$current_branch"
            return
        end

        # If all else fails, return empty
        echo ""
    end

    # Attempt to detect the default branch
    set default_branch (detect_default_branch)

    # If detection failed, prompt the user or set a known default
    if test -z "$default_branch"
        echo "Warning: Unable to detect default branch."
        read -P "Enter the default branch name (default: main): " user_branch
        if test -n "$user_branch"
            set default_branch $user_branch
        else
            set default_branch "main"
            echo "Using 'main' as the default branch."
        end
    end

    # Display help if no arguments are provided
    if test (count $argv) -eq 0
        echo "Usage: gpcr [target_branch] \"PR title\""
        echo
        echo "Examples:"
        echo "  gpcr main \"Fix issue with user authentication\""
        echo "  gpcr \"Add new feature to dashboard\""
        return 1
    end

    # Initialize variables
    set target_branch $default_branch
    set title ""

    # Determine if the first argument is the target branch or the PR title
    if test (count $argv) -ge 2
        set target_branch $argv[1]
        set title $argv[2]
    else if test (count $argv) -eq 1
        set title $argv[1]
    end

    # Trim leading and trailing spaces from title
    set title (string trim $title)

    # Validate PR title
    if test -z "$title"
        echo "Error: PR title is required."
        echo "Usage: gpcr [target_branch] \"PR title\""
        return 1
    end

    # Validate that the target branch name does not contain spaces
    if string match -q " " "$target_branch"
        echo "Error: Branch names cannot contain spaces."
        return 1
    end

    # Validate that the target branch exists locally
    if not git show-ref --verify --quiet "refs/heads/$target_branch"
        echo "Error: Target branch '$target_branch' does not exist locally."
        return 1
    end

    # Execute the gh pr create command
    if test "$target_branch" != "$default_branch"
        gh pr create -a Gwenillia -t "$title" -B "$target_branch"
    else
        gh pr create -a Gwenillia -t "$title"
    end
end
