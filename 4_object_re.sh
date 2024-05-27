ori=leveldb
# 同一级目录下的仓库名，唯一需要改的量
#output:restored_commits

# 特定的提交哈希值，全部时不需要加
# target_commit="de46c33745f5e2ad594c72f2cf5f490861b16ce1" #.21
# 创建保存文件的根目录
mkdir -p restored_commits_re
pwdpath=$(pwd)
valid_counts=$(cat 3_commit_vaild.txt)
cd $ori
declare -A tree_hashtable
# 获取 commit 列表，按照时间顺序，包含所有分支和标签
# commits=$(git rev-list --reverse --all)
commits=$(git rev-list --reverse HEAD)
# 变量保存上一个 commit
prev_commit=""
counter=1

# 递归函数提取并保存 tree 对象
extract_tree() {
    local tree_hash=$1
    local output_dir=$2
    local pretree_name=$3

    # 保存 tree 对象
    
    key="$tree_hash"
    value="myvalue"

# 检查键是否存在
    if [[ ! -v tree_hashtable["$key"] ]]; then
        # 键不存在，给它赋值
        tree_hashtable["$key"]=$value
        git cat-file -p $tree_hash > $output_dir/tree_$pretree_name.txt
     #else
        # 键存在，调试专用
        #echo "Key $key already exists"
    fi

    # 获取 tree 对象中的子对象
    objects=$(git ls-tree $tree_hash | awk '{print $2, $3, $4}')
    
    while read -r type hash name; do
        if [ "$type" == "tree" ]; then
            # 如果是子 tree 对象，递归处理
            extract_tree $hash $output_dir $name
        fi
    done <<< "$objects"
}


for commit in $commits; do

    formatted_counter=$(printf "%04d" $counter)
    # 如果 formatted_counter 不在 valid_counts 中，跳过当前循环
    if ! echo "$valid_counts" | grep -q "^$formatted_counter$"; then
        counter=$((counter + 1))
        continue
    fi

    # 创建按顺序编号的目录以保存每个 commit 的内容
    commit_dir=$pwdpath/restored_commits_re/$(printf "%04d" $counter)
    #_$commit
    mkdir -p $commit_dir

    # 获取 commit 对象的内容并保存
    str=$(git cat-file -p $commit) 

    #git cat-file commit $commit > $commit_dir/commit_object.txt
    echo "$str" >> $commit_dir/commit_object.txt

    # 获取 tree 对象哈希值
    #tree_hash=$(git cat-file commit $commit | grep '^tree' | awk '{print $2}')
    tree_hash=$(echo "$str" | grep '^tree' | awk '{print $2}')
    
    tree_name=$ori
    # 递归提取并保存 tree 对象
    extract_tree $tree_hash $commit_dir $tree_name

    if [ -z "$prev_commit" ]; then
        # 如果是第一个 commit，获取所有文件
        files=$(git ls-tree -r --name-only $commit)
        prev_commit=$commit

    else
        prev_commit=$(echo "$str" | grep '^parent' | awk '{print $2}')
        # 获取这个 commit 相对于上一个 commit 的变更文件列表
        files=$(git diff --name-only $prev_commit $commit)  #git diff --name-only会显示含路径的，更改的文件（blob），但不显示tree
    fi

    for file in $files; do
        # 获取文件的路径并创建必要的目录
        mkdir -p $commit_dir/$(dirname $file)
        
        # 提取文件内容并保存
        git show $commit:$file > $commit_dir/$file
    done

    # 更新上一个 commit
    # prev_commit=$commit
    # 递增计数器
    counter=$((counter + 1))

    # 检查是否达到特定的提交哈希值
    # if [ "$commit" == "$target_commit" ]; then
    #     echo "Reached target commit: $target_commit"
    #     break
    # fi
done