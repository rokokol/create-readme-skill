---
name: create-readme
description: "What it is — the house rules for a README: structure and tone, one paragraph per line with no hard wrapping, no trailing full stop, no section that has its own file, no version a repository does not have, plus a checker that decides the machine-checkable half. Use when writing a README from scratch AND whenever one is edited, reviewed, restructured, or translated — the rules bite hardest on an edit, because a one-word change to a hard-wrapped paragraph reflows every line after it. Also use before adding a badge, a version claim or an admonition to one. Triggers: README, readme.md, badge, admonition, callout, project description, ридми, написать readme, поправь readme, обнови описание проекта, бейджи."
license: MIT
---

## Role

You're a senior expert software engineer with extensive experience in open source projects. You always make sure the README files you write are appealing, informative, and easy to read

## Task

1. Take a deep breath, and review the entire project and workspace, then create a comprehensive and well-structured README.md file for the project. Editing an existing one is the same job with one extra obligation: the rules below apply to the whole file, not only to the lines you touched, so a readme that already breaks rule 6 or 7 gets fixed in the same commit rather than gaining one more paragraph in the old shape. Run `tests/check-readme.sh` on it — it takes any readme, and it decides the machine-checkable half faster than a reading does
2. Take inspiration from these readme files for the structure, tone and content:
   - https://raw.githubusercontent.com/rokokol/hyprland-screen-shader/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/claude-account/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/huix/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/ddlc-sddm-theme/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/obsidian-obsictionary/refs/heads/main/README.md
   - https://raw.githubusercontent.com/rokokol/super-productivity-skill/refs/heads/main/README.md
3. Do not overuse emojis, and keep the readme concise and to the point
4. Do not include sections like "LICENSE", "CONTRIBUTING", "CHANGELOG", etc. There are dedicated files for those sections. Whatever the project's own licence does not cover — third-party artwork, fonts, transcribed text, colours measured off someone else's site — belongs in `ASSETS.md`, linked from an `assets` badge in the header; the disclaimer lives there and nowhere else, not also as a callout in the readme
5. Use GFM (GitHub Flavored Markdown) for formatting, and GitHub admonition syntax (https://github.com/orgs/community/discussions/16925) where appropriate
6. One paragraph is one line. Never hard-wrap: GitHub soft-wraps for you, so a manual break inside a paragraph only means a one-word edit reflows every line after it. This holds for plain text, list items, table cells and callouts alike — a `> [!NOTE]` is one `>` line of body, not six. Keep the admonition keyword alone on its first line (`> [!NOTE]`, then the text below it), or GitHub renders a plain quote instead of the box. The one exception is a fenced block where the alignment is the content, like an ASCII tree
7. Do not end a paragraph with a full stop. Sentences inside one are punctuated normally, but the last sentence of a paragraph, a list item or a table cell ends bare — that is how every readme linked above reads. Quote with `"…"` rather than `«…»`, in Russian text too
8. If you find a logo or icon for the project, use it in the readme's header
9. Never claim a version the project does not have. A repository that is only read at whatever revision is checked out — a skill, a prompt library, a docs-only repo — gets no version badge, no "requires vX" line and no install command pinned to a tag; its install instructions clone or pull the default branch. Where the project is a versioned artifact someone installs, state the version requirements it actually has and nothing beyond them
