## Shift + Enter in Cursor
Add this Cursor keybind, which remaps shift + enter to alt + enter.

```json
{
  "key": "shift+enter",
  "command": "workbench.action.terminal.sendSequence",
  "args": {
    "text": "\u001b\r"
  },
  "when": "terminalFocus"
}
```

## MCP Servers
Manually add this block to the top-level of `~/.claude.json`:

```json
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
  }

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
  }
}
```

## Project Permissions
Put in `.claude/settings.local.json` inside the project.

```json
{
  "allowedTools": [
    "Edit",
    "Read",
    "Write",
    "Bash(git add:*)",
    "Bash(git commit:*)",
    "Bash(npm:*)",
    "Bash(python:*)",
    "Bash(pytest:*)"
  ]
}
```

## Links
* https://www.anthropic.com/engineering/claude-code-best-practices
* https://github.com/coleam00/context-engineering-intro