function _gwen_custom_git_commands_gpcr -d "Create a pull request on GitHub"
    set default_branch "main"  # Change this to your default branch if different

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

    # Execute the gh pr create command
    if test "$target_branch" != "$default_branch"
        gh pr create -a Gwenillia -t "$title" -B "$target_branch"
    else
        gh pr create -a Gwenillia -t "$title"
    end
end
