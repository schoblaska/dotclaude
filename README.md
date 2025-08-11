# 🤖 DOTCLAUDE
Personal Claude Code configuration files for enhanced AI-assisted development. This repository contains custom agents, language guidelines, templates, and settings that get symlinked to `~/.claude/` for use across all projects.

## Quick Setup
```bash
./setup.sh  # Symlinks all config files to ~/.claude/. Run at your own risk.
```

## Cursor Keybinds
```json
{
  "key": "shift+enter",
  "command": "workbench.action.terminal.sendSequence",
  "args": {
    "text": "\u001b\r"
  },
  "when": "terminalFocus"
},
{
  "key": "shift+enter",
  "command": "workbench.action.terminal.sendSequence",
  "args": {
    "text": "\u001b\r"
  },
  "when": "terminalFocus"
},
{
  "key": "cmd+i",
  "command": "-composer.startComposerPrompt"
},
{
  "key": "cmd+i",
  "command": "claude-code.insertAtMentioned",
  "when": "editorTextFocus"
},
{
  "key": "alt+cmd+k",
  "command": "-claude-code.insertAtMentioned",
  "when": "editorTextFocus"
}
```

## MCP Servers
Manually add this block to the top-level of `~/.claude.json`:

```json
{
  "mcpServers": {
    "linear": {
      "type": "sse",
      "url": "https://mcp.linear.app/sse"
    },

    "brave-search": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-brave-search"
      ],
      "env": {
        "BRAVE_API_KEY": "YOUR_API_KEY_HERE"
      }
    },

    "github": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "YOUR_GITHUB_PAT_HERE"
      }
    },

    "serena": {
      "command": "uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server",
        "--context",
        "ide-assistant"
      ]
    }
  }
}
```

## Project Permissions
Put in `.claude/settings.local.json` inside the project.

```json
{
  "permissions": {
    "allow": [
      "Edit",
      "Read",
      "Write",
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(npm:*)",
      "Bash(python:*)",
      "Bash(pytest:*)",
      "Bash(ruby:*)",
      "Bash(bin/rails:*)",
      "Bash(bin/rake:*)",
      "Bash(bundle exec:*)"
    ],
    "deny": []
  }
}
```

## Links
* https://www.anthropic.com/engineering/claude-code-best-practices
* https://github.com/coleam00/context-engineering-intro
