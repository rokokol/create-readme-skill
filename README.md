<div align="center">

# create-readme skill

**Readmes that come out looking like the rest of them ( ˶ˆ ᗜ ˆ˵ )**

![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?style=flat&logo=anthropic&logoColor=white)
![Markdown](https://img.shields.io/badge/Markdown-000000?style=flat&logo=markdown&logoColor=white)
![no dependencies](https://img.shields.io/badge/dependencies-none-3DA639?style=flat)
[![license](https://img.shields.io/badge/MIT-3DA639?style=flat)](LICENSE)
[![ci](https://github.com/rokokol/create-readme-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/rokokol/create-readme-skill/actions/workflows/ci.yml)

</div>

A readme is the file every visitor reads and nobody owns, so it gets rewritten from scratch in every repository and comes out different every time. This skill fixes the parts that are not worth re-deciding: what the header carries, what belongs in a dedicated file instead of a section, and the two formatting habits that decide whether the next diff is readable

It is a prompt, not a generator: the agent reads the actual repository and writes about what is there. Tone is anchored to a named set of readmes rather than to adjectives — "concise and appealing" means nothing to a model, six files it can read mean quite a lot

The rules are opinions, and they are mine. They are also the reason a stranger can tell that two of these repositories belong to the same person without looking at the owner

## Contents

- [Install](#install)
- [The rules](#the-rules)
- [Tests](#tests)
- [Layout](#layout)

## Install

```sh
git clone git@github.com:rokokol/create-readme-skill ~/.claude/skills/create-readme
```

> [!NOTE]
> A skill has no version to pin — it is read at whatever revision you have checked out, so `git pull` is the whole upgrade path

Then ask Claude Code to write the readme, or reach for the skill by name. [SKILL.md](SKILL.md) is the whole of it

## The rules

| | |
|---|---|
| **Read the repository first** | The readme describes what is in the tree, in the order someone new needs it. A senior engineer's readme, not a template with the project's name pasted into it |
| **Anchor the tone to real files** | Six readmes are named by URL as the reference for structure and voice, so "appealing and informative" resolves to something checkable |
| **Sections that have a file do not get a section** | No `LICENSE`, `CONTRIBUTING` or `CHANGELOG` heading. What the project's own licence does not cover — third-party art, fonts, transcribed text — goes in `ASSETS.md`, linked from an `assets` badge, and the disclaimer lives there only |
| **GFM, admonitions, few emoji** | GitHub's own `> [!NOTE]` boxes where they earn the space, with the keyword alone on its line — otherwise GitHub renders a plain quote and the box silently never appears |
| **One paragraph is one line** | Never hard-wrap: GitHub soft-wraps for you, and a manual break means a one-word edit reflows every line after it. Holds for list items and table cells too. The one exception is a fenced block where the alignment is the content |
| **A paragraph ends bare** | Sentences inside it are punctuated normally; the last one drops the full stop. It is the single most visible thing these readmes share |
| **The project's own logo in the header** | Where the project has a logo or icon, the readme's header carries it |
| **Never claim a version the project does not have** | A repo that is only read at whatever revision is checked out — a skill, a prompt library, docs — gets no version badge, no "requires vX", and an install line that clones the default branch |

## Tests

```sh
nix develop -c ./tests/check.sh
```

The rules above are handed out to other repositories, so the gate holds this one to the ones a script can decide — bare paragraph ends, one line per paragraph, the admonition keyword alone on its line, no heading for something that has its own file. `tests/check-readme.sh` takes any readme, which is what makes it worth more than a review comment

Then every check is made to fail on purpose: a fixture breaking every one of them at once, with each finding demanded by name so one live rule cannot cover for a dead one, a fixture with a dangling path and a dead anchor for the link checker, and a broken workflow actionlint has to reject

## Layout

```
SKILL.md               the skill itself — the role, the task, the rules
tests/check.sh         the self-testing gate
tests/check-readme.sh  the mechanical half of the rules, runnable on any readme
tests/check-links.sh   relative links and heading anchors, network links left alone
tests/fixtures/        the known-bad inputs each check is proven to catch
```
