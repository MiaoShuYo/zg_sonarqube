#!/bin/bash

# 修复gradlew脚本的权限和换行符问题

echo "🔧 修复gradlew脚本..."

# 检查gradlew文件是否存在
if [ ! -f "gradlew" ]; then
    echo "❌ gradlew文件不存在"
    exit 1
fi

echo "📋 原始文件信息："
ls -la gradlew
file gradlew

# 修复权限
echo "🔐 修复执行权限..."
chmod +x gradlew

# 修复换行符（如果dos2unix可用）
if command -v dos2unix &> /dev/null; then
    echo "🔄 修复换行符..."
    dos2unix gradlew
elif command -v sed &> /dev/null; then
    echo "🔄 使用sed修复换行符..."
    sed -i 's/\r$//' gradlew
else
    echo "⚠️  无法修复换行符，但继续执行..."
fi

# 验证修复结果
echo "✅ 修复后的文件信息："
ls -la gradlew
file gradlew

# 测试gradlew是否可执行
echo "🧪 测试gradlew执行..."
if ./gradlew --version &> /dev/null; then
    echo "✅ gradlew修复成功！"
    ./gradlew --version
else
    echo "❌ gradlew仍然无法执行"
    echo "尝试手动修复..."
    
    # 尝试重新下载gradlew
    echo "📥 尝试重新下载gradlew..."
    curl -o gradlew https://raw.githubusercontent.com/gradle/gradle/master/gradlew
    chmod +x gradlew
    
    if ./gradlew --version &> /dev/null; then
        echo "✅ gradlew重新下载成功！"
    else
        echo "❌ 所有修复方法都失败了"
        exit 1
    fi
fi

echo "✅ 修复完成！" 