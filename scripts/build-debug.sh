#!/bin/bash

# Docker构建调试脚本

echo "🔍 开始Docker构建调试..."

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker未安装"
    exit 1
fi

echo "✅ Docker已安装"

# 检查D可用内存
echo "📊 系统内存信息："
free -h

# Params
IMAGE_NAME="sonarqube-debug"
TAG="latest"

echo ""
echo "🏗️  开始构建Docker镜像..."

# 构建镜像并显示详细输出
docker build \
    --progress=plain \
    --no-cache \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    -t "${IMAGE_NAME}:${TAG}" \
    . 2>&1 | tee build.log

BUILD_EXIT_CODE=$?

echo ""
echo "📋 构建结果："
if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ 构建成功！"
    echo "镜像信息："
    docker images "${IMAGE_NAME}:${TAG}"
else
    echo "❌ 构建失败，退出代码: $BUILD_EXIT_CODE"
    echo ""
    echo "🔍 分析构建日志..."
    
    # 检查常见错误
    if grep -q "out of memory" build.log; then
        echo "💡 内存不足错误，建议："
        echo "   - 增加Docker内存限制"
        echo "   - 减少并行构建任务"
        echo "   - 使用更大的构建机器"
    fi
    
    if grep -q "network" build.log; then
        echo "💡 网络错误，建议："
        echo "   - 检查网络连接"
        echo "   - 使用代理或镜像源"
        echo "   - 重试构建"
    fi
    
    if grep -q "gradle" build.log; then
        echo "💡 Gradle错误，建议："
        echo "   - 清理Gradle缓存"
        echo "   - 检查依赖下载"
        echo "   - 增加内存配置"
    fi
    
    echo ""
    echo "📄 完整构建日志已保存到 build.log"
fi

echo ""
echo "🧹 清理临时文件..."
rm -f build.log

echo "✅ 调试完成！" 