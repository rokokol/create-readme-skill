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
scripts=(tests/check.sh tests/check-readme.sh check-skill.sh check-pins.sh vendor-sync.sh)

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

echo "== the vendored checkers are byte-equal to their source"
# check-skill.sh and check-pins.sh come from the ci skill: every copy must still be the
# blob .github/vendor.lock records, so one edited here instead of at its source fails by name
./vendor-sync.sh check

echo "== the workflows take no tool from a registry"
# The ci skill's pin guard, which proves on every run that it catches each unpinned shape
./check-pins.sh

echo "== SKILL.md loads, every reference is reachable, and every link and anchor resolves"
# The one gate every skill repository shares: frontmatter, the name, links and anchors in
# every doc, each check proven able to fail on a planted copy on every run
./check-skill.sh -n create-readme .

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

echo "== a full stop behind closing markup is still a full stop"
# The rule read the last character only, so `.**`, `.)` and a stop inside closing
# backticks all passed. Each line of this fixture hides one that way, and each is demanded
stops=$(./tests/check-readme.sh tests/fixtures/stop-behind-markup.md 2>&1 | grep -cF 'ends with a full stop' || true)
((stops == 3)) ||
  fail "the readme lint caught $stops of the 3 full stops behind markup in tests/fixtures/stop-behind-markup.md"

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
