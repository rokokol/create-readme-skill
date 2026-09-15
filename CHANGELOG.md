# Changelog

Kept in the shape of [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), dated rather than numbered, and with no `Unreleased` section — a skill is read at whatever revision you have checked out, so whatever is on the default branch is what every reader already has, and a section for work that has landed but not shipped would never close. The rule lives in the [versioning](https://github.com/rokokol/versioning-skill) skill, which owns what has no version

## 2026-09-15

### Changed

- `tests/check-readme.sh` prints its help from a heredoc instead of reading its own header back, which under `bash <(…)` is the pipe bash reads the script from and printed nothing; the network and bash claims stay in the header comment and are no longer part of `--help`
- `check-skill.sh` is vendored from the [skill-authoring](https://github.com/rokokol/skill-authoring-skill) skill, where the rules it checks now live, and reports the rules a skill can break without breaking as warnings on stdout, the exit code unchanged: a `Layout` or install section in runtime, `used to`, a `path:line` citation, a link to a sibling skill, a concrete model id, and the rest its `--help` lists

## 2026-09-12

### Added

- a `macos` workflow and its badge: `check-readme.sh` claims the bash 3.2 macOS ships, and the behaviour half of the gate, `tests/check.sh behaviour`, now runs under the real `/bin/bash` 3.2 on a macOS runner, with constructs planted that only a 3.2 rejects

### Changed

- `check-readme.sh` has the shape of the [bash-best-practices](https://github.com/rokokol/bash-best-practices-skill) family: its header is its help, it names its exit codes and the bash it needs, and a clean run ends with one line on stdout. The gate holds its help to its code with that skill's `check-sh.sh`, vendored beside the other checkers
- the task asks for a well-structured readme rather than a comprehensive one, in line with rule 3, and the role line no longer lists generic virtues

### Fixed

- **`check-readme.sh --help` answered `readme: --help: no such file`**, taking the flag for a path. It prints the usage now, and an unknown flag is a usage error
- **`check-readme.sh` with no readme exited 0**, which reads as a clean readme when nothing was checked. It exits 2 now, and so does a readme that does not exist, which used to exit 1 like a finding

## 2026-09-11

### Changed

- repository-wide `WORKAROUNDS.md`, `DEVIATIONS.md` and `PITFALLS.md` delegate their classification and contents to the [maintainer-docs](https://github.com/rokokol/maintainer-docs-skill) skill; create-readme owns only their `docs-<kind>` header badges and the rule against duplicating them as readme sections

## 2026-09-10

### Changed

- rule 9 leaves whether a repository has a version to the versioning skill, which owns that question, instead of restating it
- the README links to the rules in `SKILL.md` instead of keeping a table of them, which had already fallen a rule behind once
- the badge row opens with an `Agent Skill` badge instead of `Claude Code`: the `SKILL.md` format is read by OpenCode, Codex, Gemini CLI and the rest as well
- the gate runs the ci skill's `check-skill.sh` and `check-pins.sh`, vendored beside `vendor-sync.sh`, which keeps them byte-equal to their source; the CI workflow is `build.yml` now, and so is the badge

### Removed

- `tests/check-links.sh`: the vendored `check-skill.sh` resolves every link and anchor in the same docs, checks the frontmatter too, and proves each check able to fail on every run. Two link checkers side by side were two answers to one question

### Fixed

- **`check-readme.sh` saw a full stop only as the last character**, so one behind closing markup — `.**`, `.)`, a stop inside closing backticks — passed rule 7. It reads through that markup now, and a fixture hiding one each way has to be caught three times
- `check-readme.sh` checked the rules in the order 4, 5, 7, 6; it follows their numbers now
- `SKILL.md` broke its own rule 7: every rule ended with a full stop, while the skill tells every readme to drop it. The rules end bare now
- the README's rules table had no row for rule 8, the project's own logo in the header
- counts written beside the list they count — "the four things", "breaking all four", "the four of them a script can decide", and `4 rules broken, 4 caught` typed by hand next to the list it describes. The gate now takes the number from the loop, so a fifth rule cannot leave it behind

## 2026-09-08

### Added

- **a fixture the lint must stay silent on.** It was proven able to go red and never proven able to stay quiet, which is half a proof: a rule that fires on everything passes that half perfectly. `tests/fixtures/quiet-readme.md` holds a legitimate shape for each rule — an ordered list, a bulleted one, a table, an admonition written correctly, a fenced block and an indented one — and the gate requires no finding on any of them. Both bugs below were false positives on that fixture, and the check was watched catching the first one again with the fix backed out

### Fixed

- **an ordered list was reported as a hard-wrapped paragraph.** Rule 6 knew that a heading, a bullet, a table row, a quote, a badge and an indented line are not prose, and did not know that `1.` and `2.` are not either, so any readme with a numbered list was reddened on every item after the first — found on a document that has two. A numbered list is a list; rule 7 still holds each of its items to ending bare, because a list item is a list item
- **an indented code block was held to the prose rules.** A fenced block was skipped and an indented one was not, so a line of shell ending in a full stop was reported as a paragraph that ends with one. Code is exempt however it is marked

## 2026-09-05

### Changed

- the skill now fires when a readme is **edited**, not only when one is created. Its description said "Create a README.md file for the project", so it never loaded on the occasion its rules matter most: a one-word change to a hard-wrapped paragraph reflows every line after it, and nobody notices until the diff is unreadable. The description is in the family shape now — what it is, when to use it, and the triggers that reach it, Russian included
- rule 1 states the extra obligation an edit carries: the rules apply to the whole file rather than to the lines being touched, so a readme that already breaks rule 6 or 7 is fixed in the same commit instead of gaining one more paragraph in the old shape

## 2026-09-03

### Added

- the skill became a repository of its own, with a `tests/check.sh` gate proven able to fail against the fixtures in `tests/fixtures/`
- `tests/check-readme.sh`, which takes **any** readme and decides the four rules a script can decide: bare paragraph ends, one line per paragraph, the admonition keyword alone on its line, and no heading for something that has its own file. That is what makes the rules worth more than a review comment — they can be enforced in the repository they are handed to
- the nine rules themselves: structure and tone borrowed from the family's own readmes, no overused emoji, no section that has a dedicated file (`LICENSE`, `CONTRIBUTING`, `CHANGELOG`), GFM with GitHub admonitions, one paragraph per line, no trailing full stop, a logo in the header where one exists, and never a version claim a repository cannot back — a skill or a docs-only repo gets no version badge and no tag-pinned install line
