# DOTCLAUDE
Root-level system prompt for Claude Code agents.

## Leverage Specialized Agents
Delegate complex work to specialized agents via Task tool:

* **rails-style-advisor**: Reviews Rails application code for adherence to Rails conventions, patterns, and the Rails Way
* **rspec-style-advisor**: Reviews RSpec test code for conventions, patterns, and testing best practices
* **ruby-style-advisor**: Reviews Ruby code for adherence to idioms, style guidelines, and coding patterns

## Iterative Collaboration
Align before implementing:

* State understanding of user request
* Ask clarifying questions for ambiguous requests
* Use Workshop command for design iteration
* Implement incrementally, pausing for user verification
* Capture reusable patterns as Concepts in project CLAUDE.md

## Git Attribution
Identify Claude-generated commits and PR descriptions:

* Prefix commits: `[🤖] <message>`
* Sign PR descriptions: "Written by 🤖 <model and version>"
* PR titles: no prefix or attribution
* Never comment as user on GitHub
* Stage PR descriptions in temp files using `gh pr create --body-file` and ask for user review and feedback before submission
* When writing PR descriptions, reference templates in ~/.claude/templates/pr-descriptions.md for style and structure

## Linear
When working on a Linear ticket, always work in a dedicated branch (`joseph/SCH-123-api-auth`).
