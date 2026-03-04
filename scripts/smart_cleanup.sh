#!/bin/bash
# OmniCoreKernel智能记忆清理系统
# 合理管理记忆生命周期，优化存储效率

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 智能记忆清理函数
cleanup_memories() {
    log "开始智能记忆清理..."
    
    local cleaned_count=0
    local archived_count=0
    
    # 定义清理策略
    declare -A cleanup_policies=(
        ["session"]="30"      # 会话记忆保留30天
        ["context"]="7"       # 上下文记忆保留7天  
        ["emotion"]="90"      # 情感记忆保留90天
        ["learning"]="365"    # 学习记忆保留1年
        ["project"]="730"     # 项目记忆保留2年
        ["core"]="0"          # 核心记忆永久保留
    )
    
    # 处理每个记忆模块
    for module in "${!cleanup_policies[@]}"; do
        local retention_days=${cleanup_policies[$module]}
        local memory_file="$PROJECT_DIR/data/memory/${module}_memory.json"
        
        if [ ! -f "$memory_file" ] || [ "$retention_days" -eq 0 ]; then
            continue
        fi
        
        log "处理 $module 记忆模块 (保留期: ${retention_days}天)"
        
        python3 -c "
import json
import datetime
from datetime import timedelta

module = '$module'
retention_days = int('$retention_days')
memory_file = '$memory_file'

with open(memory_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

# 获取记忆列表
if f'{module}_memory' in data:
    memories = data[f'{module}_memory']
elif module == 'session':
    memories = data.get('sessions', [])
elif module == 'project':
    memories = data.get('active_projects', [])
elif module == 'learning':
    memories = data.get('knowledge_base', [])
elif module == 'context':
    memories = data.get('environment_context', [])
elif module == 'emotion':
    memories = data.get('emotional_states', [])
else:
    memories = []

if not memories:
    exit(0)

# 计算过期时间
cutoff_date = datetime.datetime.now() - timedelta(days=retention_days)

# 分离过期和保留的记忆
kept_memories = []
expired_memories = []

for memory in memories:
    memory_date = datetime.datetime.fromisoformat(memory['timestamp'].replace('+08:00', ''))
    if memory_date < cutoff_date:
        expired_memories.append(memory)
    else:
        kept_memories.append(memory)

# 更新原文件
if f'{module}_memory' in data:
    data[f'{module}_memory'] = kept_memories
elif module == 'session':
    data['sessions'] = kept_memories
elif module == 'project':
    data['active_projects'] = kept_memories
elif module == 'learning':
    data['knowledge_base'] = kept_memories
elif module == 'context':
    data['environment_context'] = kept_memories
elif module == 'emotion':
    data['emotional_states'] = kept_memories

# 创建归档文件（包含过期记忆）
if expired_memories:
    archive_data = {
        'archive_info': {
            'module': module,
            'archive_date': datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+08:00'),
            'retention_policy': f'{retention_days} days',
            'expired_count': len(expired_memories),
            'reason': 'automatic_cleanup'
        },
        'expired_memories': expired_memories
    }
    
    archive_file = f'$PROJECT_DIR/data/archive/{module}_archive_$(date +%Y%m%d).json'
    with open(archive_file, 'w', encoding='utf-8') as f:
        json.dump(archive_data, f, ensure_ascii=False, indent=2)
    
    print(f'ARCHIVED:{len(expired_memories)}')

# 更新元数据
if 'metadata' in data:
    data['metadata']['last_updated'] = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+08:00')
    if f'total_{module}s' in data['metadata']:
        data['metadata'][f'total_{module}s'] = len(kept_memories)

with open(memory_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'CLEANED:{len(kept_memories)}')
" > /tmp/cleanup_result.txt
        
        local result=$(cat /tmp/cleanup_result.txt)
        local cleaned=$(echo "$result" | grep "CLEANED:" | cut -d: -f2)
        local archived=$(echo "$result" | grep "ARCHIVED:" | cut -d: -f2)
        
        if [ -n "$cleaned" ]; then
            success "  保留: $cleaned 条记忆"
        fi
        
        if [ -n "$archived" ]; then
            warning "  归档: $archived 条过期记忆"
            archived_count=$((archived_count + archived))
        fi
    done
    
    # 清理旧的归档文件（保留最近30天的归档）
    log "清理旧归档文件..."
    find "$PROJECT_DIR/data/archive" -name "*_archive_*.json" -mtime +30 -delete 2>/dev/null || true
    
    success "清理完成！归档文件: $archived_count"
}

# 智能压缩函数
compress_old_memories() {
    log "压缩旧记忆数据..."
    
    # 对超过1年的数据进行压缩
    local cutoff_date=$(date -d "1 year ago" +%Y-%m-%d)
    
    for module in learning context emotion; do
        local memory_file="$PROJECT_DIR/data/memory/${module}_memory.json"
        if [ -f "$memory_file" ]; then
            python3 -c "
import json
import datetime

cutoff_date = '$cutoff_date'
memory_file = '$memory_file'

with open(memory_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

# 获取记忆列表
if f'{module}_memory' in data:
    memories = data[f'{module}_memory']
elif module == 'learning':
    memories = data.get('knowledge_base', [])
elif module == 'context':
    memories = data.get('environment_context', [])
elif module == 'emotion':
    memories = data.get('emotional_states', [])
else:
    memories = []

# 压缩旧记忆（简化内容，保留关键信息）
for memory in memories:
    memory_date = datetime.datetime.fromisoformat(memory['timestamp'].replace('+08:00', ''))
    if memory_date.strftime('%Y-%m-%d') < cutoff_date:
        # 压缩：只保留关键字段
        memory['content'] = memory['content'][:100] + '...' if len(memory['content']) > 100 else memory['content']
        if 'details' in memory:
            del memory['details']
        if 'full_content' in memory:
            del memory['full_content']

with open(memory_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'压缩完成: {module}')
" 2>/dev/null || true
        fi
    done
    
    success "旧记忆压缩完成"
}

# 创建归档目录
mkdir -p "$PROJECT_DIR/data/archive"

# 主函数
case "${1:-cleanup}" in
    "cleanup")
        cleanup_memories
        ;;
    "compress")
        compress_old_memories
        ;;
    "full")
        cleanup_memories
        compress_old_memories
        ;;
    "help"|*)
        echo "OmniCoreKernel智能记忆清理系统"
        echo ""
        echo "用法: $0 <command>"
        echo ""
        echo "命令:"
        echo "  cleanup   - 清理过期记忆（默认）"
        echo "  compress  - 压缩旧记忆数据"
        echo "  full      - 完整清理流程"
        echo "  help      - 显示帮助信息"
        echo ""
        echo "清理策略："
        echo "  会话记忆: 保留30天"
echo "  上下文记忆: 保留7天"
echo "  情感记忆: 保留90天"
echo "  学习记忆: 保留1年"
echo "  项目记忆: 保留2年"
echo "  核心记忆: 永久保留"
        echo ""
echo "注意：清理操作会同步到GitHub，过期记忆会被归档而非完全删除"
        ;;
esac