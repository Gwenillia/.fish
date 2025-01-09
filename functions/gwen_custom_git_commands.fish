function gwen_custom_git_commands
  if test (count $argv) -lt 1
    echo "Usage: custom_git_commands [help|rtm|nah|flist|forget|uncommit]"
    return
  end

  switch $argv[1]
    case "help"
      echo "Usage: custom_git_commands [help|rtm|nah|flist|forget|uncommit]"
      echo
      echo "Subcommands:"
      echo "  rtm        Merges specific branch to master"
      echo "  nah        Resets to HEAD, cleans untracked files and aborts rebase if needed"
      echo "  flist      Fetches, checks for gone branches, deletes them or says none"
      echo "  forget     Lists branches that are gone"
      echo "  uncommit   Backs out of the last commit but keeps the changes"
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
      echo "Unknown subcommand: $argv[1]"
  end
end
