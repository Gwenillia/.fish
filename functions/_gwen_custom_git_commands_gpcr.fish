function gpcr -d "Create a pull request on GitHub"
    # Initialize local variables
    set -l branch ""
    set -l title ""
    set -l args $argv

    # If no arguments, display help
    if test (count $args) -eq 0
        echo "Usage: gpcr [-B branch] \"PR title\""
        return 1
    end

    # Parse arguments
    while test (count $args) -gt 0
        switch $args[1]
            case -B
                if test (count $args) -lt 2
                    echo "Error: -B flag requires a branch name."
                    return 1
                end
                set branch $args[2]
                # Remove the first two arguments (-B and branch name)
                set args $args[3..-1]
            case -* 
                echo "Unknown option: $args[1]"
                return 1
            case '*'
                # Accumulate all remaining arguments as the title
                if test -z "$title"
                    set title "$args[1]"
                else
                    set title "$title $args[1]"
                end
                # Remove the first argument (part of the title)
                set args $args[2..-1]
        end
    end

    # Trim leading and trailing whitespace from title
    set title (string trim "$title")

    # Validate that a title was provided
    if test (string length "$title") -eq 0
        echo "Error: PR title is required."
        return 1
    end

    # Execute the gh pr create command
    if test -n "$branch"
        gh pr create -a "Gwenillia" -t "$title" -B "$branch"
    else
        gh pr create -a "Gwenillia" -t "$title"
    end

    # Check if the gh command was successful
    if test $status -eq 0
        echo "Pull request created successfully."
    else
        echo "Failed to create pull request."
        return 1
    end
end
