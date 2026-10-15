#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Publishes uOS to GitHub: pushes main, tags v3.0, creates a release and
# attaches the zip.
#
#   usage:  bash publish.sh <your-username>/uos
#
# The token is read from stdin (hidden), whitespace-stripped, and passed to
# git through an in-memory credential helper + environment variable. It is
# never put in a URL, never stored in the remote, and never in shell history.
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "usage: bash publish.sh <your-username>/uos" >&2
  exit 1
fi

ZIP="uos-3.0.zip"
if [ ! -f "$ZIP" ]; then
  echo "· building $ZIP"
  zip -q -9 "$ZIP" uOS.html README.md RELEASE_NOTES.md
fi

printf 'Paste a FRESH GitHub token (input hidden, press Enter): '
read -rs TOKEN || true
echo

# pastes often pick up a trailing newline / stray spaces — strip them all
TOKEN="$(printf '%s' "$TOKEN" | tr -d '[:space:]')"
if [ -z "$TOKEN" ]; then
  echo "! no token given, aborting" >&2
  exit 1
fi
echo "· token length: ${#TOKEN} (should be 40 for ghp_… or 93 for github_pat_…)"
case "$TOKEN" in
  ghp_*|github_pat_*) : ;;
  *) echo "! warning: that doesn't start with ghp_ or github_pat_ — is it the right token?" >&2 ;;
esac

# git gets the token via a credential helper, never via the remote URL
export GIT_TOKEN="$TOKEN"
CRED='!f() { echo username=x-access-token; echo password="$GIT_TOKEN"; }; f'

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$REPO.git"

echo "· pushing main"
if ! git -c credential.helper="$CRED" push -u origin main; then
  echo "! the remote already has commits (GitHub usually adds a README)."
  echo "  merging it in so nothing on the remote is lost…"
  git -c credential.helper="$CRED" fetch origin main
  if git merge --allow-unrelated-histories -X ours -m "merge remote history" FETCH_HEAD; then
    git -c credential.helper="$CRED" push -u origin main
  else
    echo >&2
    echo "! automatic merge failed. Pick one by hand:" >&2
    echo "    git merge --abort" >&2
    echo "    git push -f origin main    # only if the remote has nothing you need" >&2
    exit 1
  fi
fi

echo "· tagging v3.0"
git tag -f v3.0
git -c credential.helper="$CRED" push -f origin v3.0

echo "· creating the release"
BODY=$(python3 -c 'import json; print(json.dumps(open("RELEASE_NOTES.md").read()))')
RESP=$(curl -sS -X POST "https://api.github.com/repos/$REPO/releases" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d "{\"tag_name\":\"v3.0\",\"target_commitish\":\"main\",\"name\":\"uOS 3.0\",\"body\":$BODY,\"draft\":false,\"prerelease\":false}")

UPLOAD=$(printf '%s' "$RESP" | python3 -c 'import json,sys
try:
  d = json.load(sys.stdin)
except Exception:
  sys.exit(0)
if d.get("upload_url"):
  print(d["upload_url"].split("{")[0])
  open("/tmp/opencode/rel_url.txt","w").write(d.get("html_url",""))
elif d.get("message"):
  sys.stderr.write("! GitHub said: " + str(d.get("message")) + "\n")' 2>&1 || true)

if [ -n "$UPLOAD" ]; then
  echo "· uploading $ZIP"
  curl -sS -X POST "$UPLOAD?name=$ZIP" \
    -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/zip" \
    --data-binary "@$ZIP" >/dev/null
  echo "· done → $(cat /tmp/opencode/rel_url.txt 2>/dev/null)"
else
  echo "· release response: $(printf '%s' "$RESP" | head -c 200)"
  echo "· check https://github.com/$REPO/releases"
fi
