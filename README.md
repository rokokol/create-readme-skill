<div align="center">

# create-readme skill

**Readmes that come out looking like the rest of them ( ˶ˆ ᗜ ˆ˵ )**

[![Agent Skill](https://img.shields.io/badge/Agent_Skill-6E56CF?style=flat)](https://agentskills.io)
![Markdown](https://img.shields.io/badge/Markdown-000000?style=flat&logo=markdown&logoColor=white)
![no dependencies](https://img.shields.io/badge/dependencies-none-3DA639?style=flat)
[![license](https://img.shields.io/badge/MIT-3DA639?style=flat)](LICENSE)
[![ci](https://github.com/rokokol/create-readme-skill/actions/workflows/build.yml/badge.svg)](https://github.com/rokokol/create-readme-skill/actions/workflows/build.yml)

</div>

A readme is the file every visitor reads and nobody owns, so it gets rewritten from scratch in every repository and comes out different every time. This skill fixes the parts that are not worth re-deciding: what the header carries, what belongs in a dedicated file instead of a section, and the two formatting habits that decide whether the next diff is readable

It is a prompt, not a generator: the agent reads the actual repository and writes about what is there. Tone is anchored to a named set of readmes rather than to adjectives — "concise and appealing" means nothing to a model, the readmes `SKILL.md` names, which it can read, mean quite a lot

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

They are the numbered list in [SKILL.md](SKILL.md#task), which is the one copy — the table that used to sit here had already fallen a rule behind once, and a second list is how that happens

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
tests/fixtures/        the known-bad inputs each check is proven to catch
check-skill.sh         the gate every skill repository shares, vendored from the ci skill
check-pins.sh          the pin guard for the workflows, vendored from the ci skill
vendor-sync.sh         keeps the vendored copies byte-equal to their source
```
