folder_num=434
#和restored_commit文件夹放同一级时,只需要改文件夹最大值，不是数量
#output:5_new_repo_re_log.txt && new_repo_re
restored_commits_relative_path="restored_commits_re"
pwdpath=$(pwd)
mkdir 5_new_repo_re
cd 5_new_repo_re
git init
git config user.email "1045839067@qq.com"
git config user.name "hasyu"
#git config gc.auto 0

if [[ $folder_num -lt 9999 ]]; then
    tmp_folder_num=$folder_num
else
    tmp_folder_num=9999
fi


for i in $(seq -f "%04g" 1 $tmp_folder_num)
do
    # 假设你的文件夹在/home/user/commits/下
    folder_path="$pwdpath/$restored_commits_relative_path/$i"
    if [ ! -d "$folder_path" ]; then
        continue
    fi
    # 遍历文件夹中的每个文件
    for file in $(find $folder_path -type f)
    do
        # 获取文件名
        filename=$(basename $file)
        # 检查文件名，如果以"tree_"或"commit_"开头，那么跳过
        if [[ $filename == tree_* ]] || [[ $filename == commit_* ]]; then
            continue
        fi
        # 获取文件的相对路径
        relative_path=$(dirname "${file#$folder_path/}")
        # 创建文件的父目录
        mkdir -p "$relative_path"
        # 将文件复制到新目录
        cp $file "$relative_path/"
        # 将文件添加到Git仓库
        git add "$relative_path/$filename"
    done
    # 创建一个新的commit
    git commit -m "Commit for folder $i">>$pwdpath/5_new_repo_re_log.txt

    # git count-objects -v >> count.txt
    # git count-objects -v | head -n 1 >> count.txt
done

if [[ $folder_num -gt 9999 ]]; then
    for i in $(seq -f "%05g" 10000 $folder_num)
    do
        # 假设你的文件夹在/home/user/commits/下
        folder_path="$pwdpath/$restored_commits_relative_path/$i"
        # 遍历文件夹中的每个文件

        if [ ! -d "$folder_path" ]; then
            continue
        fi
        
        for file in $(find $folder_path -type f)
        do
            # 获取文件名
            filename=$(basename $file)
            # 检查文件名，如果以"tree_"或"commit_"开头，那么跳过
            if [[ $filename == tree_* ]] || [[ $filename == commit_* ]]; then
                continue
            fi
            # 获取文件的相对路径
            relative_path=$(dirname "${file#$folder_path/}")
            # 创建文件的父目录
            mkdir -p "$relative_path"
            # 将文件复制到新目录
            cp $file "$relative_path/"
            # 将文件添加到Git仓库
            git add "$relative_path/$filename"
        done
        # 创建一个新的commit
        git commit -m "Commit for folder $i">>$pwdpath/5_new_repo_re_log.txt
    done
fi
# for i in $(seq -f "%04g" 1 434)
# do
#     # 假设你的文件夹在/home/user/commits/下
#     folder_path="$pwdpath/$restored_commits_relative_path/$i"
#     # 遍历文件夹中的每个文件
#     for file in $(find $folder_path -type f)
#     do
#         # 获取文件名
#         filename=$(basename $file)
#         # 检查文件名，如果以"tree_"或"commit_"开头，那么跳过
#         if [[ $filename == tree_* ]] || [[ $filename == commit_* ]]; then
#             continue
#         fi
#         # 获取文件的相对路径
#         relative_path=$(dirname "${file#$folder_path/}")
#         # 创建文件的父目录
#         mkdir -p "$relative_path"
#         # 将文件复制到新目录
#         cp $file "$relative_path/"
#         # 将文件添加到Git仓库
#         git add "$relative_path/$filename"
#     done
#     # 创建一个新的commit
#     git commit -m "Commit for folder $i">>2_new_repo_log.txt

#     # git count-objects -v >> count.txt
#     # git count-objects -v | head -n 1 >> count.txt
# done



# for i in $(seq -f "%04g" 2 434)
# do
#     # 假设你的文件夹在/home/user/commits/下
#     folder_path="/home/public/WYY/levelDB_Count/levelDB_commit/$i"
#     # 遍历文件夹中的每个文件
#     for file in $(find $folder_path -type f)
#     do
#         # 获取文件名
#         filename=$(basename $file)
#         # 检查文件名，如果以"tree_"或"commit_"开头，那么跳过
#         if [[ $filename == tree_* ]] || [[ $filename == commit_* ]]; then
#             continue
#         fi
#         # 将文件复制到Git仓库
#         cp $file .
#         # 将文件添加到Git仓库
#         git add $filename
#     done
#     # 创建一个新的commit
#     git commit -m "Commit for folder $i"
# done