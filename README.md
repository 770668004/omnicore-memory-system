# OmniCoreKernel 记忆系统

实时同步的记忆仓库，为OpenClaw会话提供持久化的记忆管理能力。

## 🧠 系统特性

- **实时同步**: 每次会话变更自动同步到GitHub
- **多模型兼容**: 支持不同AI模型间的记忆共享
- **会话恢复**: 新会话自动读取最新记忆状态
- **版本控制**: 完整的记忆变更历史
- **安全加密**: 敏感信息本地加密存储

## 📁 目录结构

```
omnicore-memory-system/
├── data/
│   ├── memory/          # 核心记忆文件
│   │   ├── core_memory.json
│   │   ├── session_YYYY-MM-DD.json
│   │   └── user_preferences.json
│   └── state/           # 状态数据
│       └── runtime.json
├── scripts/
│   ├── init.sh          # OmniCoreKernel初始化
│   ├── sync.sh          # 同步脚本
│   └── backup.sh        # 备份脚本
├── github-actions/
│   └── sync-memory.yml  # 自动同步工作流
├── config/
│   └── omnicore.conf    # 核心配置文件
└── README.md
```

## 🚀 快速开始

### 1. 克隆仓库
```bash
git clone git@github.com:770668004/omnicore-memory-system.git
cd omnicore-memory-system
```

### 2. 初始化系统
```bash
./scripts/init.sh
```

### 3. 配置自动同步
GitHub Actions会自动同步记忆变更，无需手动操作。

## 🔧 配置说明

### 核心记忆格式
```json
{
  "core_memory": [
    {
      "id": "unique_id",
      "content": "记忆内容",
      "priority": "high|medium|low",
      "timestamp": "2026-03-04T11:45:00Z",
      "category": "system|user|context",
      "encryption": false
    }
  ]
}
```

### 用户偏好设置
```json
{
  "user_preferences": {
    "language": "zh_cn",
    "timezone": "Asia/Shanghai",
    "sync_interval": 300,
    "encryption_enabled": true,
    "auto_backup": true
  }
}
```

## 📋 使用场景

- **会话重启**: 自动读取上次的对话上下文
- **模型切换**: 保持记忆一致性
- **多设备同步**: 在不同设备间共享记忆
- **备份恢复**: 完整的历史记录和版本回退

## 🔒 安全说明

- 敏感信息本地加密存储
- GitHub仓库使用私有模式
- 支持SSH密钥认证
- 定期自动备份

## 📞 支持

如有问题请在GitHub Issues中反馈。