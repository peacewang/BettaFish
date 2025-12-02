#!/bin/bash
# BettaFish 部署脚本
# 用途：在服务器上自动化部署 BettaFish 应用

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置变量（需要根据实际情况修改）
PROJECT_DIR="/var/www/bettafish"
SERVICE_NAME="bettafish"
NGINX_CONF_DIR="/etc/tengine/conf.d"
NGINX_CONF_FILE="bettafish.conf"
SYSTEMD_DIR="/etc/systemd/system"
SERVICE_FILE="bettafish.service"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}BettaFish 部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}错误：请使用 root 权限运行此脚本${NC}"
    exit 1
fi

# 1. 检查项目目录
echo -e "${YELLOW}[1/8] 检查项目目录...${NC}"
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}错误：项目目录不存在: $PROJECT_DIR${NC}"
    echo "请先创建目录并上传代码"
    exit 1
fi
echo -e "${GREEN}✓ 项目目录存在${NC}"

# 2. 检查 Python 环境
echo -e "${YELLOW}[2/8] 检查 Python 环境...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误：未找到 python3${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}✓ Python 版本: $PYTHON_VERSION${NC}"

# 3. 创建虚拟环境（如果不存在）
echo -e "${YELLOW}[3/8] 设置 Python 虚拟环境...${NC}"
if [ ! -d "$PROJECT_DIR/.venv" ]; then
    echo "创建虚拟环境..."
    cd "$PROJECT_DIR"
    python3 -m venv .venv
    echo -e "${GREEN}✓ 虚拟环境已创建${NC}"
else
    echo -e "${GREEN}✓ 虚拟环境已存在${NC}"
fi

# 4. 安装依赖
echo -e "${YELLOW}[4/8] 安装 Python 依赖...${NC}"
cd "$PROJECT_DIR"
source .venv/bin/activate
pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo -e "${GREEN}✓ 依赖安装完成${NC}"
else
    echo -e "${RED}警告：未找到 requirements.txt${NC}"
fi

# 5. 安装 Playwright（如果需要）
echo -e "${YELLOW}[5/8] 安装 Playwright 浏览器驱动...${NC}"
if command -v playwright &> /dev/null || [ -f "$PROJECT_DIR/.venv/bin/playwright" ]; then
    playwright install chromium || echo -e "${YELLOW}警告：Playwright 安装失败，可能需要手动安装${NC}"
    echo -e "${GREEN}✓ Playwright 驱动安装完成${NC}"
else
    echo -e "${YELLOW}跳过：Playwright 未安装或不需要${NC}"
fi

# 6. 配置 Systemd 服务
echo -e "${YELLOW}[6/8] 配置 Systemd 服务...${NC}"
if [ -f "$PROJECT_DIR/deployment/$SERVICE_FILE" ]; then
    cp "$PROJECT_DIR/deployment/$SERVICE_FILE" "$SYSTEMD_DIR/$SERVICE_FILE"
    # 更新服务文件中的路径（如果 PROJECT_DIR 不是默认路径）
    if [ "$PROJECT_DIR" != "/var/www/bettafish" ]; then
        sed -i "s|/var/www/bettafish|$PROJECT_DIR|g" "$SYSTEMD_DIR/$SERVICE_FILE"
    fi
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    echo -e "${GREEN}✓ Systemd 服务配置完成${NC}"
else
    echo -e "${RED}警告：未找到服务配置文件${NC}"
fi

# 7. 配置 Tengine/Nginx
echo -e "${YELLOW}[7/8] 配置 Tengine 反向代理...${NC}"
if [ -f "$PROJECT_DIR/deployment/$NGINX_CONF_FILE" ]; then
    cp "$PROJECT_DIR/deployment/$NGINX_CONF_FILE" "$NGINX_CONF_DIR/$NGINX_CONF_FILE"
    # 测试配置
    if tengine -t 2>/dev/null || nginx -t 2>/dev/null; then
        echo -e "${GREEN}✓ Tengine 配置语法正确${NC}"
        echo -e "${YELLOW}请手动执行 'tengine -s reload' 或 'systemctl reload tengine' 重载配置${NC}"
    else
        echo -e "${RED}警告：Tengine 配置语法检查失败，请手动检查${NC}"
    fi
else
    echo -e "${RED}警告：未找到 Tengine 配置文件${NC}"
fi

# 8. 检查 .env 文件
echo -e "${YELLOW}[8/8] 检查配置文件...${NC}"
if [ ! -f "$PROJECT_DIR/.env" ]; then
    if [ -f "$PROJECT_DIR/deployment/env.template" ]; then
        echo -e "${YELLOW}未找到 .env 文件，从模板创建...${NC}"
        cp "$PROJECT_DIR/deployment/env.template" "$PROJECT_DIR/.env"
        echo -e "${RED}⚠ 请编辑 $PROJECT_DIR/.env 文件，填写实际配置值${NC}"
    else
        echo -e "${RED}错误：未找到 .env 文件或模板${NC}"
    fi
else
    echo -e "${GREEN}✓ .env 文件存在${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}部署脚本执行完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}下一步操作：${NC}"
echo "1. 编辑 $PROJECT_DIR/.env 文件，填写所有必需的配置"
echo "2. 创建数据库并配置连接信息"
echo "3. 启动服务: systemctl start $SERVICE_NAME"
echo "4. 检查服务状态: systemctl status $SERVICE_NAME"
echo "5. 重载 Tengine: tengine -s reload"
echo "6. 访问: https://www.peacewang.com/bettafish/"

