#!/usr/bin/env bash
#
# check-skill.sh — 依据 agentskills.io 规范校验本技能。
#
# 用法:
#   scripts/check-skill.sh [技能目录]
#
# 默认技能目录为 scripts/ 的上一级（技能根目录）。
#
# 执行 skill-generator 工作流中的手工校验项:
#   - 技能根目录存在 SKILL.md
#   - YAML frontmatter 存在且可解析
#   - name 合法（1-64 字符，a-z0-9 与连字符，不以 '-' 开头/结尾，无 '--'）
#   - name 与父目录名一致
#   - description 存在且不超过 1024 字符
#   - compatibility（若存在）不超过 500 字符
#   - metadata 的值为字符串
#   - SKILL.md 中的相对文件引用均存在
#   - SKILL.md 不超过 500 行
#
# 若已安装 `skills-ref` 参考校验器，则一并运行。
#
# 退出码: 全部通过为 0，否则为 1。

set -uo pipefail

SKILL_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
SKILL="$SKILL_DIR/SKILL.md"

failures=0
passes=0

pass() { printf '通过   %s\n' "$*"; passes=$((passes+1)); }
fail() { printf '失败   %s\n' "$*"; failures=$((failures+1)); }
warn() { printf '警告   %s\n' "$*"; }

# --- 1. SKILL.md 存在 ------------------------------------------------------
if [ -f "$SKILL" ]; then
  pass "SKILL.md 存在于 $SKILL_DIR"
else
  fail "SKILL.md 缺失: $SKILL_DIR"
  echo "中止: 无 SKILL.md 可校验" >&2
  exit 1
fi

# --- 2. frontmatter 可解析 --------------------------------------------------
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import yaml' >/dev/null 2>&1; then
    if python3 - "$SKILL" <<'PY' >/dev/null 2>&1
import sys, yaml, pathlib
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
assert text.startswith("---\n"), "缺少开头 ---"
_, fm, _ = text.split("---\n", 2)
yaml.safe_load(fm)
PY
    then
      pass "frontmatter 为可解析的 YAML"
    else
      fail "frontmatter 无法解析为 YAML"
    fi
  else
    if [ "$(head -n 1 "$SKILL")" = "---" ] && grep -qE '^(name|description):' "$SKILL"; then
      warn "pyyaml 不可用；frontmatter 启发式检查通过（严格校验请安装 pyyaml）"
    else
      fail "frontmatter 格式似不合法（缺少 '---' 或 name/description）"
    fi
  fi
else
  warn "未找到 python3；跳过 frontmatter 解析检查"
fi

# --- 3. 提取 frontmatter 字段（尽力而为） -----------------------------------
read_field() {
  # 打印单行标量 frontmatter 字段的值
  awk -v key="$1" '
    $0 == key ":" { sub(/^[^:]+:[[:space:]]*/, ""); print; exit }
    $0 ~ "^" key ":" { sub(/^[^:]+:[[:space:]]*/, ""); print; exit }
  ' "$SKILL"
}

NAME="$(read_field name)"
DESC="$(read_field description)"
COMPAT="$(read_field compatibility)"

# --- 4. name 校验 -----------------------------------------------------------
if [ -z "$NAME" ]; then
  fail "frontmatter 缺少 'name'"
else
  if [ "${#NAME}" -gt 64 ]; then
    fail "name 超过 64 字符"
  else
    pass "name 长度正常 ($(printf '%s' "$NAME" | wc -c | tr -d ' ') 字符)"
  fi
  if [[ ! "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    fail "name '$NAME' 违反命名规则（小写字母数字 + 单个连字符）"
  else
    pass "name '$NAME' 符合命名规则"
  fi
  if [ "$NAME" = "$(basename "$SKILL_DIR")" ]; then
    pass "name 与父目录一致"
  else
    fail "name '$NAME' 与父目录 '$(basename "$SKILL_DIR")' 不一致"
  fi
fi

# --- 5. description 校验 ----------------------------------------------------
if [ -z "$DESC" ]; then
  fail "frontmatter 缺少 'description'"
else
  n=$(printf '%s' "$DESC" | wc -c | tr -d ' ')
  if [ "$n" -gt 1024 ]; then
    fail "description 为 $n 字符（上限 1024）"
  else
    pass "description 存在，$n 字符（上限 1024）"
  fi
fi

# --- 6. compatibility 校验 --------------------------------------------------
if [ -n "$COMPAT" ]; then
  n=$(printf '%s' "$COMPAT" | wc -c | tr -d ' ')
  if [ "$n" -gt 500 ]; then
    fail "compatibility 为 $n 字符（上限 500）"
  else
    pass "compatibility 存在，$n 字符（上限 500）"
  fi
fi

# --- 7. metadata 值为字符串 -------------------------------------------------
if grep -qE '^metadata:' "$SKILL"; then
  if command -v python3 >/dev/null 2>&1 && python3 -c 'import yaml' >/dev/null 2>&1; then
    if python3 - "$SKILL" <<'PY' >/tmp/cs_meta_out 2>&1
import sys, yaml, pathlib
text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
fm = yaml.safe_load(text.split("---\n", 2)[1])
md = fm.get("metadata") or {}
assert isinstance(md, dict), "metadata 必须为映射"
bad = [k for k, v in md.items() if not isinstance(v, str)]
if bad:
    sys.exit(1)
PY
    then
      pass "metadata 的值为字符串"
    else
      fail "metadata 必须为字符串键/字符串值对"
      sed 's/^/        /' /tmp/cs_meta_out 2>/dev/null
    fi
  else
    warn "python3+pyyaml 不可用；跳过 metadata 字符串检查"
  fi
fi

# --- 8. 文件引用存在 --------------------------------------------------------
# 朴素的 markdown 链接引用提取
while IFS= read -r ref; do
  case "$ref" in
    http*|'#'*) continue ;;
  esac
  clean="${ref%%\#*}"
  clean="${clean%%\?*}"
  if [ -n "$clean" ]; then
    if [ -e "$SKILL_DIR/$clean" ]; then
      pass "引用 '$clean' 存在"
    else
      fail "引用 '$clean' 缺失"
    fi
  fi
done < <(grep -oE '\]\(([^)]+)\)' "$SKILL" | sed 's/^](//; s/)$//' | grep -vE '^(http|#)')

# --- 9. SKILL.md 行数 --------------------------------------------------------
LINES=$(wc -l < "$SKILL" | tr -d ' ')
if [ "$LINES" -gt 500 ]; then
  fail "SKILL.md 共 $LINES 行（为渐进式披露请保持 500 行以内）"
else
  pass "SKILL.md 共 $LINES 行（500 行以内）"
fi

# --- 10. 可选: skills-ref 参考校验器 ----------------------------------------
if command -v skills-ref >/dev/null 2>&1; then
  echo
  echo "运行参考校验器: skills-ref validate $SKILL_DIR"
  if skills-ref validate "$SKILL_DIR"; then
    pass "skills-ref 校验通过"
  else
    fail "skills-ref 校验失败（见上方输出）"
  fi
else
  warn "未安装 skills-ref；跳过参考校验器（已使用手工校验）"
fi

# --- 结果 -------------------------------------------------------------------
echo
if [ "$failures" -eq 0 ]; then
  echo "OK: $passes 项通过，0 项失败。"
  exit 0
else
  echo "失败: $failures 项未通过，$passes 项通过。"
  exit 1
fi