# Changelog

Kept in the shape of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), dated rather than numbered — a skill is read at whatever revision you have checked out, so there is no version to bump

## Unreleased

### Changed

- the skill now fires when a readme is **edited**, not only when one is created. Its description said "Create a README.md file for the project", so it never loaded on the occasion its rules matter most: a one-word change to a hard-wrapped paragraph reflows every line after it, and nobody notices until the diff is unreadable. The description is in the family shape now — what it is, when to use it, and the triggers that reach it, Russian included
- rule 1 states the extra obligation an edit carries: the rules apply to the whole file rather than to the lines being touched, so a readme that already breaks rule 6 or 7 is fixed in the same commit instead of gaining one more paragraph in the old shape

## 2026-09-03

### Added

- the skill became a repository of its own, with a `tests/check.sh` gate proven able to fail against the fixtures in `tests/fixtures/`
- `tests/check-readme.sh`, which takes **any** readme and decides the four rules a script can decide: bare paragraph ends, one line per paragraph, the admonition keyword alone on its line, and no heading for something that has its own file. That is what makes the rules worth more than a review comment — they can be enforced in the repository they are handed to
- the nine rules themselves: structure and tone borrowed from the family's own readmes, no overused emoji, no section that has a dedicated file (`LICENSE`, `CONTRIBUTING`, `CHANGELOG`), GFM with GitHub admonitions, one paragraph per line, no trailing full stop, a logo in the header where one exists, and never a version claim a repository cannot back — a skill or a docs-only repo gets no version badge and no tag-pinned install line
