#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Publishes uOS to GitHub: pushes main, tags v<UOS_VERSION>, creates a release
# and attaches the zip. The version is read from uOS.html, so bump UOS_VERSION
# there and re-run to publish a new version (this overwrites nothing).
#
#   usage:  bash publish.sh <your-username>/uOS
#
# The token is looked up in this order:
#   1. $GH_TOKEN                       (one-off override)
#   2. the macOS Keychain              (only on macOS)
#   3. ~/.git-credentials              (Linux git credential-store)
#   4. an interactive prompt           (hidden input)
#
# It is passed to git through an in-memory credential helper — never in a URL,
# never in the remote, never in your shell history.
#
# ONE-TIME SETUP so you never paste a token again:
#   macOS:  git config --global credential.helper osxkeychain
#   Linux:  git config --global credential.helper store
# then run the script once and paste the token; it is remembered and every
# run after that needs no token. (A missing helper name is harmless — the
# script resets the helper list, so you will not see "not a git command".)
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")"

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "usage: bash publish.sh <your-username>/uOS" >&2
  exit 1
fi

# the version comes straight out of uOS.html, so tagging, the zip name and the
# release always follow the build (bump UOS_VERSION there to ship a new one)
VERSION="$(grep -oE "UOS_VERSION[[:space:]]*=[[:space:]]*'[^']+'" uOS.html | head -n1 | sed -E "s/.*'([^']+)'.*/\1/")"
if [ -z "$VERSION" ]; then
  echo "! could not read UOS_VERSION from uOS.html" >&2
  exit 1
fi
TAG="v$VERSION"
echo "· version $VERSION  (tag $TAG)"

# always rebuild, so the release asset always matches the current source
ZIP="uos-$VERSION.zip"
echo "· building $ZIP"
rm -f "$ZIP"
zip -q -9 "$ZIP" uOS.html README.md RELEASE_NOTES.md

# --------------------------------------------------------- find the token
TOKEN="${GH_TOKEN:-}"

if [ -z "$TOKEN" ] && command -v security >/dev/null 2>&1; then
  # macOS Keychain (what git-credential-osxkeychain stores)
  TOKEN="$(security find-internet-password -s github.com -w 2>/dev/null || true)"
  [ -n "$TOKEN" ] && echo "· token found in the macOS Keychain"
fi

if [ -z "$TOKEN" ] && [ -f "$HOME/.git-credentials" ]; then
  TOKEN="$(sed -n 's|^https://[^:]*:\([^@]*\)@github\.com$|\1|p' "$HOME/.git-credentials" | head -n 1)"
  [ -n "$TOKEN" ] && echo "· token found in ~/.git-credentials"
fi

if [ -z "$TOKEN" ]; then
  printf 'Paste a GitHub token (input hidden, press Enter): '
  read -rs TOKEN || true
  echo
fi
TOKEN="$(printf '%s' "$TOKEN" | tr -d '[:space:]')"

# ---------------------------------------------------------- sanity check
if [ -z "$TOKEN" ]; then
  echo "! no token available." >&2
  echo "  Either run once with GH_TOKEN=github_pat_... or let git remember it:" >&2
  echo "      git config --global credential.helper store     # Linux" >&2
  echo "      git config --global credential.helper osxkeychain  # macOS" >&2
  exit 1
fi

case "$TOKEN" in
  ghp_*)            NEED=40 ;;
  github_pat_*)     NEED=93 ;;
  gho_*|ghs_*|ghu_*) NEED=40 ;;
  *)                NEED=0  ;;
esac
echo "· token length: ${#TOKEN} (a ghp_… token is 40, a github_pat_… token is 93)"
if [ "$NEED" = "0" ]; then
  echo "! that does not look like a GitHub token — it should start with ghp_ or github_pat_." >&2
  exit 1
fi
if [ "${#TOKEN}" -ne "$NEED" ]; then
  echo "! wrong length: this token is ${#TOKEN} characters, but it should be exactly $NEED." >&2
  echo "  Check the clipboard with:  pbpaste | tr -d '[:space:]' | wc -c" >&2
  exit 1
fi

export GIT_TOKEN="$TOKEN"
CRED='!f() { echo username=x-access-token; echo password="$GIT_TOKEN"; }; f'
# the empty credential.helper= resets any global helper first, so a helper that
# doesn't exist on this machine (e.g. osxkeychain on Linux) can't spew errors
gpush(){ git -c credential.helper= -c credential.helper="$CRED" "$@"; }

git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$REPO.git"

# --------------------------------------------------------------- push it
echo "· pushing main"
PUSH_OUT="$(gpush push -u origin main 2>&1)" && PUSH_RC=0 || PUSH_RC=$?
if [ "$PUSH_RC" -ne 0 ]; then
  printf '%s\n' "$PUSH_OUT"
  case "$PUSH_OUT" in
    *"Authentication failed"*|*"Invalid username or token"*|*"could not read Username"*|*"password authentication"*)
      echo >&2
      echo "! GitHub rejected the token — authentication failed, nothing was pushed." >&2
      echo "  Check it is valid, not expired, and has Contents: Read and write on $REPO." >&2
      exit 1 ;;
  esac
  echo "! push rejected — the remote has commits you don't. Merging them in…"
  gpush fetch origin main
  if git merge --allow-unrelated-histories -X ours -m "merge remote history" FETCH_HEAD; then
    gpush push -u origin main
  else
    echo >&2
    echo "! automatic merge failed. Resolve it by hand:" >&2
    echo "    git merge --abort" >&2
    echo "    git push -f origin main    # only if the remote has nothing you need" >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------- tag it
echo "· tagging $TAG"
git tag -f "$TAG"
gpush push -f origin "$TAG"

# ----------------------------------------------------------- the release
echo "· creating the release"
BODY=$(python3 -c 'import json; print(json.dumps(open("RELEASE_NOTES.md").read()))')
API="https://api.github.com/repos/$REPO"

# -L so a renamed repo (GitHub redirects the old name) still resolves.
RESP=$(curl -sSL -X POST "$API/releases" \
  -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
  -d "{\"tag_name\":\"$TAG\",\"target_commitish\":\"main\",\"name\":\"uOS $VERSION\",\"body\":$BODY,\"draft\":false,\"prerelease\":false}")

AUTH=(-H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json")

# read one field out of a JSON blob (stdout only — never merge stderr in,
# or an error message could end up being used as a URL)
jsonval(){ printf '%s' "$1" | python3 -c 'import json,sys
try:
  d = json.load(sys.stdin)
except Exception:
  sys.exit(0)
if isinstance(d, dict):
  print(d.get(sys.argv[1]) or "")' "$2"; }

# a second run must not fail — find the existing release and update it.
# PATCH by tag 404s for this endpoint, so look up the numeric id and use that.
if ! printf '%s' "$RESP" | grep -q '"upload_url"'; then
  case "$RESP" in
    *already_exists*)
      echo "· release $TAG already exists — updating it"
      EXIST=$(curl -sSL "${AUTH[@]}" "$API/releases/tags/$TAG")
      RID=$(jsonval "$EXIST" id)
      if [ -n "$RID" ]; then
        RESP=$(curl -sSL -X PATCH "${AUTH[@]}" "$API/releases/$RID" \
          -d "{\"name\":\"uOS $VERSION\",\"body\":$BODY,\"draft\":false,\"prerelease\":false}")
      else
        echo "! could not find the existing release to update" >&2
      fi ;;
  esac
fi

UPLOAD=$(jsonval "$RESP" upload_url)
UPLOAD="${UPLOAD%%\{*}"
REL_ID=$(jsonval "$RESP" id)
REL_URL=$(jsonval "$RESP" html_url)
MSG=$(jsonval "$RESP" message)

if [ -n "$UPLOAD" ]; then
  # replace the asset if it's already attached, so re-runs stay idempotent
  if [ -n "$REL_ID" ]; then
    OLD=$(curl -sSL "${AUTH[@]}" "$API/releases/$REL_ID/assets" | ZIPNAME="$ZIP" python3 -c 'import json,os,sys
try:
  d = json.load(sys.stdin)
except Exception:
  sys.exit(0)
if isinstance(d, list):
  n = os.environ["ZIPNAME"]
  i = next((a["id"] for a in d if a.get("name") == n), "")
  print(i)' 2>/dev/null || true)
    if [ -n "$OLD" ]; then
      echo "· replacing the existing $ZIP asset"
      curl -sSL -X DELETE "${AUTH[@]}" "$API/releases/assets/$OLD" >/dev/null
    fi
  fi
  echo "· uploading $ZIP"
  UP=$(curl -sSL -X POST "${AUTH[@]}" -H "Content-Type: application/zip" \
    --data-binary "@$ZIP" "$UPLOAD?name=$ZIP")
  case "$UP" in
    *'"state":"uploaded"'*|*'"size"'*) echo "· asset uploaded" ;;
    *) echo "! asset upload said: $(printf '%s' "$UP" | head -c 160)" ;;
  esac
  echo
  echo "done → ${REL_URL:-https://github.com/$REPO/releases}"
else
  [ -n "$MSG" ] && echo "! GitHub said: $MSG" >&2
  echo "· raw response: $(printf '%s' "$RESP" | head -c 200)"
  echo "· check https://github.com/$REPO/releases"
fi
