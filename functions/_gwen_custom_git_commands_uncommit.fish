function _gwen_custom_git_commands_uncommit -d "Backs out of the last commit but keeps your changes"
    git reset --soft HEAD~1
end
