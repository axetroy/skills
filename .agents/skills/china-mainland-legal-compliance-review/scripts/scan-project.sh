#!/usr/bin/env bash
#
# scan-project.sh — 扫描项目中的中国大陆法律合规信号。
#
# 用法:
#   scripts/scan-project.sh [项目路径]
#
# 默认项目路径为当前目录。
#
# 本脚本是只读的证据收集器：绝不修改项目。
# 输出按合规领域分组；每行要么是检查状态（OK/MISSING/FLAG），要么是带文件引用的观察记录。
#
# 退出码: 成功为 0，用法错误或路径无效为 1。
# 证据缺失会作为发现报告，不属于脚本错误。

set -uo pipefail

ROOT="${1:-$PWD}"

if [ ! -d "$ROOT" ]; then
  echo "error: 不是目录: $ROOT" >&2
  exit 1
fi

cd "$ROOT" || exit 1

section() {
  echo
  echo "## $1"
}

ok()   { printf 'OK     %s\n' "$*"; }
miss() { printf '缺失   %s\n' "$*"; }
flag() { printf '标记   %s\n' "$*"; }
obs()  { printf '信息   %s\n' "$*"; }

find_case_insensitive() {
  # 按路径最后一段的不区分大小写匹配查找文件
  local pat="$1"
  find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' \
       -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/vendor/*' \
       -not -path '*/.venv/*' -not -path '*/Pods/*' 2>/dev/null \
    | grep -iE "(^|/)[^/]*${pat}[^/]*$"
}

section "项目基本信息"
obs "root=$ROOT"
if [ -f .git/config ]; then
  obs "检测到 git 仓库"
else
  obs "非 git 仓库（不影响证据收集）"
fi

section "合规文档"
POLICY=$(find_case_insensitive "privacy")
AGREEMENT=$(find_case_insensitive "user[-_]?agreement")
TERMS=$(find_case_insensitive "terms")
EULA=$(find_case_insensitive "eula")
LICENSE=$(find_case_insensitive "^licen[cs]e")
NOTICES=$(find_case_insensitive "notice")

[ -n "$POLICY" ]   && ok "隐私政策: $POLICY"   || miss "隐私政策 (privacy*.md/html/txt)"
[ -n "$AGREEMENT" ] && ok "用户协议: $AGREEMENT" || miss "用户协议 (user agreement 文件)"
[ -n "$TERMS" ]    && ok "服务条款: $TERMS"    || miss "服务条款 (terms*.md/html/txt)"
[ -n "$EULA" ]     && ok "EULA: $EULA"        || miss "EULA (eula*.md/html/txt)"
[ -n "$LICENSE" ]  && ok "LICENSE 文件: $LICENSE"   || miss "LICENSE 文件"
[ -n "$NOTICES" ]  && ok "第三方声明: $NOTICES" || miss "第三方声明 (THIRD_PARTY_NOTICES / NOTICE)"

ICP=$(grep -rIl --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build \
  -E '(ICP备[0-9]{3,}|[0-9]{3,}[0-9]号-[0-9]{1,}号)' . 2>/dev/null | head -n 5)
if [ -n "$ICP" ]; then
  ok "在以下文件中发现 ICP 备案号: $ICP"
else
  miss "未找到 ICP 备案号（备案号）"
fi

section "个人信息信号"
PI_SIGNS=$(grep -rInE --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.php' --include='*.rb' --include='*.vue' --include='*.c' --include='*.cpp' --include='*.h' --include='*.m' --include='*.mm' \
  -E '(\bphone\b|\b(mobile|cell).*number|身份证|ID_?card|idcard|\\bid_card\\b|\baddress\b|\bgps\b|location|coordinate|device.?id|IMEI|IMSI|MAC address|biometric|fingerprint|face.?id|health|medical|bank.?account|credit.?card|\\bip.?address|手机号|手机号码|定位|身份证号)' . 2>/dev/null | head -n 40)
if [ -n "$PI_SIGNS" ]; then
  flag "发现个人信息采集信号（审查必要性并取得同意）:"
  echo "$PI_SIGNS" | sed 's/^/      /' | head -n 20
else
  ok "源码中无明显个人信息关键字"
fi

SECTION_CONSENT=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.vue' \
  -E '(consent|agree|同意|授权|permission.?request|checkSelfPermission|requestPermissions)' . 2>/dev/null | head -n 5)
if [ -n "$SECTION_CONSENT" ]; then
  obs "发现同意/权限请求流程: $SECTION_CONSENT"
else
  miss "源码中未发现同意/权限请求流程"
fi

section "敏感数据"
SENS=$(find_case_insensitive "id[-_]?card")
if [ -n "$SENS" ]; then
  flag "发现身份证/敏感标识文件: $SENS"
else
  ok "无明显身份证相关产物"
fi

section "数据出境 / 境外端点"
OUT=$(grep -rInE --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.php' --include='*.vue' --include='*.xml' --include='*.json' --include='*.gradle' --include='*.plist' --include='*.yml' --include='*.yaml' --include='*.toml' --include='*.html' \
  -E '(https?://|wss?://)?([a-z0-9-]+\.)?(google|facebook|twitter|instagram|tiktok|whatsapp|telegram|amazonaws|azure|firebase|amplitude|mixpanel|segment|appsflyer|braze|intercom|hubspot|sentry|datadog|adobe|doubleclick|googletagmanager|onesignal|apifox)\b' . 2>/dev/null | head -n 40)
if [ -n "$OUT" ]; then
  flag "发现可能的出境/境外服务引用（评估数据传输）:"
  echo "$OUT" | sed 's/^/      /' | head -n 20
else
  ok "未发现明显境外服务端点"
fi

section "第三方 SDK"
SDK_DIRS=$(find . -maxdepth 4 -type d \( -iname '*sdk*' -o -iname 'fabric' -o -iname 'firebase' -o -iname 'facebook*' \) \
  -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/build/*' -not -path '*/Pods/*' 2>/dev/null | head -n 20)
if [ -n "$SDK_DIRS" ]; then
  obs "SDK 目录:"
  echo "$SDK_DIRS" | sed 's/^/      /'
fi

section "算法 / AI / 深度合成"
ALGO=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.json' --include='*.md' \
  -E '(recommend|推荐|ranking|排序|personaliz|个性化|feed|相关推荐|猜你喜欢)' . 2>/dev/null | head -n 5)
[ -n "$ALGO" ] && flag "算法/推荐信号: $ALGO（核对备案义务）" || ok "无明显推荐信号"

GENAI=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.json' --include='*.md' \
  -iE '(openai|chatgpt|gpt-|claude|gemini|deepseek|qwen|文心|通义|生成式|generative|deep.?synthes|deepfake|midjourney|stable.?diffusion)' . 2>/dev/null | head -n 5)
[ -n "$GENAI" ] && flag "生成式 AI / 深度合成信号: $GENAI（核对备案与标识义务）" || ok "无明显生成式 AI / 深度合成信号"

section "未成年人 / 年龄门槛"
AGE=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.md' --include='*.json' --include='*.html' \
  -E '(未成年|未成年人|minor|age.?gate|birth.?date|birthday|防沉迷|guardian|监护人|parental)' . 2>/dev/null | head -n 5)
[ -n "$AGE" ] && obs "未成年人保护信号: $AGE" || miss "未发现年龄门槛/未成年人保护信号"

section "内容审核"
MOD=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.md' --include='*.json' --include='*.html' \
  -iE '(moderat|审核|敏感词|sensitive.?word|censor|举报|report.*content|harmful.?content)' . 2>/dev/null | head -n 5)
[ -n "$MOD" ] && obs "内容审核信号: $MOD" || miss "未发现内容审核信号（仅 UGC 平台才相关）"

section "日志 / 安全"
LOGGING=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.log*' --include='*.yml' --include='*.yaml' --include='*.toml' --include='*.json' \
  -E '(audit.?log|access.?log|登录日志|操作日志|login.?log|log.?retention|retention)' . 2>/dev/null | head -n 5)
[ -n "$LOGGING" ] && obs "日志信号: $LOGGING" || miss "未发现审计/访问日志信号"

ENCRYPT=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.yml' --include='*.yaml' --include='*.toml' --include='*.json' \
  -iE '(AES|RSA|TLS|HTTPS|encrypt|encryption|加解密|加密)' . 2>/dev/null | head -n 5)
[ -n "$ENCRYPT" ] && obs "加密/TLS 信号: $ENCRYPT" || miss "未发现加密/TLS 信号"

section "电商 / 广告 / 支付"
ECOM=$(grep -rIl --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.kt' --include='*.java' --include='*.swift' --include='*.go' --include='*.py' --include='*.vue' --include='*.md' --include='*.json' --include='*.html' \
  -iE '(checkout|cart|order|订单|支付|payment|alipay|wechat.?pay|退款|refund|七天无理由|广告|advert|促销|promotion|coupon|优惠券)' . 2>/dev/null | head -n 5)
[ -n "$ECOM" ] && obs "电商 / 支付 / 广告信号: $ECOM" || ok "无明显电商 / 广告信号"

section "锁文件与依赖（供 IP/开源审查）"
LOCK=$(find . -maxdepth 3 -type f \( -name 'package-lock.json' -o -name 'yarn.lock' -o -name 'pnpm-lock.yaml' -o -name 'go.sum' -o -name 'Cargo.lock' -o -name 'poetry.lock' -o -name 'Gemfile.lock' -o -name 'requirements*.txt' -o -name 'Pipfile.lock' -o -name 'composer.lock' -o -name 'Podfile.lock' -o -name 'pubspec.lock' -o -name 'gradle*.lock' -o -name '*.lockfile' \) 2>/dev/null)
if [ -n "$LOCK" ]; then
  obs "依赖锁文件:"
  echo "$LOCK" | sed 's/^/      /'
else
  miss "未发现依赖锁文件（无法枚举许可证）"
fi

section "摘要"
echo
echo "撰写发现前，请将上述 缺失/标记 项对照技能参考文件核对。"
echo "以上均为证据，不构成法律结论。"

exit 0