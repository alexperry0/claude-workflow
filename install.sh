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
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory '$TARGET_DIR' does not exist."
    echo "Create it first, or omit the argument to install in the current directory."
    exit 1
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Determine script location or use temp clone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ -d "$SCRIPT_DIR/.claude" ] && [ -f "$SCRIPT_DIR/CLAUDE.md.template" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
    CLEANUP=false
else
    CLONE_DIR="$(mktemp -d)"
    echo "Cloning claude-workflow..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR/claude-workflow"
    SOURCE_DIR="$CLONE_DIR/claude-workflow"
    CLEANUP=true
fi

# Warn if .claude/ already exists
if [ -d "$TARGET_DIR/.claude" ]; then
    echo "WARNING: $TARGET_DIR/.claude/ already exists."
    echo "  Re-running will overwrite customized commands, hooks, agents, etc."
    # Detect piped execution (stdin is not a terminal)
    if [ -t 0 ]; then
        read -p "  Continue? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            [ "$CLEANUP" = true ] && rm -rf "$CLONE_DIR"
            exit 1
        fi
    else
        echo "  (Piped mode detected — use ./install.sh locally for interactive prompt)"
        echo "  Proceeding with overwrite..."
    fi
fi

echo "Installing claude-workflow into: $TARGET_DIR"

# Copy .claude/ directory, excluding pycache, plans, and settings.local.json
if command -v rsync &>/dev/null; then
    rsync -a --exclude='__pycache__' --exclude='plans/' --exclude='settings.local.json' \
        "$SOURCE_DIR/.claude/" "$TARGET_DIR/.claude/"
else
    # Preserve existing settings.local.json before overwriting
    EXISTING_SETTINGS=""
    if [ -f "$TARGET_DIR/.claude/settings.local.json" ]; then
        EXISTING_SETTINGS="$(mktemp)"
        cp "$TARGET_DIR/.claude/settings.local.json" "$EXISTING_SETTINGS"
    fi
    cp -r "$SOURCE_DIR/.claude" "$TARGET_DIR/.claude"
    find "$TARGET_DIR/.claude" -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
    rm -rf "$TARGET_DIR/.claude/plans" 2>/dev/null || true
    # Restore existing settings or remove the source's copy
    if [ -n "$EXISTING_SETTINGS" ]; then
        cp "$EXISTING_SETTINGS" "$TARGET_DIR/.claude/settings.local.json"
        rm -f "$EXISTING_SETTINGS"
    else
        rm -f "$TARGET_DIR/.claude/settings.local.json" 2>/dev/null || true
    fi
fi

# Install settings.local.json only if one doesn't already exist
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ]; then
    cp "$SOURCE_DIR/.claude/settings.local.json.template" "$TARGET_DIR/.claude/settings.local.json"
    echo "Created .claude/settings.local.json from template (review and adjust permissions)."
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
    rm -rf "$CLONE_DIR"
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
