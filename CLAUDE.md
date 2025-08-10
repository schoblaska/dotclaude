# DOTCLAUDE
This repository contains my personal dotclaude configuration files that get symlinked to ~/.claude/ for use across all projects.

## Project Structure
* `setup.sh` - Installation script that creates symlinks to ~/.claude/
* `global/` - Contains system-level CLAUDE.md and settings.json files
* `agents/` - Custom agent prompts for specialized tasks
* `hooks/` - Shell commands that execute in response to Claude Code events
* `languages/` - Language and framework-specific coding guidelines
* `prompts/` - Additional prompt templates
* `templates/` - Document templates for various purposes

## Claude Code Best Practices
Reference the [official Claude Code best practices guide](https://www.anthropic.com/engineering/claude-code-best-practices) when developing prompts and configurations. Key principles include:

* Give Claude clear targets like visual mocks, test cases, or expected outputs
* Have Claude read relevant files before making changes
* Let Claude outline its approach before implementation
* Provide feedback quickly to keep Claude on track
* Document bash commands, code style, testing instructions, and repo conventions in CLAUDE.md files
* Consider test-driven development and iterative exploration patterns

## Development Guidelines
When modifying prompts and configurations in this repository:

* Proactively tighten wording and remove redundant instructions to maximize available context
* Remove instructions that don't add value or merely state the obvious
* Every word should serve a purpose; if it doesn't change behavior, cut it
* Follow the prompt format guidelines defined in the global CLAUDE.md
* Ensure examples are minimal and generic
* Avoid unnecessary complexity in agent prompts

## Setup Commands
* Run `./setup.sh` to symlink config files to ~/.claude/
* Verify symlinks: `ls -la ~/.claude/`

## Testing
No automated tests - manually verify:
* Symlinks created correctly after setup
* Claude Code recognizes custom agents and prompts
* Language guidelines apply in appropriate projects