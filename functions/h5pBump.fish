function h5pBump -d "Bump the patch version of the H5P content type and commit the changes (tag optional)"
    # Check if required commands are available
    if not type -q h5p
        set_color red
        echo "Error: 'h5p' command not found. Please install it first."
        set_color normal
        return 1
    end

    if not type -q jq
        set_color red
        echo "Error: 'jq' command not found. Please install it first."
        set_color normal
        return 1
    end

    if not test -f "library.json"
        set_color red
        echo "Error: library.json not found in the current folder."
        set_color normal
        return 1
    end

    set CURRENT_FOLDER (basename "$PWD")
    set PARENT_FOLDER (dirname "$PWD")

    set_color blue
    echo "Changing directory to parent folder: $PARENT_FOLDER"
    set_color normal
    cd "$PARENT_FOLDER"; or begin
        set_color red
        echo "Error: Failed to change directory to $PARENT_FOLDER."
        set_color normal
        return 1
    end

    set_color blue
    echo "Executing 'h5p utils increase-patch-version' for folder: $CURRENT_FOLDER"
    set_color normal
    set COMMAND_OUTPUT (h5p utils increase-patch-version "$CURRENT_FOLDER" ^&1)

    if test $status -ne 0
        set_color red
        echo "Error: Failed to execute 'h5p utils increase-patch-version'."
        echo "Output: $COMMAND_OUTPUT"
        set_color normal
        return 1
    end

    set MAJOR (jq -r '.majorVersion' "$CURRENT_FOLDER/library.json")
    set MINOR (jq -r '.minorVersion' "$CURRENT_FOLDER/library.json")
    set PATCH (jq -r '.patchVersion' "$CURRENT_FOLDER/library.json")

    if test -z "$MAJOR" -o -z "$MINOR" -o -z "$PATCH"
        set_color red
        echo "Error: Failed to extract version numbers from library.json."
        echo "Major: $MAJOR, Minor: $MINOR, Patch: $PATCH"
        set_color normal
        return 1
    end

    set VERSION "$MAJOR.$MINOR.$PATCH"

    set_color green
    echo "Extracted version: $VERSION"
    set_color normal

    set_color blue
    echo "Changing back to the original folder: $CURRENT_FOLDER"
    set_color normal
    cd "$CURRENT_FOLDER"; or begin
        set_color red
        echo "Error: Failed to change back to directory $CURRENT_FOLDER."
        set_color normal
        return 1
    end

    set_color blue
    echo "Staging only version number changes in library.json"
    set_color normal

    git restore --staged library.json

    # Use git diff to get hunks and auto-select only the version ones
    set TMP_HUNK /tmp/version_hunks.txt

    git diff -U0 -- library.json > $TMP_HUNK

    if not test -s $TMP_HUNK
        set_color yellow
        echo "No changes detected in library.json"
        set_color normal
        return 1
    end

    # Loop through hunks and stage the ones that touch version keys
    git add -p library.json | while read -l line
        if string match -q "*majorVersion*" -- $line; or string match -q "*minorVersion*" -- $line; or string match -q "*patchVersion*" -- $line
            echo y
        else
            echo n
        end
    end | git add -p library.json

    set_color green
    echo "✅ Only version number changes staged in library.json"
    set_color normal

    if not git commit -m "Bump to $VERSION"
        set_color red
        echo "Error: Git commit failed."
        set_color normal
        return 1
    end

    # 🔥 Ask if user wants to tag
    echo
    echo -n "Do you want to create a git tag for version $VERSION? (y/n): "
    read -n 1 -s tag_choice
    echo

    set TAG_CHOICE (string lower "$tag_choice")
    set DO_TAG 0

    if test "$TAG_CHOICE" = "y" -o "$TAG_CHOICE" = "yes"
        set DO_TAG 1
        if not git tag -a "$VERSION" -m "$VERSION"
            set_color red
            echo "Error: Git tagging failed."
            set_color normal
            return 1
        end
    end

    set COMMIT_HASH (git rev-parse HEAD)
    set COMMIT_DETAILS (git log -1 --pretty=%B)

    echo
    set_color magenta
    echo "### Commit Details ###"
    set_color normal
    echo "Commit Hash: $COMMIT_HASH"
    echo "Commit Message: $COMMIT_DETAILS"

    if test $DO_TAG -eq 1
        set TAG_MESSAGE (git tag -n1 "$VERSION")
        echo
        set_color magenta
        echo "### Tag Details ###"
        set_color normal
        echo "Tag Name: $VERSION"
        echo "Tag Message: $TAG_MESSAGE"
    end

    set_color green
    echo
    echo "Version bumped to $VERSION and committed successfully."
    if test $DO_TAG -eq 1
        echo "Tag also created."
    end
    set_color normal

    echo
    echo -n "Do you want to push the changes to the remote repository? (y/n): "
    read -n 1 -s user_choice
    echo

    set USER_CHOICE (string lower "$user_choice")

    if test "$USER_CHOICE" = "y" -o "$USER_CHOICE" = "yes"
        set_color blue
        echo "Pushing commits to remote repository."
        set_color normal
        git push
        if test $status -ne 0
            set_color red
            echo "Error: Git push failed."
            set_color normal
            return 1
        end

        if test $DO_TAG -eq 1
            set_color blue
            echo "Pushing tag '$VERSION' to remote repository."
            set_color normal
            git push origin "$VERSION"
            if test $status -ne 0
                set_color red
                echo "Error: Git push origin '$VERSION' failed."
                set_color normal
                return 1
            end
        end

        set_color green
        echo "Changes" (test $DO_TAG -eq 1; and echo "and tag") "pushed successfully."
        set_color normal
    else
        set_color yellow
        echo "Push operation aborted by the user."
        set_color normal
    end
end

