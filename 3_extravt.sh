#!/bin/bash

# 输入文件名
input_file="2_new_repo_log.txt"

# 使用awk命令提取最后一列
awk '/Commit for folder/ {print $NF}' $input_file>>3_commit_vaild.txt