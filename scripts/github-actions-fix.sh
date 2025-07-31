#!/bin/bash
# GitHub Actions专用修复脚本
echo "🔧 GitHub Actions构建修复脚本..."

# 检查当前目录
echo "📁 当前目录: $(pwd)"
echo "📁 目录内容:"
ls -la

# 检查gradlew文件
echo "🔍 检查gradlew文件..."
if [ -f "./gradlew" ]; then
    echo "✅ gradlew文件存在"
    echo "📄 gradlew文件信息:"
    ls -la ./gradlew
    echo "📄 gradlew前10行:"
    head -10 ./gradlew
else
    echo "❌ gradlew文件不存在"
    exit 1
fi

# 修复gradlew权限
echo "🔧 修复gradlew权限..."
chmod +x ./gradlew

# 修复换行符（如果存在dos2unix）
if command -v dos2unix &> /dev/null; then
    echo "🔧 修复换行符..."
    dos2unix ./gradlew
fi

# 再次检查权限
echo "🔍 修复后检查..."
ls -la ./gradlew

# 测试gradlew执行
echo "🧪 测试gradlew执行..."
if ./gradlew --version; then
    echo "✅ gradlew执行成功"
else
    echo "❌ gradlew执行失败"
    exit 1
fi

echo "🎉 修复完成！" 