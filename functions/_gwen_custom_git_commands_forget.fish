function _gwen_custom_git_commands_forget --description "Fetches, checks for gone branches, and deletes them or says none to delete"
    git fetch -p
    set goneBranches (git branch -vv | awk '/: gone]/{print $1}')
    if test -z "$goneBranches"
        echo "No branches to delete!"
    else
        git branch -D $goneBranches
    end
end
