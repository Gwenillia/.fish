function h5pBump -d "Bump the patch version of the H5P content type and commit the changes with a tag"
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

    # Step 1: Check for library.json
    if not test -f "library.json"
        set_color red
        echo "Error: library.json not found in the current folder."
        set_color normal
        return 1
    end

    # Step 2: Move to parent directory and execute the command
    set CURRENT_FOLDER (basename "$PWD")
    set PARENT_FOLDER (dirname "$PWD")

    set_color blue
    echo "Changing directory to parent folder: $PARENT_FOLDER"
    set_color normal
    # Change to the parent directory or exit if it fails
    cd "$PARENT_FOLDER"; or begin
        set_color red
        echo "Error: Failed to change directory to $PARENT_FOLDER."
        set_color normal
        return 1
    end
    
    set_color blue
    echo "Executing 'h5p utils increase-patch-version' for folder: $CURRENT_FOLDER"
    set_color normal
    # Execute the command and capture its output
    set COMMAND_OUTPUT (h5p utils increase-patch-version "$CURRENT_FOLDER" ^&1)

    # Check if the command was successful
    if test $status -ne 0
        set_color red
        echo "Error: Failed to execute 'h5p utils increase-patch-version'."
        echo "Output: $COMMAND_OUTPUT"
        set_color normal
        return 1
    end

    # Extract the version number using jq
    set MAJOR (jq -r '.majorVersion' "$CURRENT_FOLDER/library.json")
    set MINOR (jq -r '.minorVersion' "$CURRENT_FOLDER/library.json")
    set PATCH (jq -r '.patchVersion' "$CURRENT_FOLDER/library.json")
    
    # Check if all version components were successfully extracted
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

    # Step 3: Change back to the original folder
    set_color blue
    echo "Changing back to the original folder: $CURRENT_FOLDER"
    set_color normal
    cd "$CURRENT_FOLDER"; or begin
        set_color red
        echo "Error: Failed to change back to directory $CURRENT_FOLDER."
        set_color normal
        return 1
    end

    # Step 4, 5, 6: Git commands
    set_color blue
    echo "Adding library.json to git."
    set_color normal
    git add library.json

    if not git commit -m "Bump to $VERSION"
        set_color red
        echo "Error: Git commit failed."
        set_color normal
        return 1
    end

    if not git tag -a "$VERSION" -m "$VERSION"
        set_color red
        echo "Error: Git tagging failed."
        set_color normal
        return 1
    end

    set COMMIT_HASH (git rev-parse HEAD)
    set COMMIT_DETAILS (git log -1 --pretty=%B)
    set TAG_MESSAGE (git tag -n1 "$VERSION")

    echo
    set_color magenta
    echo "### Commit Details ###"
    set_color normal
    echo "Commit Hash: $COMMIT_HASH"
    echo "Commit Message: $COMMIT_DETAILS"
    echo
    set_color magenta
    echo "### Tag Details ###"
    set_color normal
    echo "Tag Name: $VERSION"
    echo "Tag Message: $TAG_MESSAGE"
    echo
    set_color green
    echo "Version bumped to $VERSION and changes committed with a tag."

    # Step 7: Prompt for confirmation before pushing
    echo
    echo -n "Do you want to push the changes and the tag to the remote repository? (y/n): "
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

      set_color green
      echo "Changes and tag pushed successfully."
      set_color normal
    else
      set_color yellow
      echo "Push operation aborted by the user."
    set_color normal
  end
end
