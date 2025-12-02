# BettaFish 部署指南

本文档详细说明如何将 BettaFish 部署到生产环境（PeaceWang 个人网站）。

## 📋 部署前准备

### 1. 服务器环境要求

- **操作系统**：Linux (CentOS/Alibaba Cloud Linux/Ubuntu)
- **Python 版本**：3.9 或更高
- **数据库**：PostgreSQL 15+ 或 MySQL 8.0+
- **内存**：建议至少 4GB
- **磁盘空间**：建议至少 10GB
- **网络**：可访问外部 API（LLM 服务）

### 2. 需要确认的配置参数

在开始部署前，请准备以下信息：

#### 2.1 数据库配置
- [ ] 数据库类型：PostgreSQL 或 MySQL
- [ ] 数据库主机地址
- [ ] 数据库端口
- [ ] 数据库名称
- [ ] 数据库用户名
- [ ] 数据库密码

#### 2.2 LLM API 配置
需要为以下 Agent 配置 API 密钥：

- [ ] **Insight Engine**：推荐 Kimi (https://platform.moonshot.cn/)
- [ ] **Media Engine**：推荐 Gemini (https://aihubmix.com/?aff=8Ds9)
- [ ] **Query Engine**：推荐 DeepSeek (https://www.deepseek.com/)
- [ ] **Report Engine**：推荐 Gemini (https://aihubmix.com/?aff=8Ds9)
- [ ] **MindSpider**：推荐 DeepSeek
- [ ] **Forum Host**：推荐 Qwen (https://www.aliyun.com/product/bailian)
- [ ] **Keyword Optimizer**：推荐 Qwen

#### 2.3 网络搜索 API（可选）
- [ ] **Tavily API**：https://www.tavily.com/
- [ ] **Bocha API**：https://open.bochaai.com/

#### 2.4 应用端口配置
- [ ] Flask 主应用端口（默认：5000）
- [ ] 路由路径（默认：`/bettafish/`）

---

## 🚀 部署步骤

### 步骤 1：上传代码到服务器

```bash
# 在服务器上创建项目目录
sudo mkdir -p /var/www/bettafish
sudo chown $USER:$USER /var/www/bettafish

# 方式一：使用 Git Clone（推荐）
cd /var/www/bettafish
git clone <repository_url> .

# 方式二：使用文件传输（scp/rsync）
# 在本地执行
scp -r BettaFish/* user@server:/var/www/bettafish/
```

### 步骤 2：运行自动化部署脚本

```bash
cd /var/www/bettafish/deployment
chmod +x deploy.sh
sudo ./deploy.sh
```

部署脚本会自动完成：
- ✅ 检查 Python 环境
- ✅ 创建虚拟环境
- ✅ 安装 Python 依赖
- ✅ 安装 Playwright 驱动
- ✅ 配置 Systemd 服务
- ✅ 配置 Tengine 反向代理
- ✅ 创建 .env 配置文件模板

### 步骤 3：配置环境变量

```bash
# 编辑 .env 文件
nano /var/www/bettafish/.env
```

根据 `deployment/env.template` 模板，填写所有必需的配置值：

```bash
# 数据库配置
DB_DIALECT=postgresql  # 或 mysql
DB_HOST=localhost
DB_PORT=5432  # PostgreSQL 默认 5432，MySQL 默认 3306
DB_USER=bettafish
DB_PASSWORD=your_actual_password
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# Flask 配置
HOST=127.0.0.1
PORT=5000

# LLM API 配置（填写实际的 API 密钥）
INSIGHT_ENGINE_API_KEY=sk-xxx
MEDIA_ENGINE_API_KEY=sk-xxx
QUERY_ENGINE_API_KEY=sk-xxx
REPORT_ENGINE_API_KEY=sk-xxx
# ... 其他 API 密钥
```

### 步骤 4：创建数据库

#### PostgreSQL

```bash
sudo -u postgres psql

# 在 psql 中执行
CREATE DATABASE bettafish;
CREATE USER bettafish WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE bettafish TO bettafish;
\q
```

#### MySQL

```bash
mysql -u root -p

# 在 MySQL 中执行
CREATE DATABASE bettafish CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'bettafish'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON bettafish.* TO 'bettafish'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 步骤 5：配置 Tengine 反向代理

```bash
# 复制配置文件
sudo cp /var/www/bettafish/deployment/bettafish.conf /etc/tengine/conf.d/

# 测试配置语法
sudo tengine -t

# 如果测试通过，重载配置
sudo tengine -s reload
# 或
sudo systemctl reload tengine
```

### 步骤 6：启动服务

```bash
# 启动 BettaFish 服务
sudo systemctl start bettafish

# 设置开机自启
sudo systemctl enable bettafish

# 检查服务状态
sudo systemctl status bettafish

# 查看实时日志
sudo journalctl -u bettafish -f
```

### 步骤 7：验证部署

1. **检查服务状态**
   ```bash
   sudo systemctl status bettafish
   ```

2. **检查端口监听**
   ```bash
   sudo netstat -tulpn | grep :5000
   ```

3. **访问应用**
   打开浏览器访问：`https://www.peacewang.com/bettafish/`

4. **检查日志**
   ```bash
   # 系统日志
   sudo journalctl -u bettafish -n 50
   
   # 应用日志
   tail -f /var/www/bettafish/logs/*.log
   ```

---

## 🔧 常见问题排查

### 问题 1：服务启动失败

**检查步骤：**

```bash
# 1. 查看服务日志
sudo journalctl -u bettafish -n 100

# 2. 检查配置文件
cat /var/www/bettafish/.env

# 3. 手动测试启动
cd /var/www/bettafish
source .venv/bin/activate
python app.py
```

**可能原因：**
- 配置文件错误
- 数据库连接失败
- 端口被占用
- Python 依赖缺失

### 问题 2：数据库连接失败

**检查步骤：**

```bash
# 1. 检查数据库服务是否运行
# PostgreSQL
sudo systemctl status postgresql

# MySQL
sudo systemctl status mysql

# 2. 测试数据库连接
# PostgreSQL
psql -h localhost -U bettafish -d bettafish

# MySQL
mysql -h localhost -u bettafish -p bettafish
```

**可能原因：**
- 数据库服务未启动
- 用户名或密码错误
- 数据库未创建
- 防火墙阻止连接

### 问题 3：Tengine 配置错误

**检查步骤：**

```bash
# 1. 测试配置语法
sudo tengine -t

# 2. 查看错误日志
sudo tail -f /var/log/tengine/error.log

# 3. 检查配置文件路径
ls -la /etc/tengine/conf.d/bettafish.conf
```

**可能原因：**
- 配置文件语法错误
- 路径配置错误
- 端口冲突

### 问题 4：LLM API 调用失败

**检查步骤：**

```bash
# 1. 检查 API 密钥配置
grep API_KEY /var/www/bettafish/.env

# 2. 测试网络连接
curl https://api.moonshot.cn/v1/models

# 3. 查看应用日志
tail -f /var/www/bettafish/logs/*.log | grep -i error
```

**可能原因：**
- API 密钥无效或过期
- 网络连接问题
- API 服务商限制

---

## 📝 运维命令速查

### 服务管理

```bash
# 启动服务
sudo systemctl start bettafish

# 停止服务
sudo systemctl stop bettafish

# 重启服务
sudo systemctl restart bettafish

# 查看服务状态
sudo systemctl status bettafish

# 查看服务日志
sudo journalctl -u bettafish -f
sudo journalctl -u bettafish -n 100
```

### 日志管理

```bash
# 查看应用日志
tail -f /var/www/bettafish/logs/*.log

# 查看特定日志文件
tail -f /var/www/bettafish/logs/insight_engine.log

# 清理旧日志（谨慎操作）
find /var/www/bettafish/logs -name "*.log" -mtime +30 -delete
```

### 配置更新

```bash
# 更新代码
cd /var/www/bettafish
git pull

# 更新依赖（如有新依赖）
source .venv/bin/activate
pip install -r requirements.txt

# 重启服务
sudo systemctl restart bettafish
```

### Tengine 配置

```bash
# 测试配置
sudo tengine -t

# 重载配置
sudo tengine -s reload

# 查看配置
cat /etc/tengine/conf.d/bettafish.conf
```

---

## 🔒 安全建议

1. **配置文件安全**
   - `.env` 文件包含敏感信息，不要提交到 Git
   - 设置适当的文件权限：`chmod 600 /var/www/bettafish/.env`

2. **端口安全**
   - 应用仅监听 `127.0.0.1`（localhost）
   - 通过 Tengine 反向代理对外提供服务
   - 使用 HTTPS 加密传输

3. **数据库安全**
   - 使用强密码
   - 限制数据库用户权限
   - 仅允许 localhost 连接

4. **日志管理**
   - 定期清理旧日志
   - 配置日志轮转
   - 避免在日志中记录敏感信息

---

## 📚 相关文档

- [BettaFish README](./README.md)
- [部署文件说明](./deployment/README.md)
- [个人网站部署文档](../peaceportal/readme.md)

---

## 🆘 获取帮助

如遇到问题，请：

1. 查看本文档的"常见问题排查"部分
2. 查看应用日志和系统日志
3. 参考 BettaFish 官方文档：https://github.com/666ghj/BettaFish
4. 提交 Issue 或联系维护者

