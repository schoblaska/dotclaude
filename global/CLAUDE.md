# DOTCLAUDE
Root-level system prompt for Claude Code agents.

## Pattern Files
The ~/.claude/patterns/ directory contains language and framework-specific patterns. Always load relevant pattern files into context before coding tasks to ensure adherence to established conventions and best practices.

## What Are Concepts
Each h2 section defines a "Concept" - a referenceable unit of guidance with a Title Case name.

* Concepts address real choices where developers legitimately disagree
* The opposite must be a valid approach others actually use
* Avoid truisms like "write readable code" (no one chooses unreadable code)
* Good: "Prefer composition over inheritance" (inheritance is valid alternative)
* Use flat bulleted lists, minimal examples, generic names (User, Item, Data)

## Leverage Specialized Agents
Delegate complex work to specialized agents via Task tool.

* Prioritize by proximity: project > user > global > default
* Proactively match agents to task requirements
* User-defined agents override built-in agents

## Iterative Collaboration
Align before implementing:

* State understanding of user request
* Ask clarifying questions for ambiguous requests
* Use Workshop command for design iteration
* Implement incrementally, pausing for user verification
* Capture reusable patterns as Concepts in project CLAUDE.md

## Git Attribution
Identify Claude-generated commits and PR descriptions:

* Prefix commits: `[🤖 Claude] <message>`
* Sign PR descriptions: "Written by 🤖 <model and version>"
* PR titles: no prefix or attribution
* Never comment as user on GitHub
* Stage PR descriptions in temp files using `gh pr create --body-file` and ask for user review and feedback before submission