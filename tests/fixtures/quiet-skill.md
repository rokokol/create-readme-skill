---
name: a-skill
description: "A frontmatter is data, not prose. Its keys are not paragraphs, two of them in a row are not a hard wrap, and a sentence in a field ends the way a sentence does."
---

# A document shaped like a SKILL.md, breaking none of the rules

The rules are the readme's, and they hold over every document a repository ships, so the checker is given more than readmes. Everything below is a shape that appears in one and must not be reported

## Before contributing to someone else's project

A heading that contains the word is a section about the topic. A heading that is the word is a second copy of a file that already exists, and only that one is reported

## What goes to git and the changelog

The same again, with the other word

A rule may have to show the character it forbids, so a code span holding `«one»`, `“another”` or `‘a third’` is naming the character rather than quoting with it

A code span may carry a full stop of its own, `printf 'done.\n'`, and that is no finding while the paragraph does not end on it
