#!/bin/bash

# 快速修复脚本 - 使用最小化Dockerfile

echo "🚀 快速修复Docker构建问题..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装"
    exit 1
fi

echo "✅ Docker已安装"

# 使用最小化Dockerfile构建
echo "🏗️  使用最小化Dockerfile构建..."
docker build -f Dockerfile.minimal -t sonarqube-quick .

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "镜像信息："
    docker images sonarqube-quick
    
    echo ""
    echo "🎉 构建完成！"
    echo "运行命令："
    echo "  docker run -p 9000:9000 sonarqube-quick"
else
    echo "❌ 构建失败，退出代码: $BUILD_EXIT_CODE"
    echo ""
    echo "💡 尝试其他解决方案："
    echo "  1. 使用简化版Dockerfile: docker build -f Dockerfile.simple -t sonarqube ."
    echo "  2. 运行调试脚本: ./scripts/build-debug.sh"
    echo "  3. 修复gradlew: ./scripts/fix-gradlew.sh"
fi 