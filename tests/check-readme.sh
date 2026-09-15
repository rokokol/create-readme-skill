#!/usr/bin/env bash
# Needs bash 3.2 and POSIX tools only
set -euo pipefail

usage() {
  cat <<'EOF'
The mechanical half of the create-readme skill's rules, checked on any readme

  check-readme.sh README...

  -h, --help   print this and exit

Only the rules a script can decide are here: whether a paragraph ends bare, whether it
occupies one line, whether an admonition is shaped the way GitHub wants it, and whether
a section duplicates a file that already exists. Tone, structure and honesty about
versions stay a reading job — this catches what would otherwise be re-caught by eye on
every readme. A finding is one line on stderr, README:LINE: what, so an editor can jump
to it

Nothing here reaches the network.
Exit 0 when every readme keeps the rules, 1 with one line per finding, 2 on a usage
error or a readme that does not exist
EOF
}

die() { # the request itself is wrong
  printf 'check-readme: %s\n' "$1" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      usage >&2
      exit 2
      ;;
    *) break ;;
  esac
done
# No readme is nothing to check, and nothing checked must not read as a clean readme
(($# > 0)) || {
  usage >&2
  exit 2
}
# Every path is looked at before any is read, so a typo is a refusal rather than a
# half-checked run whose findings hide it
for file in "$@"; do
  [[ -f "$file" ]] || die "$file: no such file"
done

fail=0
file=''
n=0
report() { # report MESSAGE — about $file, at line $n
  printf '%s:%s: %s\n' "$file" "$n" "$1" >&2
  fail=1
}

for file in "$@"; do
  inside=0
  prev_prose=0
  n=0
  while IFS= read -r line; do
    n=$((n + 1))
    case $line in
      '```'*)
        inside=$((1 - inside))
        prev_prose=0
        continue
        ;;
    esac
    [ "$inside" -eq 1 ] && continue

    # An indented block is code as much as a fenced one is, and the rules below are about
    # prose: a line of shell that ends in a full stop was being reported as a paragraph
    if [ "${line#    }" != "$line" ] || [ "${line#	}" != "$line" ]; then
      prev_prose=0
      continue
    fi

    # Rule 4: sections that have their own file at the root of a repository. The level-one
    # heading is the readme's own title, the project's name, which may well be a contributing
    # skill or a changelog tool; the sections below it are what the rule is about
    case $line in
      '# '*) ;;
      '#'*[Ll]icense* | '#'*[Cc]ontributing* | '#'*[Cc]hangelog*)
        report "a heading for something that has its own file: ${line}"
        ;;
    esac

    # Rule 5: the admonition keyword takes its line alone, or GitHub renders a
    # plain quote instead of the box
    case $line in
      '> [!'*']'?*)
        report "text on the admonition keyword's line — it belongs below"
        ;;
    esac

    # Rule 6: one paragraph is one line. Badge rows, tables, lists, headings and
    # html are not paragraphs; two prose lines in a row are a hard wrap. A numbered
    # list is a list: `1.` and `2.` on consecutive lines were being read as one
    # paragraph broken in two, and any document with an ordered list was reddened
    if [[ "$line" =~ ^[0-9]+[.\)][[:space:]] ]]; then
      prev_prose=0
    else
      case $line in
        '' | '#'* | '-'* | '*'* | '|'* | '>'* | '<'* | '!['* | '['* | ' '*)
          prev_prose=0
          ;;
        *)
          [ "$prev_prose" -eq 1 ] && report "a hard-wrapped paragraph — one paragraph is one line"
          prev_prose=1
          ;;
      esac
    fi

    # Rule 7: a paragraph, a list item and a table cell all end bare — read through the
    # markup that can close after the stop, since `.**`, `.)` and `` .` `` end on one too
    bare=$line
    while case $bare in *[*_\)\`\"]) true ;; *) false ;; esac do
      bare=${bare%?}
    done
    case $bare in
      *..) ;;
      *[!.].)
        report "ends with a full stop"
        ;;
    esac
  done <"$file"
done

((fail == 0)) || exit 1
printf 'check-readme: %s readme(s) keep every rule a script can decide\n' "$#"
