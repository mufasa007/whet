#!/usr/bin/env bash
# PreToolUse hook (Bash): block accidental redirections to sensitive files
# Exit 2 = block with feedback.
set -euo pipefail

INPUT="$(cat)"

# Check for sensitive redirections using python3.
RESULT="$(python3 - "$INPUT" <<'PY'
import sys, json, re, os

try:
    data = json.loads(sys.argv[1])
except (json.JSONDecodeError, IndexError):
    sys.exit(0)

cmd = data.get("command", "")
if not cmd:
    sys.exit(0)

# Find all redirection targets: > or >> followed by a path.
pattern = r">>?\s*(?:\"([^\"]+)\"|'([^']+)'|([^;|&\s]+))"
targets = re.findall(pattern, cmd)

for match in targets:
    target = match[0] or match[1] or match[2]
    if not target:
        continue
    basename = os.path.basename(target)

    # Allow example/template files.
    if basename.endswith((".example", ".sample", ".template")):
        continue
    if basename.startswith(".env.") and basename.endswith(".example"):
        continue

    # Basename patterns.
    if basename in (".env", ".env.production", ".env.local", ".env.development",
                      ".secrets", ".netrc", ".git-credentials", ".htpasswd",
                      ".npmrc", ".pypirc", "credentials", "credentials.json",
                      "serviceAccountKey.json", "terraform.tfstate",
                      "id_rsa", "id_ed25519", "id_ecdsa"):
        print(target)
        sys.exit(0)

    # Extension patterns.
    _, ext = os.path.splitext(basename)
    if ext in (".pem", ".key", ".p12", ".pfx", ".keystore", ".jks",
               ".token", ".secret", ".tfvars"):
        print(target)
        sys.exit(0)

    # Path-based patterns.
    parts = target.split("/")
    for part in parts:
        if part in (".aws", ".kube", ".docker", ".ssh", ".gnupg", ".terraform"):
            print(target)
            sys.exit(0)

sys.exit(0)
PY
)"

if [[ -n "$RESULT" ]]; then
    echo "Blocked Bash redirection to sensitive file: ${RESULT}. If this is intentional," >&2
    echo "ask the user to make this change themselves or to approve it explicitly." >&2
    exit 2
fi

exit 0
