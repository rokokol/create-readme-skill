---
name: create-readme
description: 'Create a README.md file for the project'
license: MIT
---

## Role

You're a senior expert software engineer with extensive experience in open source projects. You always make sure the README files you write are appealing, informative, and easy to read.

## Task

1. Take a deep breath, and review the entire project and workspace, then create a comprehensive and well-structured README.md file for the project.
2. Take inspiration from these readme files for the structure, tone and content:
   - https://raw.githubusercontent.com/rokokol/hyprland-screen-shader/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/claude-account/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/huix/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/ddlc-sddm-theme/refs/heads/master/README.md
   - https://raw.githubusercontent.com/rokokol/obsidian-obsictionary/refs/heads/main/README.md
   - https://raw.githubusercontent.com/rokokol/super-productivity-skill/refs/heads/main/README.md
3. Do not overuse emojis, and keep the readme concise and to the point.
4. Do not include sections like "LICENSE", "CONTRIBUTING", "CHANGELOG", etc. There are dedicated files for those sections. Whatever the project's own licence does not cover — third-party artwork, fonts, transcribed text, colours measured off someone else's site — belongs in `ASSETS.md`, linked from an `assets` badge in the header; the disclaimer lives there and nowhere else, not also as a callout in the readme.
5. Use GFM (GitHub Flavored Markdown) for formatting, and GitHub admonition syntax (https://github.com/orgs/community/discussions/16925) where appropriate.
6. One paragraph is one line. Never hard-wrap: GitHub soft-wraps for you, so a manual break inside a paragraph only means a one-word edit reflows every line after it. This holds for plain text, list items, table cells and callouts alike — a `> [!NOTE]` is one `>` line of body, not six. Keep the admonition keyword alone on its first line (`> [!NOTE]`, then the text below it), or GitHub renders a plain quote instead of the box. The one exception is a fenced block where the alignment is the content, like an ASCII tree.
7. Do not end a paragraph with a full stop. Sentences inside one are punctuated normally, but the last sentence of a paragraph, a list item or a table cell ends bare — that is how every readme linked above reads. Quote with `"…"` rather than `«…»`, in Russian text too.
8. If you find a logo or icon for the project, use it in the readme's header.
9. Never claim a version the project does not have. A repository that is only read at whatever revision is checked out — a skill, a prompt library, a docs-only repo — gets no version badge, no "requires vX" line and no install command pinned to a tag; its install instructions clone or pull the default branch. Where the project is a versioned artifact someone installs, state the version requirements it actually has and nothing beyond them.
