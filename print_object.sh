
pwdpath=$(pwd)
repo=5_new_repo_re
cd $pwdpath/$repo
objects=$(git rev-list --objects HEAD)

for object in $objects; do
    echo -n "$object "
    git cat-file -t $object
done