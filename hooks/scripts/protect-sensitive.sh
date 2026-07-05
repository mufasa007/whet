#!/usr/bin/env bash
# PreToolUse hook (Write|Edit): block accidental writes to sensitive files
# (env files, key material, cloud credentials). Exit 2 = block with feedback.
set -euo pipefail

INPUT="$(cat)"

# Extract file_path from tool_input JSON without requiring jq.
FILE_PATH="$(printf '%s' "$INPUT" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

[[ -z "$FILE_PATH" ]] && exit 0

BASENAME="$(basename "$FILE_PATH")"

# Allow example/template files first.
case "$BASENAME" in
  *.example|*.sample|*.template|.env.example|.env.sample|.env.template)
    exit 0 ;;
esac

# Check basename against sensitive patterns.
case "$BASENAME" in
  .env|.env.*|*.pem|*.key|*.p12|*.pfx|*.keystore|*.jks|id_rsa|id_ed25519|id_ecdsa|credentials|credentials.json|.npmrc|.pypirc|.env.local|*.token|*.secret|.secrets|serviceAccountKey.json|terraform.tfstate|*.tfvars|.netrc|.git-credentials|.htpasswd)
    echo "Blocked write to sensitive file: ${FILE_PATH}. If this is intentional," >&2
    echo "ask the user to make this change themselves or to approve it explicitly." >&2
    exit 2
    ;;
esac

# Check path-based patterns (directories that commonly contain secrets).
case "$FILE_PATH" in
  */.aws/*|*/.kube/*|*/.docker/*|*/.ssh/*|*/.gnupg/*|*/.terraform/*)
    echo "Blocked write to sensitive file: ${FILE_PATH}. If this is intentional," >&2
    echo "ask the user to make this change themselves or to approve it explicitly." >&2
    exit 2
    ;;
esac

exit 0
