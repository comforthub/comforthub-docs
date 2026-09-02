#!/usr/bin/env bash
# The gate. Every rule in CLAUDE.md that a script can check is checked here.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
say() { echo "FAIL: $*"; fail=1; }

pages=$(find . -name '*.mdx' -not -path './node_modules/*' -not -path './snippets/*' \
  -not -path './templates/*' -not -path './drafts/*' -not -name '*.draft.mdx' \
  | sed 's|^\./||; s|\.mdx$||' | sort)

front() { awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$1.mdx"; }
body()  { awk 'NR==1 && $0!="---"{p=1} NR>1 && !p && $0=="---"{p=1; next} p' "$1.mdx"; }
has()   { grep -q -E "$2" <<<"$1"; }

# 1. Every page has a title, a description, and a kind.
for p in $pages; do
  f=$(front "$p")
  has "$f" '^title:' || say "$p.mdx has no title"
  has "$f" '^description:' || say "$p.mdx has no description"
  has "$f" '^kind: *(hub|explanation|how-to|reference) *$' \
    || say "$p.mdx needs 'kind: hub | explanation | how-to | reference'"
done

# 2. Every page is in the menu, and every menu entry is a real page.
nav=$(node -e '
const keys = ["pages","groups","tabs","anchors","dropdowns","versions","languages","products","menu"];
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
  --include='*.mdx' --include='docs.json' . --exclude-dir=templates && say "template text is still in the docs"
grep -l 'Starter Kit' logo/*.svg favicon.svg 2>/dev/null && say "the starter kit logo is still in logo/ (see above)"

# 4. Nothing that looks like a key, token, or password.
grep -rn -E 'sk_(live|test)_[A-Za-z0-9]{8,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|password *[:=] *\S{6,}' \
  --include='*.mdx' --include='*.md' --include='*.json' --exclude-dir=node_modules --exclude-dir=.git . \
  && say "something above looks like a secret"

# 5. A finished page has the sections its kind requires, and ends with Related.
#    Pages tagged TODO are stubs and skip this.
for p in $pages; do
  f=$(front "$p"); b=$(body "$p")
  has "$f" '^tag: *"?TODO"?' && continue
  kind=$(sed -n 's/^kind: *//p' <<<"$f" | tr -d ' ')
  case "$kind" in
    how-to)
      has "$b" '^## Before you start' || say "$p.mdx is a how-to with no '## Before you start'"
      has "$b" '^## How you know it worked' || say "$p.mdx is a how-to with no '## How you know it worked'"
      ;;
    explanation)
      has "$f" '^title: *"?How to ' && say "$p.mdx is an explanation but its title says 'How to'; that is a how-to"
      ;;
  esac
  if [ "$kind" != hub ]; then
    has "$b" '^## Related' || say "$p.mdx has no '## Related' section"
    awk '/^## Related/{r=1} r' <<<"$b" | grep -q '](/' || say "$p.mdx has a Related section with no link to another page"
  fi
done

# 6. Code names stay out of prose. Zoho-style Names_With_Underscores, schema.table names,
#    and snake_case words fail everywhere except a page with 'raw-names: allowed'.
schemas='core|operations|billing|catalog|communication|integrations|app|checklists|scheduling|sales|payroll|assistant|corpus|knowledge|private|public|guard|analytics|auth|storage'
allowed=$(grep -v '^#' scripts/allowed-names.txt | grep -v '^$' || true)
for p in $pages; do
  f=$(front "$p")
  has "$f" '^raw-names: *allowed' && continue
  hits=$(body "$p" \
    | grep -v -E '^import ' \
    | sed -E 's#https?://[^ )>"]+##g' \
    | grep -n -o -E "\b[A-Z][A-Za-z0-9]*(_[A-Za-z0-9]+)+\b|\b($schemas)\.[a-z][a-z0-9_]*\b|\b[a-z][a-z0-9]*(_[a-z0-9]+)+\b" || true)
  while IFS= read -r h; do
    [ -z "$h" ] && continue
    word=${h#*:}
    grep -qxF "$word" <<<"$allowed" && continue
    say "$p.mdx line ${h%%:*}: '$word' looks like a code name. Say the human name, or put it on reference/names"
  done <<<"$hits"
done

# 7. No robotic phrases. The list is scripts/banned-phrases.txt.
banned=$(grep -v '^#' scripts/banned-phrases.txt | grep -v '^$' || true)
for p in $pages; do
  b=$(body "$p")
  while IFS= read -r phrase; do
    [ -z "$phrase" ] && continue
    hits=$(grep -n -i -F -- "$phrase" <<<"$b" || true)
    [ -z "$hits" ] && continue
    while IFS= read -r l; do
      say "$p.mdx line ${l%%:*}: banned phrase '$phrase'. Say the plain thing"
    done <<<"$hits"
  done <<<"$banned"
done

# 8. Headings are sentence case. A capitalised word after the first must be a known proper noun.
nouns=$(grep -v '^#' scripts/proper-nouns.txt | grep -v '^$' || true)
for p in $pages; do
  heads=$(body "$p" | grep -n -E '^#{2,} ' || true)
  [ -z "$heads" ] && continue
  while IFS= read -r line; do
    n=${line%%:*}; text=$(sed -E 's/^[0-9]+:#+ //' <<<"$line")
    clean=$(sed -E 's/[^A-Za-z0-9 -]//g' <<<"$text")
    case "$clean" in *" "*) rest=${clean#* } ;; *) continue ;; esac
    for w in $rest; do
      case "$w" in [A-Z]*) grep -qxF "$w" <<<"$nouns" || say "$p.mdx line $n: heading '$text' is not sentence case ('$w'). Add it to scripts/proper-nouns.txt if it is a name" ;; esac
    done
  done <<<"$heads"
done

# 9. The site builds cleanly and has no broken links (needs the mint CLI).
if command -v mint >/dev/null; then
  mint validate >/dev/null 2>&1 || say "the site does not build cleanly (run: mint validate)"
  mint broken-links >/dev/null 2>&1 || say "broken links (run: mint broken-links)"
else
  echo "skip: mint CLI not installed, so the build and links were not checked"
fi

[ "$fail" = 0 ] && echo "ok"
exit "$fail"
