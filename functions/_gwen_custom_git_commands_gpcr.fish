function _gwen_custom_git_commands_gpcr -d "Create a pull request on GitHub"
    set branch ""
    set title ""

    # If no arguments, display help
    if test (count $argv) -eq 0
        echo "Usage: gpcr [-B branch] \"PR title\""
        return 1
    end

    # Parse arguments
    while test (count $argv) -gt 0
        switch $argv[1]
            case '-B'
                if test (count $argv) -lt 2
                    echo "Error: -B flag requires a branch name."
                    return 1
                end
                set branch $argv[2]
                set argv $argv[3..-1]
            case '-*' 
                echo "Unknown option: $argv[1]"
                return 1
            case '*'
                set title "$title $argv[1]"
                set argv $argv[2..-1]
        end
    end

    # Trim leading and trailing spaces from title
    set title (string trim $title)

    if test -z "$title"
        echo "Error: PR title is required."
        return 1
    end

    # Execute the gh pr create command
    if test -n "$branch"
        gh pr create -a Gwenillia -t "$title" -B "$branch"
    else
        gh pr create -a Gwenillia -t "$title"
    end
end
