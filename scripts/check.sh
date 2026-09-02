#!/usr/bin/env bash
# The gate. Every rule in CLAUDE.md that a script can check is checked here.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
say() { echo "FAIL: $*"; fail=1; }

pages=$(find . -name '*.mdx' -not -path './node_modules/*' -not -path './snippets/*' \
  -not -path './drafts/*' -not -name '*.draft.mdx' | sed 's|^\./||; s|\.mdx$||' | sort)

# 1. Every page has a title and a one-line description.
for p in $pages; do
  head -n 20 "$p.mdx" | grep -q '^title:' || say "$p.mdx has no title"
  head -n 20 "$p.mdx" | grep -q '^description:' || say "$p.mdx has no description"
done

# 2. Every page is in the menu, and every menu entry is a real page.
nav=$(node -e '
const keys = ["pages","groups","tabs","anchors","dropdowns","versions","languages"];
const out = [];
(function walk(x) {
  if (typeof x === "string") out.push(x);
  else if (Array.isArray(x)) x.forEach(walk);
  else if (x && typeof x === "object") keys.forEach(k => k in x && walk(x[k]));
})(require("./docs.json").navigation);
console.log(out.join("\n"));' | sort)
for p in $pages; do
  grep -qx "$p" <<<"$nav" || say "$p.mdx is not in the docs.json menu"
done
for n in $nav; do
  [ -f "$n.mdx" ] || [ -f "$n.md" ] || say "docs.json lists $n but there is no such page"
done

# 3. No leftover template text.
grep -rn -E 'Mintlify Starter Kit|your-package|Write a short description|Welcome to your project|mintlify\.com/docs/components' \
  --include='*.mdx' --include='docs.json' . && say "template text is still in the docs"

# 4. Nothing that looks like a key, token, or password.
grep -rn -E 'sk_(live|test)_[A-Za-z0-9]{8,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|password *[:=] *\S{6,}' \
  --include='*.mdx' --include='*.md' --include='*.json' --exclude-dir=node_modules --exclude-dir=.git . \
  && say "something above looks like a secret"

# 5. The site builds cleanly and has no broken links (needs the mint CLI).
if command -v mint >/dev/null; then
  mint validate || say "the site does not build cleanly"
  mint broken-links || say "broken links"
else
  echo "skip: mint CLI not installed, so the build and links were not checked"
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
