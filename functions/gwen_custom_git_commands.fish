function gwen_custom_git_commands
  # Define color and style variables with correct order: color first, then style
  set COLOR_HEADER (set_color blue --bold)
  set COLOR_SUBHEADER (set_color green --bold)
  set COLOR_OPTION (set_color yellow --bold)
  set COLOR_EXAMPLE (set_color magenta --bold)
  set COLOR_RESET (set_color normal)

  if test (count $argv) -lt 1
    echo "$COLOR_HEADER Usage:$COLOR_RESET custom_git_commands [help|rtm|nah|flist|forget|uncommit|gpcr]"
    return
  end

  switch $argv[1]
    case "help"
      echo
      echo "$COLOR_HEADER Usage:$COLOR_RESET custom_git_commands [help|rtm|nah|flist|forget|uncommit|gpcr]"
      echo
      echo "$COLOR_HEADER Subcommands:$COLOR_RESET"
      echo "  $COLOR_OPTION rtm$COLOR_RESET        🔀 Merges specific branch to master"
      echo "  $COLOR_OPTION nah$COLOR_RESET        🛠️  Resets to HEAD, cleans untracked files and aborts rebase if needed"
      echo "  $COLOR_OPTION flist$COLOR_RESET      📋 Fetches, checks for gone branches, deletes them or says none"
      echo "  $COLOR_OPTION forget$COLOR_RESET     ❓ Lists branches that are gone"
      echo "  $COLOR_OPTION uncommit$COLOR_RESET   🔙 Backs out of the last commit but keeps the changes"
      echo "  $COLOR_OPTION gpcr$COLOR_RESET       🚀 Create a PR on GitHub"
      echo
      echo "$COLOR_HEADER gpcr Usage:$COLOR_RESET"
      echo "  gpcr [target_branch] \"PR title\""
      echo
      echo "$COLOR_HEADER Examples:$COLOR_RESET"
      echo "  $COLOR_EXAMPLE gpcr feat/xxx-x-x \"Fix blabla\"$COLOR_RESET"
      echo "  $COLOR_EXAMPLE gpcr \"Awesome PR Title\"$COLOR_RESET"
      echo
      echo "$COLOR_HEADER rtm Usage:$COLOR_RESET"
      echo "  rtm branch_name [target_branch]"
      echo
      echo "$COLOR_HEADER Examples:$COLOR_RESET"
      echo "  $COLOR_EXAMPLE rtm staging$COLOR_RESET"
      echo "  $COLOR_EXAMPLE rtm staging nightly$COLOR_RESET"
      echo
    case "rtm"
      _gwen_custom_git_commands_rtm $argv[2..-1]
    case "nah"
      _gwen_custom_git_commands_nah
    case "flist"
      _gwen_custom_git_commands_flist
    case "forget"
      _gwen_custom_git_commands_forget
    case "uncommit"
      _gwen_custom_git_commands_uncommit
    case "gpcr"
      _gwen_custom_git_commands_gpcr $argv[2..-1]
    case "*"
      echo "$COLOR_HEADER Unknown subcommand:$COLOR_RESET $argv[1]"
  end

  # Reset color at the end to prevent color bleeding
  set_color normal
end
