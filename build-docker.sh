#!/bin/bash

# SonarQube Docker镜像构建脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认值
IMAGE_NAME="zgsonarqube"
TAG="latest"
PUSH=false

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -n, --name NAME     镜像名称 (默认: zgsonarqube)"
    echo "  -t, --tag TAG       镜像标签 (默认: latest)"
    echo "  -p, --push          构建后推送到仓库"
    echo "  -h, --help          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                    # 构建默认镜像"
    echo "  $0 -n my-zgsonar -t v1.0  # 构建自定义名称和标签的镜像"
    echo "  $0 -p                 # 构建并推送镜像"
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo -e "${GREEN}开始构建SonarQube Docker镜像...${NC}"
echo -e "${YELLOW}镜像名称: ${FULL_IMAGE_NAME}${NC}"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker未安装或不在PATH中${NC}"
    exit 1
fi

# 检查Docker是否运行
if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker守护进程未运行${NC}"
    exit 1
fi

# 构建镜像
echo -e "${GREEN}构建Docker镜像...${NC}"
docker build -t "${FULL_IMAGE_NAME}" .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}镜像构建成功!${NC}"
    
    # 显示镜像信息
    echo -e "${YELLOW}镜像信息:${NC}"
    docker images "${FULL_IMAGE_NAME}"
    
    if [ "$PUSH" = true ]; then
        echo -e "${GREEN}推送镜像到仓库...${NC}"
        docker push "${FULL_IMAGE_NAME}"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}镜像推送成功!${NC}"
        else
            echo -e "${RED}镜像推送失败!${NC}"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}构建完成!${NC}"
    echo -e "${YELLOW}运行命令:${NC}"
    echo "  docker run -p 9000:9000 ${FULL_IMAGE_NAME}"
    echo "  或使用docker-compose:"
    echo "  docker-compose up -d"
else
    echo -e "${RED}镜像构建失败!${NC}"
    exit 1
fi 