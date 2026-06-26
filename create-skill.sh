#!/usr/bin/env bash
#
# Generate a new ChatGPT Skill template.
#
# Usage:
#   ./new-skill.sh <name> "<description>"
#
# Example:
#   ./new-skill.sh ripgrep \
#     "Use ripgrep (rg) for fast code search."
#
# Output:
#   ./<name>/SKILL.md
#

set -euo pipefail

if [[ $# -lt 2 ]]; then
  sed -n '2,13p' "$0"
  exit 1
fi

name="$1"
shift
description="$*"

dir="$name"
file=".agents/skills/$dir/SKILL.md"

mkdir -p "$dir"

cat >"$file" <<EOF
---
name: $name
description: $description
---

# ${name^}

## Purpose

Describe when this skill should be applied.

---

## ALWAYS

- ...

---

## NEVER

- ...

---

## Common Patterns

\`\`\`bash
...
\`\`\`

---

## Notes

- ...
EOF

echo "Created: $file"