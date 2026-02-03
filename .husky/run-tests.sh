#!/bin/bash
# 自动测试脚本 - 在提交前运行所有测试

echo "🔍 自动测试流程启动..."

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 运行代码检查
echo ""
echo "📋 步骤1: 运行代码检查..."
echo "------------------------------"

if command -v hvigorw &> /dev/null; then
    hvigorw code-lint --parallel
    LINT_EXIT_CODE=$?
    
    if [ $LINT_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}❌ 代码检查失败！请修复问题后再提交。${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ 代码检查通过${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  hvigorw 未找到，跳过代码检查${NC}"
fi

# 运行单元测试
echo ""
echo "🧪 步骤2: 运行单元测试..."
echo "------------------------------"

if command -v hvigorw &> /dev/null; then
    hvigorw test --parallel
    TEST_EXIT_CODE=$?
    
    if [ $TEST_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}❌ 单元测试失败！请修复测试后再提交。${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ 单元测试通过${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  hvigorw 未找到，跳过单元测试${NC}"
fi

# 运行构建测试
echo ""
echo "🏗️ 步骤3: 运行构建测试..."
echo "------------------------------"

if command -v hvigorw &> /dev/null; then
    hvigorw assembleHap --parallel
    BUILD_EXIT_CODE=$?
    
    if [ $BUILD_EXIT_CODE -ne 0 ]; then
        echo -e "${RED}❌ 构建失败！请修复构建错误后再提交。${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ 构建测试通过${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  hvigorw 未找到，跳过构建测试${NC}"
fi

echo ""
echo -e "${GREEN}🎉 所有检查通过！可以进行提交。${NC}"
echo ""

exit 0
