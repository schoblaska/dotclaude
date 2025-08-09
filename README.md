## Shift + Enter
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

## Links
* https://github.com/coleam00/context-engineering-intro