#!/usr/bin/env bash
# The whole gate. Nothing here reaches the network, so it is safe to run on pull
# requests — and every check is followed by proof that it can go red, because a
# check that has never failed is a decoration.
#
#   check.sh [lint|behaviour|all]
#
# Two halves, because they need different things. `lint` reads what the repository ships
# — the scripts, the workflows, SKILL.md and the vendored copies — with the linters the
# flake's dev shell pins: actionlint, shellcheck, shfmt. `behaviour` runs check-readme.sh
# on the readme and the fixtures and needs only bash and POSIX tools, so it runs under the
# bash 3.2 macOS ships, which is what check-readme.sh claims to run on. `all`, the
# default, is both.
#
#   nix develop -c ./tests/check.sh
#   /bin/bash ./tests/check.sh behaviour        # on a macOS runner, CHECK_BASH32=1
set -euo pipefail

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$HERE"

fail() {
  printf 'check: %s\n' "$1" >&2
  exit 1
}

# One source of truth for what gets linted: this list, read by nothing else
scripts=(tests/check.sh tests/check-readme.sh check-skill.sh check-pins.sh check-sh.sh vendor-sync.sh)

# Every script below runs under the bash running this gate, not under whatever bash its
# shebang finds: on a macOS runner the gate is started as /bin/bash to prove the 3.2 macOS
# ships, while `env bash` would find Homebrew's 5
readme() { "$BASH" "$HERE/tests/check-readme.sh" "$@"; }
checker() { "$BASH" "$HERE/check-sh.sh" "$@"; }

# With a template, so a crashed run's leftovers say whose they are
work=$(mktemp -d "${TMPDIR:-/tmp}/check.XXXXXX")
trap 'rm -rf "$work"' EXIT

mode="${1:-all}"
case "$mode" in
  lint | behaviour | all) ;;
  *)
    printf 'check: no such mode: %s — lint, behaviour or all\n' "$mode" >&2
    exit 2
    ;;
esac

tools=()
[[ "$mode" == behaviour ]] || tools+=(actionlint shellcheck shfmt)
missing=()
for tool in "${tools[@]+"${tools[@]}"}"; do
  command -v "$tool" >/dev/null || missing+=("$tool")
done
((${#missing[@]} == 0)) ||
  fail "missing: ${missing[*]} — they are pinned in the flake, so run this as: nix develop -c ./tests/check.sh"

check_lint() {
  echo "== the scripts parse and lint"
  for s in "${scripts[@]}"; do bash -n "$s"; done
  shellcheck "${scripts[@]}"
  shfmt -d -i 2 -ci "${scripts[@]}"

  echo "== the workflows pass actionlint"
  actionlint .github/workflows/*.yml

  echo "== the workflow lint is able to fail"
  mkdir -p "$work/bad/.github/workflows"
  cp tests/fixtures/must-fail.yml "$work/bad/.github/workflows/"
  if (cd "$work/bad" && actionlint .github/workflows/*.yml >/dev/null 2>&1); then
    fail "actionlint passed tests/fixtures/must-fail.yml — it cannot catch anything"
  fi

  echo "== the vendored checkers are byte-equal to their source"
  # check-skill.sh, check-pins.sh and check-sh.sh come from the ci and bash-best-practices
  # skills: every copy must still be the blob .github/vendor.lock records, so one edited
  # here instead of at its source fails by name
  ./vendor-sync.sh check

  echo "== the workflows take no tool from a registry"
  # The ci skill's pin guard, which proves on every run that it catches each unpinned shape
  ./check-pins.sh

  echo "== SKILL.md loads, every reference is reachable, and every link and anchor resolves"
  # The one gate every skill repository shares: frontmatter, the name, links and anchors in
  # every doc, each check proven able to fail on a planted copy on every run
  ./check-skill.sh -n create-readme .
}

check_behaviour() {
  echo "== check-readme.sh answers to its own help"
  # The bash-best-practices skill's checker, vendored like the ones above: the header is the
  # help, and every flag and exit code the script has is named there, held both ways. It
  # proves each of its own checks able to fail on every run. SKILL.md and the readme send
  # people to it, so every flag they give it has to be one it parses
  checker -m SKILL.md -m README.md tests/check-readme.sh

  echo "== check-readme.sh refuses what it was not given"
  # A lint that exits 0 with nothing to read reads as a clean readme, and one that takes
  # --help for a path answers every question with "no such file"; both are a usage error
  refuses "no readme at all"
  refuses "an unknown flag" --nope README.md
  refuses "a readme that does not exist" README.md tests/fixtures/no-such-readme.md
  # Taken for a path, an unknown flag exits 2 as well, as a missing file, so the code alone
  # cannot tell the two apart: the usage is what says it was read as a flag
  out=$(readme --nope README.md 2>&1 || true)
  [[ "$out" == *"check-readme.sh README..."* ]] ||
    fail "check-readme.sh took an unknown flag for a readme instead of printing its usage: $out"

  echo "== this readme obeys the rules this skill hands out"
  readme README.md

  echo "== each of those rules is able to fail"
  # One fixture breaking every rule, and every finding demanded by name: a single
  # over-broad rule must not be able to cover for one that has gone dead
  out=$(readme tests/fixtures/bad-readme.md 2>&1 || true)
  if readme tests/fixtures/bad-readme.md >/dev/null 2>&1; then
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
  stops=$(readme tests/fixtures/stop-behind-markup.md 2>&1 | grep -cF 'ends with a full stop' || true)
  ((stops == 3)) ||
    fail "the readme lint caught $stops of the 3 full stops behind markup in tests/fixtures/stop-behind-markup.md"

  echo "== and none of them fires on a readme that breaks nothing"
  # The other half of the proof, and the half that was missing: a lint proven only able to
  # go red is proven only to be loud. Every shape in this fixture is legitimate — an ordered
  # list, a table, an admonition done right, a fenced block and an indented one — and each
  # was a false positive at some point. An ordered list reddened every document that had
  # one, because `1.` and `2.` on consecutive lines read as a paragraph broken in two.
  out=$(readme tests/fixtures/quiet-readme.md 2>&1) && quiet=0 || quiet=$?
  ((quiet == 0)) ||
    fail "the readme lint reported a finding on a readme that breaks no rule:"$'\n'"$out"

  # check-readme.sh claims bash 3.2, and a grep for newer syntax is a proxy; the mechanism
  # is this half under the real 3.2, with two constructs planted that only a 3.2 rejects.
  # Under a newer bash they are no defect at all, so this block runs only where
  # CHECK_BASH32 says which bash this is, and first checks that claim
  if [[ -n "${CHECK_BASH32:-}" ]]; then
    echo "== this bash is the 3.2 the proof is about"
    ((BASH_VERSINFO[0] == 3)) ||
      fail "CHECK_BASH32 is set, but this is bash $BASH_VERSION — on macOS, run: /bin/bash ./tests/check.sh behaviour"
    ! "$BASH" -c 'declare -A m' >/dev/null 2>&1 || fail "CHECK_BASH32 is set, but this bash accepts declare -A"
    awk '{ print } /^set -euo pipefail$/ && !done { print "declare -A check_readme_probe || exit 70"; done = 1 }' \
      tests/check-readme.sh >"$work/probe.sh"
    status=0
    "$BASH" "$work/probe.sh" README.md >/dev/null 2>&1 || status=$?
    ((status == 70)) || fail "a check-readme.sh that declares an associative array ran under this bash (got $status) — this is not a 3.2"
    # mapfile does not exist here, so a lint reading its readme with it dies on the spot
    # under set -e — the class of regression only this bash catches, since a newer one
    # runs the same line without a word
    sed 's/^  while IFS= read -r line; do$/  mapfile -t lines <\/dev\/null; while IFS= read -r line; do/' \
      tests/check-readme.sh >"$work/mapfile.sh"
    grep -q 'mapfile -t lines' "$work/mapfile.sh" || fail "the mapfile plant did not land in check-readme.sh"
    out=$("$BASH" "$work/mapfile.sh" README.md 2>&1) && fail "a check-readme.sh reading its readme with mapfile passed under this bash"
    [[ "$out" == *"mapfile: command not found"* ]] ||
      fail "the mapfile plant failed for a reason other than mapfile being absent: $out"
  fi
}

refuses() { # refuses WHAT ARGS... — check-readme.sh must exit 2 on ARGS
  local what=$1 rc=0
  shift
  readme "$@" >/dev/null 2>&1 || rc=$?
  ((rc == 2)) || fail "check-readme.sh exited $rc on $what, where a usage error is 2"
}

case "$mode" in
  lint) check_lint ;;
  behaviour) check_behaviour ;;
  all)
    check_lint
    check_behaviour
    ;;
esac

echo
echo "check: everything holds"
