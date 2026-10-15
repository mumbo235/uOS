#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Publishes uOS to GitHub: pushes main, tags v3.0, creates a release and
# attaches the zip.
#
#   usage:  bash publish.sh <your-username>/uos
#       or: GH_TOKEN=github_pat_... bash publish.sh <your-username>/uos
#
# The token is read from stdin (hidden) or from $GH_TOKEN. It is passed to git
# through an in-memory credential helper, never in a URL, never in the remote
# and never in your shell history.
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

# ---------------------------------------------------------------- the token
TOKEN="${GH_TOKEN:-}"
if [ -z "$TOKEN" ]; then
  printf 'Paste a FRESH GitHub token (input hidden, press Enter): '
  read -rs TOKEN || true
  echo
fi
TOKEN="$(printf '%s' "$TOKEN" | tr -d '[:space:]')"

case "$TOKEN" in
  ghp_*)            NEED=40 ;;
  github_pat_*)     NEED=93 ;;
  gho_*|ghs_*|ghu_*) NEED=40 ;;
  *)                NEED=0  ;;
esac

echo "· token length: ${#TOKEN} (a ghp_… token is 40, a github_pat_… token is 93)"

if [ "$NEED" = "0" ]; then
  echo "! that does not look like a GitHub token — it should start with ghp_ or github_pat_." >&2
  echo "  Create one at github.com/settings/personal-access-tokens" >&2
  exit 1
fi
if [ "${#TOKEN}" -ne "$NEED" ]; then
  echo "! wrong length: this token is ${#TOKEN} characters, but it should be exactly $NEED." >&2
  echo "  The paste was probably cut short or picked up an extra character." >&2
  echo "  On macOS you can check the clipboard with:" >&2
  echo "      pbpaste | tr -d '[:space:]' | wc -c" >&2
  exit 1
fi

# ------------------------------------------------------------------ pushing
export GIT_TOKEN="$TOKEN"
CRED='!f() { echo username=x-access-token; echo password="$GIT_TOKEN"; }; f'

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$REPO.git"

echo "· pushing main"
PUSH_OUT="$(git -c credential.helper="$CRED" push -u origin main 2>&1)" && PUSH_RC=0 || PUSH_RC=$?
if [ "$PUSH_RC" -ne 0 ]; then
  printf '%s\n' "$PUSH_OUT"
  case "$PUSH_OUT" in
    *"Authentication failed"*|*"Invalid username or token"*|*"could not read Username"*|*"password authentication"*)
      echo >&2
      echo "! GitHub rejected the token — authentication failed, nothing was pushed." >&2
      echo "  Check the token is valid, not expired, and has Contents: Read and write on $REPO." >&2
      exit 1 ;;
  esac
  echo "! push rejected — the remote has commits you don't. Merging them in…"
  git -c credential.helper="$CRED" fetch origin main
  if git merge --allow-unrelated-histories -X ours -m "merge remote history" FETCH_HEAD; then
    git -c credential.helper="$CRED" push -u origin main
  else
    echo >&2
    echo "! automatic merge failed. Resolve it by hand:" >&2
    echo "    git merge --abort" >&2
    echo "    git push -f origin main    # only if the remote has nothing you need" >&2
    exit 1
  fi
fi

# ----------------------------------------------------------------- tag it
echo "· tagging v3.0"
git tag -f v3.0
git -c credential.helper="$CRED" push -f origin v3.0

# ------------------------------------------------------------ the release
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
