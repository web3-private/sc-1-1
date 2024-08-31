#!/bin/bash

# 创建一个临时文件来存储合并的内容
TEMP_FILE="flattened/TokenTempAll.sol"

# 清空临时文件
> $TEMP_FILE

# 遍历 contracts 文件夹中的所有 .sol 文件
for file in contracts/*.sol; do
    # 使用 hardhat flatten 命令合并每个文件，并追加到临时文件中
    npx hardhat flatten $file >> $TEMP_FILE
    echo "\n" >> $TEMP_FILE # 添加一个空行来分隔文件内容
done

echo "All files have been flattened into $TEMP_FILE"
