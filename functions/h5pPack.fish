function h5pPack --description "Pack H5P content with optional build & upload"
  # The separate config file we want to maintain
  set H5P_CONFIG_FILE $HOME/.config/fish/config.h5p.fish

  # 0. Ensure config.h5p.fish exists, and that config.fish sources it
  if not test -f $H5P_CONFIG_FILE
    touch $H5P_CONFIG_FILE
    echo "# This file is auto-managed by h5pPack" >> $H5P_CONFIG_FILE
    echo "Created $H5P_CONFIG_FILE"
  end

  # Make sure config.fish sources it with a literal $HOME path
  if not grep -q "config.h5p.fish" ~/.config/fish/config.fish
    echo "" >> ~/.config/fish/config.fish
    echo "# Automatically source our H5P config if present" >> ~/.config/fish/config.fish

    # Notice we escape the $ so that fish writes the literal '$HOME'
    echo "if test -f \$HOME/.config/fish/config.h5p.fish" >> ~/.config/fish/config.fish
    echo "  source \$HOME/.config/fish/config.h5p.fish" >> ~/.config/fish/config.fish
    echo "end" >> ~/.config/fish/config.fish

    echo "Added source line to ~/.config/fish/config.fish"
  end

  # Source it now so we pick up previously stored variables
  if test -f $H5P_CONFIG_FILE
    source $H5P_CONFIG_FILE
  end

  #
  # 1. Prompt for DESTINATION_DIR if it's not set yet
  #
  if not set -q DESTINATION_DIR
    echo "No destination directory is currently set."
    echo "Please enter the path you'd like to use for .h5p files (no default):"
    read -l customDest

    while test -z "$customDest"
      echo "You must specify a destination directory. Please try again."
      read -l customDest
    end

    set -gx DESTINATION_DIR "$customDest"

    # Write it to config.h5p.fish
    if not grep -q "DESTINATION_DIR" $H5P_CONFIG_FILE
      echo "" >> $H5P_CONFIG_FILE
      echo "# h5pPack DESTINATION_DIR" >> $H5P_CONFIG_FILE
      echo "set -gx DESTINATION_DIR '$customDest'" >> $H5P_CONFIG_FILE
      echo "Destination directory persisted in $H5P_CONFIG_FILE"
    end

    echo "Destination directory set to: $DESTINATION_DIR"
  end

  #
  # 2. Prompt for username, password, and URL if they're not set (no defaults)
  #
  if not set -q USERNAME_H5P
    echo "No username is set for H5P uploads."
    echo "Please enter your H5P server username (no default):"
    read -l customUser

    while test -z "$customUser"
      echo "You must specify a username. Please try again."
      read -l customUser
    end

    set -gx USERNAME_H5P "$customUser"

    if not grep -q "USERNAME_H5P" $H5P_CONFIG_FILE
      echo "" >> $H5P_CONFIG_FILE
      echo "# h5pPack USERNAME" >> $H5P_CONFIG_FILE
      echo "set -gx USERNAME_H5P '$customUser'" >> $H5P_CONFIG_FILE
      echo "USERNAME_H5P persisted in $H5P_CONFIG_FILE"
    end
  end

  if not set -q PASSWORD_H5P
    echo "No password is set for H5P uploads."
    echo "Please enter your H5P server password (no default):"
    read -l customPass

    while test -z "$customPass"
      echo "You must specify a password. Please try again."
      read -l customPass
    end

    set -gx PASSWORD_H5P "$customPass"

    if not grep -q "PASSWORD_H5P" $H5P_CONFIG_FILE
      echo "" >> $H5P_CONFIG_FILE
      echo "# h5pPack PASSWORD" >> $H5P_CONFIG_FILE
      echo "set -gx PASSWORD_H5P '$customPass'" >> $H5P_CONFIG_FILE
      echo "PASSWORD_H5P persisted in $H5P_CONFIG_FILE"
    end
  end

  if not set -q UPLOAD_URL_H5P
    echo "No upload URL is set for H5P uploads."
    echo "Please enter the server URL (no default):"
    read -l customUrl

    while test -z "$customUrl"
      echo "You must specify a URL. Please try again."
      read -l customUrl
    end

    set -gx UPLOAD_URL_H5P "$customUrl"

    if not grep -q "UPLOAD_URL_H5P" $H5P_CONFIG_FILE
      echo "" >> $H5P_CONFIG_FILE
      echo "# h5pPack UPLOAD_URL" >> $H5P_CONFIG_FILE
      echo "set -gx UPLOAD_URL_H5P '$customUrl'" >> $H5P_CONFIG_FILE
      echo "UPLOAD_URL_H5P persisted in $H5P_CONFIG_FILE"
    end
  end

  #
  # 3. Parse the arguments (supports multiple: -b/--build, -u/--upload, -h/--help)
  #
  set build "no"
  set upload "no"

  if test (count $argv) -gt 0
    for arg in $argv
      switch $arg
        case -b --build
          set build "yes"
        case -u --upload
          set upload "yes"
        case -h --help
          # Enhanced Help Message with Colors and Formatting
          set_color blue
          echo "==============================="
          echo "         h5pPack Help          "
          echo "==============================="
          set_color normal
          echo
          set_color --bold "Usage:" normal
          echo "  h5pPack [options]"
          echo
          set_color --bold "Description:" normal
          echo "  Pack the current H5P library folder into a .h5p file using"
          echo "  the library name and version from library.json."
          echo "  Then moves it to the destination folder ($DESTINATION_DIR)."
          echo
          set_color --bold "Options:" normal
          set_color green
          echo "  -b, --build" 
          set_color normal
          echo "      Build the library before packing."
          set_color green
          echo "  -u, --upload"
          set_color normal
          echo "      Upload the newly created .h5p file to $UPLOAD_URL_H5P."
          set_color green
          echo "  -h, --help"
          set_color normal
          echo "      Show this help message and exit."
          echo
          set_color blue
          echo "==============================="
          set_color normal
          return 0
        case '*'
          set_color red
          echo "Error: Invalid argument: $arg"
          set_color normal
          echo "Use -h or --help for usage."
          return 1
      end
    end
  end

  #
  # 4. Pack logic
  #
  set STARTING_FOLDER (basename "$PWD")

  if not test -f library.json
    set_color red
    echo "Error: No library.json found in the current directory."
    set_color normal
    return 1
  end

  # Use jq to parse JSON
  set MACHINE_NAME (jq -r '.machineName' library.json)
  set MAJOR (jq -r '.majorVersion' library.json)
  set MINOR (jq -r '.minorVersion' library.json)
  set PATCH (jq -r '.patchVersion' library.json)

  if test -z "$MAJOR" -o -z "$MINOR" -o -z "$PATCH"
    set_color red
    echo "Error: Failed to extract version from library.json."
    set_color normal
    return 1
  end

  set VERSION "$MAJOR.$MINOR.$PATCH"
  echo "Version: $VERSION"

  cd ..
  set DESTINATION_FILE "$MACHINE_NAME-$VERSION.h5p"

  # Build first if requested
  if test "$build" = "yes"
    echo "Building the library..."
    h5p utils build "$STARTING_FOLDER"
    if test $status -ne 0
      set_color red
      echo "Error: Build failed."
      set_color normal
      return 1
    end
  end

  # Always pack
  echo "Packing the library..."
  h5p utils pack "$STARTING_FOLDER" "$DESTINATION_FILE"
  if test $status -ne 0
    set_color red
    echo "Error: Packing failed."
    set_color normal
    return 1
  end

  # Move the file to DESTINATION_DIR
  mkdir -p "$DESTINATION_DIR"
  mv "$DESTINATION_FILE" "$DESTINATION_DIR"

  #
  # 5. Upload if requested
  #
  if test "$upload" = "yes"
    echo "Uploading library to $UPLOAD_URL_H5P ..."

    set uploadedFile "$DESTINATION_DIR/$DESTINATION_FILE"

    set RESPONSE (curl -u "$USERNAME_H5P:$PASSWORD_H5P" \
      -H "Accept: application/json" \
      -F "h5p=@$uploadedFile" \
      "$UPLOAD_URL_H5P" 2>&1)

    set STATUS $status

    if test $STATUS -eq 0
      set_color green
      echo "Success: File uploaded successfully."
      set_color normal
      echo "Server response: $RESPONSE"
    else
      set_color red
      echo "Error: File upload failed."
      set_color normal
      echo "cURL output: $RESPONSE"
    end
  end

  cd "$STARTING_FOLDER"
  set_color green
  echo "Success: Packed $DESTINATION_FILE to $DESTINATION_DIR"
  set_color normal
end
