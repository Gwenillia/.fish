function gitRtm -d "Will merge specific branch to master"
  set branch $argv[1]
  set target_branch $argv[2]
  
  if test -z "$branch"
    echo "Usage: gitRtm <branch> [target_branch]"
    return 1
  end

  if test -z "$target_branch"
    set target_branch "master"
  end

  echo "Checking out $branch..."
  g checkout $branch
  g pull

  echo "Checking out $target_branch..."
  g checkout $target_branch
  g pull

  echo "Merging $branch into $target_branch..."
  g merge $branch
  g push

  echo "Done."
end

