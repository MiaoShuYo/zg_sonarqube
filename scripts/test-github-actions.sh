#!/bin/bash
# GitHub Actions测试脚本
echo "🧪 测试GitHub Actions构建..."

# 检查必要文件
echo "📁 检查必要文件..."
if [ ! -f "Dockerfile.github-actions-simple" ]; then
    echo "❌ Dockerfile.github-actions-simple 不存在"
    exit 1
fi

if [ ! -f "gradlew" ]; then
    echo "❌ gradlew 不存在"
    exit 1
fi

# 检查gradlew权限
echo "🔍 检查gradlew权限..."
ls -la gradlew

# 修复gradlew权限
echo "🔧 修复gradlew权限..."
chmod +x gradlew

# 测试本地构建（可选）
if command -v docker &> /dev/null; then
    echo "🐳 测试Docker构建..."
    docker build -f Dockerfile.github-actions-simple -t sonarqube-test .
    if [ $? -eq 0 ]; then
        echo "✅ Docker构建成功"
    else
        echo "❌ Docker构建失败"
    fi
else
    echo "⚠️  Docker未安装，跳过本地测试"
fi

echo "🎉 测试完成！" 