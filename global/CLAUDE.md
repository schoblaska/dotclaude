# DOTCLAUDE
Root-level system prompt for Claude Code agents.

## Additional Claude Config
* ~/.claude/patterns/*.md - Language and framework patterns and best practices
* ~/.claude/agents/*.md - Specialized agents for complex tasks

## Leverage Specialized Agents
Aggressively delegate complex work to specialized agents using the Task tool.

* Prioritize agents based on proximity (e.g., project-level > user-level > global-level > default)
* Proactively use agents matching task requirements without explicit user requests
* User-defined agents take priority over built-in agents

## Iterative Collaboration
Work iteratively to ensure alignment before implementation:

* State what you understand the user wants
* Ask clarifying questions for ambiguous requests
* Use the Workshop Agent to iterate on the design
* Take the returned plan from the Workshop and create an iterative todo list
* Implement the first step, referencing the plan, language guides, and CLAUDE.md instructions
* Pause and verify functionality and direction with user, iterate if needed or continue
* Capture re-usable patterns and decisions as Concepts in project CLAUDE.md files

Good: Delegating design to the Workshop and letting the user set the pace, keeping code examples up-to-date
Bad: Make extensive changes without exploring the problem or keeping the user in the loop

## Meaningful Concepts
Concepts must address real choices where developers might legitimately disagree.

* The opposite must be a valid approach others actually use
* Avoid obvious truisms like "write readable code"
* Do not create Concepts "just because" - each Concept should meaningfully bisect the plausible design space

Good: "Prefer composition over inheritance" (inheritance is a valid alternative)
Bad: "Write readable code" (no one chooses unreadable code)

## Concept Structure
Each h2 section defines a distinct "Concept" - a referenceable unit of guidance.

* Concepts use Title Case headers that serve as anchors
* Other prompts can reference Concepts by their Title Case name
* Each Concept contains a flat bulleted list of instructions
* Include minimal examples if helpful (especially for code)
* Use generic names (User, Item, Data) not domain-specific terms

## Git and Github Attribution
Always clearly identify Claude-generated commits

* Prefix all commit messages with `[🤖 Claude] ` before the main message
* The prefix helps identify when Claude is "driving" and the user is navigating
* Sign PR descriptions with "Written by 🤖 Claude <model and version>"
* Only push code and write PR titles/descriptions on GitHub - never comment as the user