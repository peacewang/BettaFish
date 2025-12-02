# BettaFish 部署文件说明

本目录包含将 BettaFish 部署到生产环境所需的所有配置文件。

## 📁 文件说明

### 1. `bettafish.service`
Systemd 服务配置文件，用于将 BettaFish 作为系统服务运行。

**使用方法：**
```bash
# 复制到系统目录
sudo cp bettafish.service /etc/systemd/system/

# 修改服务文件中的路径（如需要）
sudo nano /etc/systemd/system/bettafish.service

# 重新加载 systemd
sudo systemctl daemon-reload

# 启用服务（开机自启）
sudo systemctl enable bettafish

# 启动服务
sudo systemctl start bettafish

# 查看服务状态
sudo systemctl status bettafish
```

### 2. `bettafish.conf`
Tengine/Nginx 反向代理配置文件，用于将外部请求转发到 Flask 应用。

**使用方法：**
```bash
# 复制到 Tengine 配置目录
sudo cp bettafish.conf /etc/tengine/conf.d/

# 测试配置语法
sudo tengine -t

# 重载配置
sudo tengine -s reload
# 或
sudo systemctl reload tengine
```

**配置说明：**
- 主应用路由：`/bettafish/` → `http://127.0.0.1:5000`
- Query Engine：`/bettafish/query/` → `http://127.0.0.1:8503`
- Media Engine：`/bettafish/media/` → `http://127.0.0.1:8502`
- Insight Engine：`/bettafish/insight/` → `http://127.0.0.1:8501`

### 3. `.env.template`
环境变量配置模板，包含所有必需的配置项。

**使用方法：**
```bash
# 复制模板文件
cp .env.template ../.env

# 编辑配置文件
nano ../.env

# 填写所有必需的配置值
```

**重要配置项：**
- 数据库连接信息
- LLM API 密钥和端点
- Flask 应用端口

### 4. `deploy.sh`
自动化部署脚本，用于一键部署 BettaFish。

**使用方法：**
```bash
# 添加执行权限
chmod +x deploy.sh

# 运行部署脚本（需要 root 权限）
sudo ./deploy.sh
```

**脚本功能：**
1. 检查项目目录
2. 检查 Python 环境
3. 创建虚拟环境
4. 安装 Python 依赖
5. 安装 Playwright 驱动
6. 配置 Systemd 服务
7. 配置 Tengine 反向代理
8. 检查配置文件

## 🚀 部署流程

### 步骤 1：准备服务器环境
```bash
# 确保已安装 Python 3.9+
python3 --version

# 确保已安装 PostgreSQL 或 MySQL
# PostgreSQL
psql --version
# MySQL
mysql --version

# 确保已安装 Tengine/Nginx
tengine -v
```

### 步骤 2：上传代码
```bash
# 在服务器上创建项目目录
sudo mkdir -p /var/www/bettafish
sudo chown $USER:$USER /var/www/bettafish

# 上传代码（使用 Git 或文件传输）
cd /var/www/bettafish
git clone <repository_url> .
# 或使用 scp/rsync 上传文件
```

### 步骤 3：运行部署脚本
```bash
cd /var/www/bettafish/deployment
sudo ./deploy.sh
```

### 步骤 4：配置环境变量
```bash
# 编辑 .env 文件
nano /var/www/bettafish/.env

# 填写所有必需的配置值
```

### 步骤 5：创建数据库
```bash
# PostgreSQL
sudo -u postgres psql
CREATE DATABASE bettafish;
CREATE USER bettafish WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE bettafish TO bettafish;
\q

# MySQL
mysql -u root -p
CREATE DATABASE bettafish CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'bettafish'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON bettafish.* TO 'bettafish'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 步骤 6：启动服务
```bash
# 启动 BettaFish 服务
sudo systemctl start bettafish

# 检查服务状态
sudo systemctl status bettafish

# 查看日志
sudo journalctl -u bettafish -f
```

### 步骤 7：重载 Tengine
```bash
# 测试配置
sudo tengine -t

# 重载配置
sudo tengine -s reload
```

### 步骤 8：测试访问
访问 `https://www.peacewang.com/bettafish/` 验证部署是否成功。

## 🔧 常见问题

### 问题 1：服务启动失败
**检查：**
```bash
# 查看服务日志
sudo journalctl -u bettafish -n 50

# 检查配置文件
cat /var/www/bettafish/.env

# 手动测试启动
cd /var/www/bettafish
source .venv/bin/activate
python app.py
```

### 问题 2：数据库连接失败
**检查：**
- 数据库服务是否运行
- 数据库用户和密码是否正确
- 数据库是否已创建
- 防火墙是否允许连接

### 问题 3：Tengine 配置错误
**检查：**
```bash
# 测试配置语法
sudo tengine -t

# 查看错误日志
sudo tail -f /var/log/tengine/error.log
```

### 问题 4：端口被占用
**检查：**
```bash
# 查看端口占用
sudo netstat -tulpn | grep :5000

# 或使用 ss
sudo ss -tulpn | grep :5000
```

## 📝 注意事项

1. **安全性**：
   - `.env` 文件包含敏感信息，不要提交到 Git
   - 确保服务仅监听 localhost（127.0.0.1）
   - 使用 HTTPS 访问

2. **资源限制**：
   - BettaFish 是资源密集型应用
   - 建议至少 4GB 内存
   - 建议至少 10GB 磁盘空间

3. **日志管理**：
   - 日志文件位于 `/var/www/bettafish/logs/`
   - 建议配置日志轮转
   - 定期清理旧日志

4. **备份**：
   - 定期备份数据库
   - 定期备份配置文件
   - 定期备份生成的报告

## 🔗 相关文档

- [BettaFish README](../README.md)
- [个人网站部署文档](../../peaceportal/readme.md)

