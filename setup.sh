#!/bin/bash

# Simple dotclaude setup script
# Creates symlinks from this repo to your local .claude directory

set -e # Exit on any error

# Get the directory where this script is located
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default .claude directory location
CLAUDE_DIR="$HOME/.claude"

# Create .claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR"

echo "Setting up symlinks from $REPO_DIR to $CLAUDE_DIR"

# Function to create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "Backing up existing $target to $target.backup"
    mv "$target" "$target.backup"
  elif [ -L "$target" ]; then
    echo "Removing existing symlink $target"
    rm "$target"
  fi

  echo "Creating symlink: $target -> $source"
  ln -sf "$source" "$target"
}

DIRS_TO_LINK=(
  "agents"
  "commands"
  "hooks"
  "prompts"
  "templates"
)

FILES_TO_LINK=(
  "global/CLAUDE.md:CLAUDE.md"  # source:target format
  "global/settings.json:settings.json"
)

# Create symlinks for each specified directory
for dir in "${DIRS_TO_LINK[@]}"; do
  source="$REPO_DIR/$dir"
  target="$CLAUDE_DIR/$dir"

  if [ -d "$source" ]; then
    create_symlink "$source" "$target"
  else
    echo "Warning: $source directory not found, skipping"
  fi
done

# Create symlinks for each specified file
for file_spec in "${FILES_TO_LINK[@]}"; do
  # Check if the spec contains a colon for custom source:target mapping
  if [[ "$file_spec" == *":"* ]]; then
    source="$REPO_DIR/${file_spec%%:*}"
    target="$CLAUDE_DIR/${file_spec##*:}"
  else
    source="$REPO_DIR/$file_spec"
    target="$CLAUDE_DIR/$file_spec"
  fi

  if [ -f "$source" ]; then
    create_symlink "$source" "$target"
  else
    echo "Warning: $source file not found, skipping"
  fi
done

echo "Setup complete! Your dotclaude repo is now linked to $CLAUDE_DIR"
echo "Run 'ls -la $CLAUDE_DIR' to verify the symlinks"
