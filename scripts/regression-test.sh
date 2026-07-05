#!/usr/bin/env bash
# whet 回归自测。从仓库任意位置运行:  bash scripts/regression-test.sh
# 覆盖:3 个 hook 脚本的黑盒行为 + agents/skills frontmatter 约定 +
#       JSON 清单与版本一致性 + commands/spec 模板存在性。
# 只读校验,不改任何仓库文件;临时产物写入 ./tmp/selftest(tmp 已被 .gitignore),跑完自动清理。
set -euo pipefail
cd "$(dirname "$0")/.."   # 仓库根(脚本位于 scripts/)
ROOT="$PWD"
TMP="$ROOT/tmp/selftest"
rm -rf "$TMP"; mkdir -p "$TMP"

PASS=0; FAIL=0; FAILED_CASES=()
ok(){ PASS=$((PASS+1)); printf '  ✓ %s\n' "$1"; }
no(){ FAIL=$((FAIL+1)); FAILED_CASES+=("$1"); printf '  ✗ %s\n' "$1"; }
# check "名称" 期望码 -- 命令...
run_hook(){ # $1 脚本  $2 期望exit  $3 stdin  $4 projectdir  $5 名称
  local out rc errfile="$TMP/hook_err_$$.txt"
  out="$(printf '%s' "$3" | CLAUDE_PROJECT_DIR="$4" bash "$1" 2>"$errfile")" && rc=0 || rc=$?
  if [[ "$rc" == "$2" ]]; then
    ok "$5 (exit $rc)"
  else
    no "$5 (期望 $2，实得 $rc)"
    if [[ -s "$errfile" ]]; then
      echo "    --- stderr ---"
      cat "$errfile" | sed 's/^/    /'
      echo "    --------------"
    fi
  fi
  rm -f "$errfile"
}

echo "════════════════════════════════════════════"
echo " 1. enforce-model-tier.sh — 模型档位护栏"
echo "════════════════════════════════════════════"
H="$ROOT/hooks/scripts/enforce-model-tier.sh"
LEDGER="$TMP/proj-ledger"; mkdir -p "$LEDGER/.whet/plan/20260704-001-x"
NOLED="$TMP/proj-noledger"; mkdir -p "$NOLED"

run_hook "$H" 2 '{"tool_input":{"subagent_type":"backend-dev","prompt":"x"}}'                 "$LEDGER" "台账+backend-dev无model → 拦截"
run_hook "$H" 0 '{"tool_input":{"subagent_type":"backend-dev","model":"sonnet","prompt":"x"}}' "$LEDGER" "台账+backend-dev带model → 放行"
run_hook "$H" 0 '{"tool_input":{"subagent_type":"quick-scout","prompt":"x"}}'                  "$LEDGER" "台账+quick-scout无model → 放行(豁免)"
run_hook "$H" 2 '{"tool_input":{"subagent_type":"whet:task-reviewer","prompt":"x"}}'           "$LEDGER" "台账+带命名空间前缀 → 拦截"
run_hook "$H" 0 '{"tool_input":{"subagent_type":"general-purpose","prompt":"x"}}'              "$LEDGER" "台账+非whet agent → 放行"
run_hook "$H" 0 '{"tool_input":{"subagent_type":"backend-dev","prompt":"x"}}'                  "$NOLED"  "无台账+backend-dev无model → 放行"
run_hook "$H" 0 ''                                                                              "$LEDGER" "空输入 → 放行"
run_hook "$H" 0 'not-json-at-all'                                                               "$LEDGER" "非法JSON → 放行"
run_hook "$H" 2 '{"tool_input":{"subagent_type":"architect","prompt":"set \"model\": \"sonnet\" later"}}' "$LEDGER" "prompt内伪造model字样 → 仍拦截"
# 全部 14 个 inherit agent 无 model 均应拦截
for a in architect backend-dev frontend-dev mobile-dev devops-engineer qa-tester code-reviewer task-reviewer product-manager uiux-designer security-engineer data-engineer tech-writer; do
  run_hook "$H" 2 "{\"tool_input\":{\"subagent_type\":\"$a\",\"prompt\":\"x\"}}" "$LEDGER" "台账+${a} 无model → 拦截"
done
# JSON 边缘 case: 验证 sed 解析边界行为
run_hook "$H" 0 '{"tool_input":{"model":"haiku","subagent_type":"backend-dev"}}'                                 "$LEDGER" "字段重排: model已指定 → 放行"
run_hook "$H" 2 '{"tool_input":{"subagent_type":"backend-dev","prompt":"use \"model\":\"haiku\""}}'               "$LEDGER" "prompt内含转义引号 → 拦截(sed误匹配)"
run_hook "$H" 2 '{"tool_input":{"subagent_type":"backend-dev","prompt":"'"$(python3 -c 'print("x"*10000)')"'"}}' "$LEDGER" "超大payload无model → 拦截"

echo
echo "════════════════════════════════════════════"
echo " 2. protect-sensitive.sh — 敏感文件写入护栏"
echo "════════════════════════════════════════════"
H="$ROOT/hooks/scripts/protect-sensitive.sh"
run_hook "$H" 2 '{"file_path":"/x/.env"}'              "$TMP" ".env → 拦截"
run_hook "$H" 2 '{"file_path":"/x/.env.production"}'   "$TMP" ".env.production → 拦截"
run_hook "$H" 2 '{"file_path":"/x/server.pem"}'        "$TMP" "*.pem → 拦截"
run_hook "$H" 2 '{"file_path":"/x/id_rsa"}'            "$TMP" "id_rsa → 拦截"
run_hook "$H" 2 '{"file_path":"/x/credentials.json"}'  "$TMP" "credentials.json → 拦截"
run_hook "$H" 0 '{"file_path":"/x/.env.example"}'      "$TMP" ".env.example → 放行(模板)"
run_hook "$H" 0 '{"file_path":"/x/config.yaml"}'       "$TMP" "普通文件 → 放行"
run_hook "$H" 0 '{"file_path":"/x/README.md"}'         "$TMP" "README.md → 放行"
run_hook "$H" 0 '{}'                                    "$TMP" "无file_path → 放行"
# 扩展敏感文件覆盖测试
run_hook "$H" 2 '{"file_path":"/x/.env.local"}'        "$TMP" ".env.local → 拦截"
run_hook "$H" 2 '{"file_path":"/x/id_ecdsa"}'          "$TMP" "id_ecdsa → 拦截"
run_hook "$H" 2 '{"file_path":"/x/app.token"}'         "$TMP" "*.token → 拦截"
run_hook "$H" 2 '{"file_path":"/x/app.secret"}'        "$TMP" "*.secret → 拦截"
run_hook "$H" 2 '{"file_path":"/x/.secrets"}'          "$TMP" ".secrets → 拦截"
run_hook "$H" 2 '{"file_path":"/x/serviceAccountKey.json"}' "$TMP" "serviceAccountKey.json → 拦截"
run_hook "$H" 2 '{"file_path":"/x/terraform.tfstate"}' "$TMP" "terraform.tfstate → 拦截"
run_hook "$H" 2 '{"file_path":"/x/vars.tfvars"}'       "$TMP" "*.tfvars → 拦截"
run_hook "$H" 2 '{"file_path":"/x/.netrc"}'            "$TMP" ".netrc → 拦截"
run_hook "$H" 2 '{"file_path":"/x/.git-credentials"}'  "$TMP" ".git-credentials → 拦截"
run_hook "$H" 2 '{"file_path":"/x/.htpasswd"}'         "$TMP" ".htpasswd → 拦截"
run_hook "$H" 2 '{"file_path":"/home/user/.aws/credentials"}' "$TMP" ".aws/credentials → 拦截(路径)"
run_hook "$H" 2 '{"file_path":"/home/user/.kube/config"}' "$TMP" ".kube/config → 拦截(路径)"
run_hook "$H" 2 '{"file_path":"/home/user/.docker/config.json"}' "$TMP" ".docker/config.json → 拦截(路径)"
run_hook "$H" 2 '{"file_path":"/home/user/.ssh/authorized_keys"}' "$TMP" ".ssh/authorized_keys → 拦截(路径)"
run_hook "$H" 2 '{"file_path":"/home/user/.gnupg/secring.gpg"}' "$TMP" ".gnupg/secring.gpg → 拦截(路径)"
run_hook "$H" 2 '{"file_path":"/home/user/.terraform/terraform.tfstate"}' "$TMP" ".terraform/terraform.tfstate → 拦截(路径)"
run_hook "$H" 0 '{"file_path":"/x/.env.local.example"}'  "$TMP" ".env.local.example → 放行(模板)"
run_hook "$H" 2 '{"file_path":"/x/.aws/config.yaml"}'    "$TMP" ".aws/config.yaml → 拦截(路径)"

echo
echo "════════════════════════════════════════════"
echo " 2.5 protect-sensitive-bash.sh — Bash 重定向护栏"
echo "════════════════════════════════════════════"
H="$ROOT/hooks/scripts/protect-sensitive-bash.sh"
run_hook "$H" 2 '{"command":"echo x > .env"}'                       "$TMP" "Bash > .env → 拦截"
run_hook "$H" 2 '{"command":"echo x >> /home/user/.aws/credentials"}' "$TMP" "Bash >> 敏感路径 → 拦截"
run_hook "$H" 0 '{"command":"echo x > README.md"}'                "$TMP" "Bash > README.md → 放行"
run_hook "$H" 0 '{"command":"ls -la"}'                            "$TMP" "Bash 无重定向 → 放行"
run_hook "$H" 0 '{"command":"echo x > .env.example"}'             "$TMP" "Bash > .env.example → 放行(模板)"

echo
echo "════════════════════════════════════════════"
echo " 3. session-ledger.sh — 台账检测(SessionStart)"
echo "════════════════════════════════════════════"
H="$ROOT/hooks/scripts/session-ledger.sh"
# 该脚本用相对路径 .whet/plan，需在 cwd 下建目录并切过去
SL="$TMP/sl"; mkdir -p "$SL/.whet/plan/20260704-002-demo"
printf '# plan\n' > "$SL/.whet/plan/20260704-002-demo/plan.md"
out="$(cd "$SL" && bash "$H" 2>"$TMP/sl_err1.txt")"; rc=$?
if [[ $rc -eq 0 && "$out" == *"20260704-002-demo"* && "$out" == *"plan.md"* ]]; then
  ok "有台账 → 输出最新批次提示 (exit 0)"; else no "有台账 → 期望提示含批次名，实得: [$out] rc=$rc"; fi
SL2="$TMP/sl-empty"; mkdir -p "$SL2"
out="$(cd "$SL2" && bash "$H" 2>"$TMP/sl_err2.txt")"; rc=$?
if [[ $rc -eq 0 && -z "$out" ]]; then ok "无台账 → 静默 (exit 0, 无输出)"; else no "无台账 → 期望静默，实得: [$out] rc=$rc"; fi
# 有 plan 目录但无 plan.md → 不应误报
SL3="$TMP/sl-nopm"; mkdir -p "$SL3/.whet/plan/20260704-003-half"
out="$(cd "$SL3" && bash "$H" 2>"$TMP/sl_err3.txt")"; rc=$?
if [[ $rc -eq 0 && -z "$out" ]]; then ok "批次目录缺 plan.md → 静默"; else no "缺plan.md → 期望静默，实得: [$out]"; fi

echo
echo "════════════════════════════════════════════"
echo " 4. hook 脚本静态规范 (CLAUDE.md 约定)"
echo "════════════════════════════════════════════"
for s in "$ROOT"/hooks/scripts/*.sh; do
  n="$(basename "$s")"
  bash -n "$s" 2>/dev/null && ok "$n 语法正确" || no "$n 语法错误"
  [[ -x "$s" ]] && ok "$n 有可执行位" || no "$n 缺可执行位"
  grep -q 'set -euo pipefail' "$s" && ok "$n 含 set -euo pipefail" || no "$n 缺 set -euo pipefail"
  # 检测真实 jq 命令调用(排除注释行),而非注释里 "without requiring jq" 之类字样
  if grep -vE '^\s*#' "$s" | grep -qE '(^|[|;&(]|\$\()\s*jq\b'; then
    no "$n 依赖了 jq(违反约定)"; else ok "$n 不依赖 jq"; fi
done

echo
echo "════════════════════════════════════════════"
echo " 5. JSON 清单校验 + 版本一致性"
echo "════════════════════════════════════════════"
for j in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json; do
  python3 -m json.tool < "$ROOT/$j" >/dev/null 2>&1 && ok "$j 合法 JSON" || no "$j JSON 非法"
done
PV="$(python3 -c 'import json;print(json.load(open("'"$ROOT"'/.claude-plugin/plugin.json"))["version"])')"
MV="$(python3 -c 'import json;print(json.load(open("'"$ROOT"'/.claude-plugin/marketplace.json"))["metadata"]["version"])')"
CV="$(grep -m1 -oE '## \[[0-9]+\.[0-9]+\.[0-9]+\]' "$ROOT/CHANGELOG.md" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[[ "$PV" == "$MV" ]] && ok "plugin/marketplace 版本一致 ($PV)" || no "版本不一致 plugin=$PV marketplace=$MV"
[[ "$PV" == "$CV" ]] && ok "版本与 CHANGELOG 顶条一致 ($CV)" || no "plugin=$PV 但 CHANGELOG 顶条=$CV"
# hooks.json 引用的脚本都存在
python3 - "$ROOT" <<'PY'
import json,os,sys,re
root=sys.argv[1]
h=json.load(open(os.path.join(root,"hooks/hooks.json")))
miss=[]
for evs in h["hooks"].values():
    for blk in evs:
        for hk in blk["hooks"]:
            m=re.search(r'scripts/([\w.-]+\.sh)',hk["command"])
            if m and not os.path.exists(os.path.join(root,"hooks/scripts",m.group(1))):
                miss.append(m.group(1))
print("MISSING:"+",".join(miss) if miss else "OK")
PY

echo
echo "════════════════════════════════════════════"
echo " 5.5 README 版本徽章一致性"
echo "════════════════════════════════════════════"
BADGE_VER="$(grep -oE 'version-[0-9]+\.[0-9]+\.[0-9]+' "$ROOT/README.md" | head -n1 | cut -d- -f2)"
[[ "$PV" == "$BADGE_VER" ]] && ok "README badge 版本与 plugin.json 一致 ($BADGE_VER)" || no "README badge=$BADGE_VER 与 plugin=$PV 不一致"

echo
echo "════════════════════════════════════════════"
echo " 5.6 docs/guide.zh-CN.html 版本一致性"
echo "════════════════════════════════════════════"
HTML_VER="$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' "$ROOT/docs/guide.zh-CN.html" | head -n1)"
[[ "$PV" == "${HTML_VER#v}" ]] && ok "guide.zh-CN.html 版本与 plugin.json 一致 (${HTML_VER#v})" || no "guide.zh-CN.html=$HTML_VER 与 plugin=$PV 不一致"

echo
echo "════════════════════════════════════════════"
echo " 5.7 agent 列表硬编码同步检查"
echo "════════════════════════════════════════════"
python3 - "$ROOT" <<'PY'
import os,sys,re
root=sys.argv[1]; agents_dir=os.path.join(root,"agents")
expected=set()
for fn in sorted(os.listdir(agents_dir)):
    if not fn.endswith(".md"): continue
    t=open(os.path.join(agents_dir,fn)).read()
    m=re.match(r'^---\n(.*?)\n---',t,re.S)
    if not m: continue
    nm=re.search(r'^name:\s*(\S+)',m.group(1),re.M)
    if nm: expected.add(nm.group(1))
expected.discard("quick-scout")
hook=open(os.path.join(root,"hooks/scripts/enforce-model-tier.sh")).read()
hook_agents=set()
for line in hook.splitlines():
    stripped=line.strip()
    if stripped.endswith(")") and "|" in stripped:
        stripped=stripped[:-1]
        hook_agents=set(a.strip() for a in stripped.split("|") if a.strip())
        break
p=f=0
def ok(m): global p; p+=1; print(f"  ✓ {m}")
def no(m): global f; f+=1; print(f"  ✗ {m}")
for a in sorted(expected):
    (ok if a in hook_agents else no)(f"agents/{a}.md 在 case 语句中")
for a in sorted(hook_agents):
    (ok if a in expected else no)(f"case 中的 {a} 有对应 agents/*.md")
print(f"__SYNC__ {p} {f}")
PY

echo
echo "════════════════════════════════════════════"
echo " 6. agents frontmatter 规范"
echo "════════════════════════════════════════════"
python3 - "$ROOT" <<'PY'
import os,sys,re
root=sys.argv[1]; d=os.path.join(root,"agents"); p=f=0
def ok(m):
    global p;p+=1;print(f"  ✓ {m}")
def no(m):
    global f;f+=1;print(f"  ✗ {m}")
for fn in sorted(os.listdir(d)):
    if not fn.endswith(".md"):continue
    stem=fn[:-3]; t=open(os.path.join(d,fn)).read()
    m=re.match(r'^---\n(.*?)\n---',t,re.S)
    if not m: no(f"{fn} 缺 frontmatter");continue
    fm=m.group(1)
    nm=re.search(r'^name:\s*(\S+)',fm,re.M)
    (ok if nm and nm.group(1)==stem else no)(f"{fn} name 与文件名一致")
    (ok if re.search(r'^description:',fm,re.M) else no)(f"{fn} 有 description")
    mo=re.search(r'^model:\s*(\S+)',fm,re.M)
    (ok if mo else no)(f"{fn} 有 model 字段")
    # CLAUDE.md: 禁止硬编码具体模型名，只允许 inherit / 家族别名
    if mo and mo.group(1) not in ("inherit","haiku","sonnet","opus"):
        no(f"{fn} model='{mo.group(1)}' 疑似硬编码具体模型名")
    else:
        ok(f"{fn} model 用别名/inherit")
print(f"__AG__ {p} {f}")
PY

echo
echo "════════════════════════════════════════════"
echo " 7. skills frontmatter (name 必须匹配目录名)"
echo "════════════════════════════════════════════"
python3 - "$ROOT" <<'PY'
import os,sys,re
root=sys.argv[1]; base=os.path.join(root,"skills")
for dn in sorted(os.listdir(base)):
    sp=os.path.join(base,dn,"SKILL.md")
    if not os.path.isfile(sp):
        print(f"  ✗ {dn}/SKILL.md 缺失");continue
    fm=re.match(r'^---\n(.*?)\n---',open(sp).read(),re.S)
    nm=re.search(r'^name:\s*(\S+)',fm.group(1),re.M) if fm else None
    if nm and nm.group(1)==dn: print(f"  ✓ {dn}: name 匹配目录")
    else: print(f"  ✗ {dn}: name={nm.group(1) if nm else None} 不匹配目录")
    d=re.search(r'description:',fm.group(1)) if fm else None
    print(("  ✓ " if d else "  ✗ ")+f"{dn}: 有 description")
PY

echo
echo "════════════════════════════════════════════"
echo " 8. commands / spec 模板存在性"
echo "════════════════════════════════════════════"
for c in optimize plan resume review spec status; do
  [[ -f "$ROOT/commands/$c.md" ]] && ok "command /whet:$c 存在" || no "command $c 缺失"
done
for t in requirements design tasks; do
  [[ -f "$ROOT/spec/templates/$t.md" ]] && ok "spec 模板 $t.md 存在" || no "spec 模板 $t 缺失"
done


echo "════════════════════════════════════════════"
echo " 汇总"
echo "════════════════════════════════════════════"
# 把两段 python 的内部计数并入（它们已各自打印✓/✗，这里只统计 bash 段）
echo "bash 断言:  通过 $PASS  失败 $FAIL"
if ((FAIL>0)); then printf '失败用例:\n'; printf '  - %s\n' "${FAILED_CASES[@]}"; fi
echo "(agents/skills/JSON 的 ✓/✗ 见上方各节；如全为 ✓ 即通过)"
rm -rf "$TMP"
exit $(( FAIL>0 ? 1 : 0 ))
