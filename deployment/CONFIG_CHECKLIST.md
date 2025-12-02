# BettaFish 部署配置确认清单

本文档列出部署 BettaFish 时需要您确认的所有配置项。请仔细填写每一项。

---

## 🔴 必需配置（部署前必须填写）

### 1. 数据库配置

请选择并填写：

- [ ] **数据库类型**：`postgresql` 或 `mysql`
- [ ] **数据库主机**：`localhost` 或 `127.0.0.1`（如使用 Docker 请填写容器名）
- [ ] **数据库端口**：
  - PostgreSQL：`5432`
  - MySQL：`3306`
- [ ] **数据库名称**：`bettafish`（或自定义）
- [ ] **数据库用户名**：`bettafish`（或自定义）
- [ ] **数据库密码**：`_________________`（请填写强密码）

**决策问题**：
- 是否复用现有的 MySQL 数据库？还是新建数据库？
- 如果新建，选择 PostgreSQL 还是 MySQL？

---

### 2. Flask 应用配置

- [ ] **监听地址**：`127.0.0.1`（建议，仅本地访问）
- [ ] **应用端口**：`5000`（建议，或自定义其他端口）

**注意**：应用仅监听 localhost，通过 Tengine 反向代理对外提供服务。

---

### 3. LLM API 配置

请为以下每个 Agent 填写 API 密钥和配置：

#### 3.1 Insight Engine（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://api.moonshot.cn/v1`（Kimi 推荐）
- [ ] **模型名称**：`kimi-k2-0711-preview`（或自定义）

**推荐服务商**：Kimi (https://platform.moonshot.cn/)

#### 3.2 Media Engine（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://aihubmix.com/v1`（推荐）
- [ ] **模型名称**：`gemini-2.5-pro`（或自定义）

**推荐服务商**：Gemini 中转 (https://aihubmix.com/?aff=8Ds9)

#### 3.3 Query Engine（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://api.deepseek.com`（推荐）
- [ ] **模型名称**：`deepseek-chat`（或自定义）

**推荐服务商**：DeepSeek (https://www.deepseek.com/)

#### 3.4 Report Engine（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://aihubmix.com/v1`（推荐）
- [ ] **模型名称**：`gemini-2.5-pro`（或自定义）

**推荐服务商**：Gemini 中转 (https://aihubmix.com/?aff=8Ds9)

#### 3.5 MindSpider（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://api.deepseek.com`（推荐）
- [ ] **模型名称**：`deepseek-reasoner`（或自定义）

**推荐服务商**：DeepSeek (https://www.deepseek.com/)

#### 3.6 Forum Host（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://dashscope.aliyuncs.com/compatible-mode/v1`（推荐）
- [ ] **模型名称**：`qwen-plus`（或自定义）

**推荐服务商**：Qwen (https://www.aliyun.com/product/bailian)

#### 3.7 Keyword Optimizer（必需）
- [ ] **API 密钥**：`_________________`
- [ ] **Base URL**：`https://dashscope.aliyuncs.com/compatible-mode/v1`（推荐）
- [ ] **模型名称**：`qwen-plus`（或自定义）

**推荐服务商**：Qwen (https://www.aliyun.com/product/bailian)

---

## 🟡 可选配置（可稍后配置）

### 4. 网络搜索 API（可选）

#### 4.1 Tavily API
- [ ] **是否使用**：是 / 否
- [ ] **API 密钥**：`_________________`（如使用）

**申请地址**：https://www.tavily.com/

#### 4.2 Bocha API
- [ ] **是否使用**：是 / 否
- [ ] **API 密钥**：`_________________`（如使用）
- [ ] **Base URL**：`https://api.bocha.cn/v1/ai-search`（默认）

**申请地址**：https://open.bochaai.com/

---

## 🟢 部署路径配置

### 5. 服务器路径

- [ ] **项目部署路径**：`/var/www/bettafish`（默认，或自定义）
- [ ] **日志目录**：`/var/www/bettafish/logs`（自动创建）
- [ ] **报告目录**：`/var/www/bettafish/final_reports`（自动创建）

---

### 6. 网站路由配置

- [ ] **访问路径**：`/bettafish/`（默认，或自定义）

**注意**：如果修改路径，需要同步更新：
- Tengine 配置文件（`bettafish.conf`）
- 门户主页链接（`index.html`）

---

## 📝 配置填写说明

1. **复制模板文件**：
   ```bash
   cp deployment/env.template .env
   ```

2. **编辑配置文件**：
   ```bash
   nano .env
   ```

3. **填写所有标记为"必需"的配置项**

4. **保存并验证**：
   - 确保没有留空的必需配置项
   - 检查 API 密钥格式是否正确
   - 验证数据库连接信息

---

## ✅ 配置验证清单

部署前请确认：

- [ ] 所有必需配置项已填写
- [ ] 数据库已创建并配置用户权限
- [ ] 所有 LLM API 密钥已申请并填写
- [ ] 数据库连接信息已测试
- [ ] 端口未被占用
- [ ] 服务器资源充足（内存、磁盘）

---

## 🆘 需要帮助？

如果对某个配置项不确定：

1. 查看 [DEPLOYMENT.md](../DEPLOYMENT.md) 详细说明
2. 查看 [BettaFish README](../README.md) 官方文档
3. 参考各 LLM 服务商的官方文档

---

## 📋 配置示例

以下是一个完整的配置示例（请替换为实际值）：

```bash
# 数据库配置
DB_DIALECT=postgresql
DB_HOST=localhost
DB_PORT=5432
DB_USER=bettafish
DB_PASSWORD=your_strong_password_here
DB_NAME=bettafish
DB_CHARSET=utf8mb4

# Flask 配置
HOST=127.0.0.1
PORT=5000

# LLM 配置
INSIGHT_ENGINE_API_KEY=sk-xxxxxxxxxxxxx
INSIGHT_ENGINE_BASE_URL=https://api.moonshot.cn/v1
INSIGHT_ENGINE_MODEL_NAME=kimi-k2-0711-preview

MEDIA_ENGINE_API_KEY=sk-xxxxxxxxxxxxx
MEDIA_ENGINE_BASE_URL=https://aihubmix.com/v1
MEDIA_ENGINE_MODEL_NAME=gemini-2.5-pro

# ... 其他配置
```

---

**最后更新**：2025-01-XX

