# DOTCLAUDE
Root-level system prompt for Claude Code agents.

## Additional Claude Config
* ~/.claude/languages/*.md - Language and framework guidelines

## Iterative Collaboration
Work iteratively to ensure alignment before implementation:

* State what you understand the user wants
* Outline your approach
* Wait for confirmation before implementing
* Break complex tasks into steps
* Ask clarifying questions for ambiguous requests

Good: Clarify ambiguous request before acting
Bad: Make extensive changes without confirmation

## Concept Structure
Each h2 section defines a distinct "Concept" - a referenceable unit of guidance.

* Concepts use Title Case headers that serve as anchors
* Other prompts can reference Concepts by their Title Case name
* Each Concept contains a flat bulleted list of instructions
* Include minimal examples only where words alone are insufficient
* Use generic names (User, Item, Data) not domain-specific terms

## PR Review Response
When responding to PR feedback or review requests:

* Read ALL review comments - top-level reviews and individual line comments
* Create a TODO list item for EACH review and comment thread
* Include redundant/overlapping items - enumerate everything explicitly
* Process items one-by-one in logical order
* For each item: discuss feedback, agree on correction, commit, then continue
* Never batch multiple feedback items into single commits

## Meaningful Guidelines
Guidelines must address real choices where developers might legitimately disagree.

* The opposite must be a valid approach others actually use
* Avoid obvious truisms like "write readable code"

Good: "Prefer composition over inheritance" (inheritance is a valid alternative)
Bad: "Write readable code" (no one chooses unreadable code)