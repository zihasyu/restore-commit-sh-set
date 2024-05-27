restored_commits_relative_path="restored_commits"
pwdpath=$(pwd)
mkdir commit_tar_ori
topath="commit_tar_ori"

for i in $(seq -f "%04g" 1 434)
do
    folder_path="$pwdpath/$restored_commits_relative_path/$i"
    if [ ! -d "$folder_path" ]; then
        continue
    fi
    tar -cf "$pwdpath/$topath/$i.tar" -C "$folder_path" .
    # ...
done