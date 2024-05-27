#!/bin/bash

# 定义脚本所在目录
script_dir=$(pwd)
ori=leveldb
last_tag_commit="${commit_order[-1]}"

echo "Script directory: $script_dir"

# 读取标签和对应的提交哈希
tag_commits_file="$script_dir/tag_commits.txt"
if [ ! -f "$tag_commits_file" ]; then
    echo "Error: tag_commits.txt not found in $script_dir"
    exit 1
fi

declare -A tag_commits
declare -a commit_order
while read tag commit; do
    tag_commits[$commit]=$tag
    commit_order+=($commit)
done < "$tag_commits_file"

# for commit in "${!tag_commits[@]}"; do
#     echo "Commit: $commit, Tag: ${tag_commits[$commit]}"
# done
# 创建目录来保存结果
mkdir -p "$script_dir/results"

# 原始仓库路径
original_repo="$script_dir/$ori"
if [ ! -d "$original_repo/.git" ]; then
    echo "Error: $original_repo/.git not found"
    exit 1
fi

# 初始化新的测试仓库
test_repo_path="$script_dir/test_repo"
rm -rf "$test_repo_path"
mkdir "$test_repo_path"
cd "$test_repo_path"
git init

# 禁用当前仓库的 delta 压缩
git config repack.useDeltaBaseOffset false

# 记录详细的统计信息
record_stats() {
    local tag=$1
    local tag_commit=$2

    # 启用 delta 压缩并记录开始时间
    git config repack.useDeltaBaseOffset true
    local start_time=$(date +%s)
    git repack -ad --depth=50 --window=50
    local end_time=$(date +%s)
    git config repack.useDeltaBaseOffset false
    local duration=$((end_time - start_time))

    # 记录 .git/objects 文件夹及其子项的大小
    du -sh .git/objects/* > "$script_dir/results/objects_${tag_commit}.txt"

    # 记录所有 delta 压缩对象的大小
    git verify-pack -v .git/objects/pack/*.idx | grep -E "^\w{40}" > "$script_dir/results/delta_objects_${tag_commit}.txt"

    # 记录 delta 压缩使用的时间
    echo "Delta compression time: $duration seconds" > "$script_dir/results/compression_time_${tag_commit}.txt"

    # 记录每个 pack 文件的大小
    du -sh .git/objects/pack/*.pack >> "$script_dir/results/pack_sizes_${tag_commit}.txt"

    # 如果是发布标签，记录相应信息
    if [[ -n "$tag" ]]; then
        echo "Release $tag ($tag_commit):" >> "$script_dir/results/sizes.txt"
        du -sh .git/objects/* >> "$script_dir/results/sizes.txt"
        du -sh .git/objects/pack/*.pack >> "$script_dir/results/sizes.txt"
        echo "Delta compression time: $duration seconds" >> "$script_dir/results/sizes.txt"
    fi
}

# 提取最后一个标签的提交哈希
# last_tag_commit="${commit_order[-1]}"

# 找出最后一个标签之前的所有提交
#git --git-dir="$original_repo/.git" log --pretty=format:"%H" --reverse "$last_tag_commit" > "$script_dir/all_commits.txt"
all_commits=$(git rev-list --reverse HEAD)
#all_commits=( $(cat "$script_dir/all_commits.txt") )

# 遍历每个提交
for commit in "${all_commits[@]}"; do
    echo "Processing commit $commit"

    # 从原始仓库中检出当前提交的内容到测试仓库
    git --git-dir="$original_repo/.git" --work-tree="$test_repo_path" checkout "$commit" -- .

    # 检查是否有新文件
    # if [ -z "$(git status --porcelain)" ]; then
    #     echo "No changes to commit for $commit"
    #     continue
    # fi
    if [ -z "$(git status --porcelain)" ]; then
        if [[ -n "${tag_commits[$commit]}" ]]; then
            record_stats "${tag_commits[$commit]}" "$commit"
        fi
        echo "No changes to commit for $commit"
        continue
    fi
    # 添加所有文件并提交
    git add .
    GIT_COMMITTER_DATE="$(git --git-dir="$original_repo/.git" show -s --format=%ci "$commit")" git commit --date="$(git --git-dir="$original_repo/.git" show -s --format=%ci "$commit")" -m "Commit $commit"

    # 检查当前提交是否是一个标签的提交
    if [[ -n "${tag_commits[$commit]}" ]]; then
        tag="${tag_commits[$commit]}"
        echo "Processing tag $tag at commit $commit"
        record_stats "$tag" "$commit"
    fi
done