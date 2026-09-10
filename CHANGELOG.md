# Changelog

Kept in the shape of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), dated rather than numbered, and with no `Unreleased` section — a skill is read at whatever revision you have checked out, so whatever is on the default branch is what every reader already has, and a section for work that has landed but not shipped would never close. The rule lives in the [ci](https://github.com/rokokol/ci-skill) skill, which owns what has no version

## 2026-09-10

### Fixed

- `SKILL.md` broke its own rule 7: every rule ended with a full stop, while the skill tells every readme to drop it. The rules end bare now
- the README's rules table had no row for rule 8, the project's own logo in the header
- counts written beside the list they count — "the four things", "breaking all four", "the four of them a script can decide", and `4 rules broken, 4 caught` typed by hand next to the list it describes. The gate now takes the number from the loop, so a fifth rule cannot leave it behind

## 2026-09-08

### Fixed

- **an ordered list was reported as a hard-wrapped paragraph.** Rule 6 knew that a heading, a bullet, a table row, a quote, a badge and an indented line are not prose, and did not know that `1.` and `2.` are not either, so any readme with a numbered list was reddened on every item after the first — found on a document that has two. A numbered list is a list; rule 7 still holds each of its items to ending bare, because a list item is a list item
- **an indented code block was held to the prose rules.** A fenced block was skipped and an indented one was not, so a line of shell ending in a full stop was reported as a paragraph that ends with one. Code is exempt however it is marked

### Added

- **a fixture the lint must stay silent on.** It was proven able to go red and never proven able to stay quiet, which is half a proof: a rule that fires on everything passes that half perfectly. `tests/fixtures/quiet-readme.md` holds a legitimate shape for each rule — an ordered list, a bulleted one, a table, an admonition written correctly, a fenced block and an indented one — and the gate requires no finding on any of them. Both bugs above were false positives on that fixture, and the check was watched catching the first one again with the fix backed out

## 2026-09-05

### Changed

- the skill now fires when a readme is **edited**, not only when one is created. Its description said "Create a README.md file for the project", so it never loaded on the occasion its rules matter most: a one-word change to a hard-wrapped paragraph reflows every line after it, and nobody notices until the diff is unreadable. The description is in the family shape now — what it is, when to use it, and the triggers that reach it, Russian included
- rule 1 states the extra obligation an edit carries: the rules apply to the whole file rather than to the lines being touched, so a readme that already breaks rule 6 or 7 is fixed in the same commit instead of gaining one more paragraph in the old shape

## 2026-09-03

### Added

- the skill became a repository of its own, with a `tests/check.sh` gate proven able to fail against the fixtures in `tests/fixtures/`
- `tests/check-readme.sh`, which takes **any** readme and decides the four rules a script can decide: bare paragraph ends, one line per paragraph, the admonition keyword alone on its line, and no heading for something that has its own file. That is what makes the rules worth more than a review comment — they can be enforced in the repository they are handed to
- the nine rules themselves: structure and tone borrowed from the family's own readmes, no overused emoji, no section that has a dedicated file (`LICENSE`, `CONTRIBUTING`, `CHANGELOG`), GFM with GitHub admonitions, one paragraph per line, no trailing full stop, a logo in the header where one exists, and never a version claim a repository cannot back — a skill or a docs-only repo gets no version badge and no tag-pinned install line
