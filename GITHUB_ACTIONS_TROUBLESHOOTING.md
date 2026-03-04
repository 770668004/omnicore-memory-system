# GitHub Actions工作流故障排除指南

## 🔍 当前状态

### 工作流运行情况
- **状态**: 最新运行显示 "failure"
- **工作流文件**: `.github/workflows/sync-memory.yml` (原始复杂版本)
- **备用工作流**: `.github/workflows/simple-sync.yml` (新增简化版本)

## ❓ 可能的问题原因

### 1. 复杂JSON操作失败
- 原始工作流包含复杂的嵌套JSON验证
- 使用了 `python3 -m json.tool` 进行验证
- 复杂的循环和条件判断

### 2. 环境依赖问题
- 可能缺少 `jq` 或其他依赖工具
- Python环境配置问题
- Git配置问题

### 3. 权限问题
- GitHub Token权限不足
- 文件系统权限问题
- 仓库访问权限

### 4. 工作流逻辑复杂性
- 过多的步骤和条件判断
- 复杂的错误处理逻辑
- 嵌套的条件语句

## ✅ 解决方案

### 方案1: 使用简化工作流 (推荐)
我们创建了 `simple-sync.yml`，它具有以下优势：
- ✅ 简化的JSON验证
- ✅ 减少复杂逻辑
- ✅ 更好的错误处理
- ✅ 更容易调试

### 方案2: 分步调试
1. **验证JSON文件**
   ```bash
   python3 -m json.tool data/memory/*.json
   ```

2. **测试Git操作**
   ```bash
   git status
   git add -A
   git commit -m "test"
   ```

3. **测试文件权限**
   ```bash
   ls -la data/
   touch data/test.txt
   rm data/test.txt
   ```

### 方案3: 添加详细日志
在工作流中添加更多调试信息：
```yaml
- name: Debug Info
  run: |
    echo "Current directory: $(pwd)"
    echo "Git status: $(git status --porcelain)"
    echo "Python version: $(python3 --version)"
    echo "Available files: $(ls -la data/)"
```

## 🚀 当前解决方案

### 已实施的改进
1. **添加了简化工作流** (`simple-sync.yml`)
2. **优化了错误处理**
3. **减少了复杂依赖**
4. **改进了日志记录**

### 建议操作
1. **监控新工作流** - 观察 `simple-sync.yml` 的运行情况
2. **查看GitHub Actions页面** - 获取详细错误日志
3. **测试本地执行** - 确保所有脚本正常工作

## 📋 监控建议

### 定期检查
- [ ] 查看GitHub Actions运行状态
- [ ] 监控同步日志文件
- [ ] 验证记忆数据完整性
- [ ] 检查自动清理功能

### 故障处理流程
1. **查看GitHub Actions日志**
2. **检查本地日志文件** (`/tmp/omnicore_*.log`)
3. **验证JSON文件完整性**
4. **测试手动同步功能**

## 🔗 相关链接
- GitHub Actions页面: https://github.com/770668004/omnicore-memory-system/actions
- 工作流文件: `.github/workflows/`
- 日志文件: `/tmp/omnicore_*.log`

---

**当前状态**: 系统功能正常，工作流正在优化中
**建议**: 使用简化版工作流，监控运行情况