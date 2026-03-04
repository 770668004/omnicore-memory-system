#!/bin/bash
# OmniCoreKernel高级记忆管理脚本
# 支持多模块记忆操作

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
info() { echo -e "${CYAN}[INFO]${NC} $1"; }

# 显示所有记忆模块状态
show_memory_modules() {
    log "OmniCoreKernel记忆模块状态："
    echo ""
    
    local modules=("core" "session" "project" "learning" "context" "emotion")
    local module_files=("core_memory.json" "session_memory.json" "project_memory.json" "learning_memory.json" "context_memory.json" "emotion_memory.json")
    
    for i in "${!modules[@]}"; do
        local module="${modules[$i]}"
        local file="${module_files[$i]}"
        local filepath="$PROJECT_DIR/data/memory/$file"
        
        if [ -f "$filepath" ]; then
            local count=$(python3 -c "import json; data=json.load(open('$filepath')); print(len(data.get('${module}_memory', data.get('sessions', data.get('active_projects', [])))))" 2>/dev/null || echo "0")
            local size=$(stat -c%s "$filepath" 2>/dev/null || stat -f%z "$filepath" 2>/dev/null || echo "0")
            success "📋 $module 记忆: $count 条记录 ($size 字节)"
        else
            warning "❌ $module 记忆: 文件不存在"
        fi
    done
}

# 添加新的记忆条目
add_memory() {
    local module=$1
    local content=$2
    local priority=${3:-"medium"}
    local category=${4:-"general"}
    local tags=${5:-""}
    
    log "添加$module记忆..."
    
    local memory_file="$PROJECT_DIR/data/memory/${module}_memory.json"
    if [ ! -f "$memory_file" ]; then
        error "记忆模块文件不存在: $memory_file"
        return 1
    fi
    
    python3 -c "
import json
import datetime
import sys

module = sys.argv[1]
content = sys.argv[2]
priority = sys.argv[3]
category = sys.argv[4]
tags = sys.argv[5].split(',') if sys.argv[5] else []

with open('$memory_file', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 创建新的记忆条目
new_memory = {
    'id': f'{module}_' + datetime.datetime.now().strftime('%Y%m%d_%H%M%S'),
    'content': content,
    'priority': priority,
    'timestamp': datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+08:00'),
    'category': category,
    'encryption': False,
    'tags': tags
}

# 添加到相应的记忆数组
if f'{module}_memory' in data:
    data[f'{module}_memory'].append(new_memory)
elif module == 'session':
    data['sessions'].append(new_memory)
elif module == 'project':
    data['active_projects'].append(new_memory)
elif module == 'learning':
    data['knowledge_base'].append(new_memory)
elif module == 'context':
    data['environment_context'].append(new_memory)
elif module == 'emotion':
    data['emotional_states'].append(new_memory)

# 更新元数据
if 'metadata' in data:
    if 'total_memories' in data['metadata']:
        data['metadata']['total_memories'] += 1
    data['metadata']['last_updated'] = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S+08:00')

with open('$memory_file', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f'✅ 已添加{module}记忆')
" "$module" "$content" "$priority" "$category" "$tags"
    
    success "记忆已添加到 $module 模块"
}

# 搜索记忆
search_memories() {
    local keyword=$1
    log "搜索包含 '$keyword' 的记忆..."
    
    local modules=("core" "session" "project" "learning" "context" "emotion")
    local found=false
    
    for module in "${modules[@]}"; do
        local memory_file="$PROJECT_DIR/data/memory/${module}_memory.json"
        if [ -f "$memory_file" ]; then
            python3 -c "
import json
import sys

keyword = sys.argv[1]
module = sys.argv[2]
memory_file = f'$PROJECT_DIR/data/memory/{module}_memory.json'

try:
    with open(memory_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 根据模块类型获取记忆列表
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
    
    found = False
    for memory in memories:
        if keyword.lower() in memory.get('content', '').lower():
            print(f'📝 [{module}] {memory[\"content\"][:80]}...')
            print(f'   优先级: {memory.get(\"priority\", \"unknown\")} | 时间: {memory[\"timestamp\"][:19]}')
            print('')
            found = True
    
    if found:
        sys.exit(0)
    
except Exception as e:
    pass
" "$keyword" "$module"
        fi
    done
    
    info "搜索完成"
}

# 显示记忆统计
show_statistics() {
    log "OmniCoreKernel记忆统计："
    echo ""
    
    local total_memories=0
    local modules=("core" "session" "project" "learning" "context" "emotion")
    
    for module in "${modules[@]}"; do
        local memory_file="$PROJECT_DIR/data/memory/${module}_memory.json"
        if [ -f "$memory_file" ]; then
            local count=$(python3 -c "import json; data=json.load(open('$memory_file')); print(len(data.get('${module}_memory', data.get('sessions', data.get('active_projects', [])))))" 2>/dev/null || echo "0")
            local size=$(stat -c%s "$memory_file" 2>/dev/null || stat -f%z "$memory_file" 2>/dev/null || echo "0")
            
            CYAN='[36m'
            printf "${CYAN}%-10s${NC}: %3d 条记录 | %6d 字节\n" "$module" "$count" "$size"
            total_memories=$((total_memories + count))
        fi
    done
    
    echo ""
    success "📈 总计: $total_memories 条记忆"
    
    # 显示最新更新时间
    if [ -f "$PROJECT_DIR/data/memory/core_memory.json" ]; then
        local last_update=$(python3 -c "import json; data=json.load(open('$PROJECT_DIR/data/memory/core_memory.json')); print(data.get('metadata', {}).get('last_updated', 'unknown'))")
        info "🕐 最后更新: $last_update"
    fi
}

# 主函数
case "${1:-help}" in
    "show")
        show_memory_modules
        ;;
    "add")
        if [ $# -lt 3 ]; then
            error "用法: $0 add <module> <content> [priority] [category] [tags]"
            echo "模块: core, session, project, learning, context, emotion"
            echo "优先级: low, medium, high"
            exit 1
        fi
        shift
        add_memory "$@"
        ;;
    "search")
        if [ $# -lt 2 ]; then
            error "用法: $0 search <keyword>"
            exit 1
        fi
        search_memories "$2"
        ;;
    "stats")
        show_statistics
        ;;
    "sync")
        log "同步到GitHub..."
        cd "$PROJECT_DIR"
        git add -A
        git commit -m "记忆系统更新: $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
        git push origin main 2>/dev/null
        success "同步完成"
        ;;
    "help"|*)
        echo "OmniCoreKernel高级记忆管理"
        echo ""
        echo "用法: $0 <command> [options]"
        echo ""
        echo "命令:"
        echo "  show          - 显示所有记忆模块状态"
        echo "  add <module> <content> [priority] [category] [tags]"
        echo "               - 添加新的记忆条目"
        echo "  search <keyword> - 搜索记忆内容"
        echo "  stats         - 显示记忆统计信息"
        echo "  sync          - 同步到GitHub"
        echo "  help          - 显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0 show"
        echo "  $0 add learning '学会了新的Python技巧' high technology 'python,tips'"
        echo "  $0 search Python"
        echo "  $0 stats"
        ;;
esac