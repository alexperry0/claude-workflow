#!/usr/bin/env bash
set -euo pipefail

# claude-workflow installer
# Installs the .claude/ framework and CLAUDE.md.template into a target project.
#
# Usage:
#   ./install.sh [TARGET_DIR]
#
# If TARGET_DIR is omitted, installs into the current directory.
# Can also be run via curl:
#   curl -fsSL https://raw.githubusercontent.com/alexperry0/claude-workflow/main/install.sh | bash -s -- [TARGET_DIR]

REPO_URL="https://github.com/alexperry0/claude-workflow.git"

TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Determine script location or use temp clone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ -d "$SCRIPT_DIR/.claude" ] && [ -f "$SCRIPT_DIR/CLAUDE.md.template" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
    CLEANUP=false
else
    TMPDIR="$(mktemp -d)"
    echo "Cloning claude-workflow..."
    git clone --depth 1 --quiet "$REPO_URL" "$TMPDIR/claude-workflow"
    SOURCE_DIR="$TMPDIR/claude-workflow"
    CLEANUP=true
fi

echo "Installing claude-workflow into: $TARGET_DIR"

# Copy .claude/ directory, excluding pycache and plans
if command -v rsync &>/dev/null; then
    rsync -a --exclude='__pycache__' --exclude='plans/' "$SOURCE_DIR/.claude/" "$TARGET_DIR/.claude/"
else
    cp -r "$SOURCE_DIR/.claude" "$TARGET_DIR/.claude"
    find "$TARGET_DIR/.claude" -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
    rm -rf "$TARGET_DIR/.claude/plans" 2>/dev/null || true
fi

# Copy CLAUDE.md.template
cp "$SOURCE_DIR/CLAUDE.md.template" "$TARGET_DIR/CLAUDE.md.template"

# If no CLAUDE.md exists, copy the template as a starting point
if [ ! -f "$TARGET_DIR/CLAUDE.md" ]; then
    cp "$SOURCE_DIR/CLAUDE.md.template" "$TARGET_DIR/CLAUDE.md"
    echo "Created CLAUDE.md from template (fill in your project details)."
fi

# Cleanup temp clone if needed
if [ "$CLEANUP" = true ]; then
    rm -rf "$TMPDIR"
fi

echo ""
echo "Done! Installed:"
echo "  .claude/            — agents, commands, hooks, guides, personas, templates"
echo "  CLAUDE.md.template  — reference template"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project's repo info, build commands, and architecture"
echo "  2. Verify Python 3.10+ is available (hooks need it)"
echo "  3. Review .claude/settings.local.json and adjust permissions"
