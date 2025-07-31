#!/bin/bash

# GitHub Security功能检查脚本

echo "🔍 检查GitHub仓库安全功能..."

# 检查仓库可见性
echo "📋 仓库信息："
echo "   - 仓库名称: $GITHUB_REPOSITORY"
echo "   - 仓库可见性: $GITHUB_REPOSITORY_VISIBILITY"
echo "   - 事件类型: $GITHUB_EVENT_NAME"

# 检查权限
echo ""
echo "🔐 权限检查："
if [ "$GITHUB_REPOSITORY_VISIBILITY" = "public" ]; then
    echo "   ✅ 公共仓库 - Code Scanning应该可用"
else
    echo "   ⚠️  私有仓库 - 需要GitHub Advanced Security许可证"
fi

# 检查GitHub Token权限
echo ""
echo "🎫 Token权限检查："
if [ -n "$GITHUB_TOKEN" ]; then
    echo "   ✅ GITHUB_TOKEN已设置"
else
    echo "   ❌ GITHUB_TOKEN未设置"
fi

# 检查必要的Secrets
echo ""
echo "🔑 Secrets检查："
if [ -n "$DOCKERHUB_USERNAME" ] && [ -n "$DOCKERHUB_TOKEN" ]; then
    echo "   ✅ Docker Hub凭据已配置"
else
    echo "   ⚠️  Docker Hub凭据未配置"
fi

# 提供建议
echo ""
echo "💡 建议："

if [ "$GITHUB_REPOSITORY_VISIBILITY" != "public" ]; then
    echo "   1. 将仓库设为公共仓库以启用免费的安全功能"
    echo "   2. 或升级到GitHub Pro/Enterprise以在私有仓库中使用安全功能"
fi

echo "   3. 确保工作流文件包含必要的权限配置"
echo "   4. 检查GitHub Actions设置中的权限"

echo ""
echo "📚 相关文档："
echo "   - GitHub Advanced Security: https://docs.github.com/en/github/getting-started-with-github/learning-about-github/about-github-advanced-security"
echo "   - Code Scanning: https://docs.github.com/en/code-security/code-scanning"
echo "   - GitHub Pricing: https://github.com/pricing"

echo ""
echo "✅ 检查完成！" 