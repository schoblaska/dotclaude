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

## Development Guidelines
When modifying prompts and configurations in this repository:

* Follow the prompt format guidelines defined in the global CLAUDE.md
* Ensure examples are minimal and generic
* Avoid unnecessary complexity in agent prompts