function _gwen_custom_git_commands_flist -d "Just lists branches that are gone"
    git fetch -p
    git branch -vv | awk '/: gone]/{print $1}'
end

