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
  "linear-server": {
    "type": "sse",
    "url": "https://mcp.linear.app/sse"
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
* https://github.com/coleam00/context-engineering-intro