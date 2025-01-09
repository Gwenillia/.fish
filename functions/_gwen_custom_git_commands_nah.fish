function _gwen_custom_git_commands_nah --description "Resets to HEAD, cleans untracked files and aborts rebase if needed"
    git reset --hard
    git clean -df
    if test -d .git/rebase-apply -o -d .git/rebase-merge
        git rebase --abort
    end
end

