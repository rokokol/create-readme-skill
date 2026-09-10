#!/usr/bin/env bash
# The whole gate. Nothing here reaches the network, so it is safe to run on pull
# requests — and every check is followed by proof that it can go red, because a
# check that has never failed is a decoration.
#
# Needs: actionlint, shellcheck, shfmt — from PATH; CI provides them via nix develop
set -euo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$HERE"

fail() {
  echo "check: $1" >&2
  exit 1
}

# One source of truth for what gets linted: this list, read by nothing else
scripts=(tests/check.sh tests/check-links.sh tests/check-readme.sh)
docs=(README.md SKILL.md CHANGELOG.md)

echo "== the scripts parse and lint"
for s in "${scripts[@]}"; do bash -n "$s"; done
shellcheck "${scripts[@]}"
shfmt -d -i 2 -ci "${scripts[@]}"

echo "== the workflows pass actionlint"
actionlint .github/workflows/*.yml

echo "== the workflow lint is able to fail"
bad=$(mktemp -d)
trap 'rm -rf "$bad"' EXIT
mkdir -p "$bad/.github/workflows"
cp tests/fixtures/must-fail.yml "$bad/.github/workflows/"
if (cd "$bad" && actionlint .github/workflows/*.yml >/dev/null 2>&1); then
  fail "actionlint passed tests/fixtures/must-fail.yml — it cannot catch anything"
fi

echo "== SKILL.md carries the frontmatter an agent loads it by"
head -1 SKILL.md | grep -qx -- '---' || fail "SKILL.md does not open with a frontmatter block"
front=$(sed -n '2,/^---$/p' SKILL.md)
for key in name description license; do
  printf '%s\n' "$front" | grep -q "^$key:" || fail "SKILL.md frontmatter has no $key"
done
printf '%s\n' "$front" | grep -q '^name: create-readme$' ||
  fail "the skill's name is not what the plugin manifest and the readme call it"

echo "== every relative link in the docs resolves"
./tests/check-links.sh "${docs[@]}"

echo "== the link checker is able to fail"
if ./tests/check-links.sh tests/fixtures/broken-links.md >/dev/null 2>&1; then
  fail "tests/fixtures/broken-links.md passed the link checker — it cannot catch anything"
fi

echo "== this readme obeys the rules this skill hands out"
./tests/check-readme.sh README.md

echo "== each of those rules is able to fail"
# One fixture breaking every rule, and every finding demanded by name: a single
# over-broad rule must not be able to cover for one that has gone dead
out=$(./tests/check-readme.sh tests/fixtures/bad-readme.md 2>&1 || true)
if ./tests/check-readme.sh tests/fixtures/bad-readme.md >/dev/null 2>&1; then
  fail "tests/fixtures/bad-readme.md passed the readme lint — it cannot catch anything"
fi
# The count is taken from the loop rather than typed beside it: a typed "4" stays true
# only until someone adds a fifth rule to the list above
caught=0
for want in \
  'ends with a full stop' \
  'hard-wrapped paragraph' \
  "admonition keyword" \
  'has its own file'; do
  printf '%s\n' "$out" | grep -qF "$want" ||
    fail "the readme lint no longer reports \"$want\" on tests/fixtures/bad-readme.md"
  caught=$((caught + 1))
done
echo "   $caught rules broken, $caught caught"

echo "== and none of them fires on a readme that breaks nothing"
# The other half of the proof, and the half that was missing: a lint proven only able to
# go red is proven only to be loud. Every shape in this fixture is legitimate — an ordered
# list, a table, an admonition done right, a fenced block and an indented one — and each
# was a false positive at some point. An ordered list reddened every document that had
# one, because `1.` and `2.` on consecutive lines read as a paragraph broken in two.
out=$(./tests/check-readme.sh tests/fixtures/quiet-readme.md 2>&1) && quiet=0 || quiet=$?
((quiet == 0)) ||
  fail "the readme lint reported a finding on a readme that breaks no rule:"$'\n'"$out"

echo
echo "check: everything holds"
