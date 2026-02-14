#!/usr/bin/env bash
set -euo pipefail

# claude-workflow installer
# Installs the .claude/ framework and CLAUDE.md.template into a target project.
#
# Usage:
#   ./install.sh [--force] [TARGET_DIR]
#
# Options:
#   --force    Overwrite existing .claude/ directory without prompting
#
# If TARGET_DIR is omitted, installs into the current directory.
# Can also be run via curl:
#   curl -fsSL https://raw.githubusercontent.com/alexperry0/claude-workflow/main/install.sh | bash -s -- [--force] [TARGET_DIR]

REPO_URL="https://github.com/alexperry0/claude-workflow.git"

# Parse arguments
FORCE=false
TARGET_DIR="."
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        *) TARGET_DIR="$arg" ;;
    esac
done

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

cleanup() {
    [ "$CLEANUP" = true ] && rm -rf "$CLONE_DIR"
}

# Warn if .claude/ already exists
if [ -d "$TARGET_DIR/.claude" ]; then
    if [ "$FORCE" = true ]; then
        echo "WARNING: Overwriting $TARGET_DIR/.claude/ (--force specified)"
    elif [ -t 0 ]; then
        echo "WARNING: $TARGET_DIR/.claude/ already exists."
        echo "  Re-running will overwrite customized commands, hooks, agents, etc."
        read -p "  Continue? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            cleanup
            exit 1
        fi
    else
        echo "ERROR: $TARGET_DIR/.claude/ already exists."
        echo "  Cannot prompt for confirmation in piped mode."
        echo "  Pass --force to overwrite: bash -s -- --force [TARGET_DIR]"
        cleanup
        exit 1
    fi
fi

echo "Installing claude-workflow into: $TARGET_DIR"

# Directories to copy from .claude/ (explicit list avoids copying settings.local.json)
SUBDIRS="agents commands guides hooks personas templates"

mkdir -p "$TARGET_DIR/.claude"
for dir in $SUBDIRS; do
    if [ -d "$SOURCE_DIR/.claude/$dir" ]; then
        if command -v rsync &>/dev/null; then
            rsync -a --exclude='__pycache__' "$SOURCE_DIR/.claude/$dir/" "$TARGET_DIR/.claude/$dir/"
        else
            cp -r "$SOURCE_DIR/.claude/$dir" "$TARGET_DIR/.claude/$dir"
            find "$TARGET_DIR/.claude/$dir" -type d -name '__pycache__' -prune -exec rm -rf {} + 2>/dev/null || true
        fi
    fi
done

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
cleanup

echo ""
echo "Done! Installed:"
echo "  .claude/            — agents, commands, hooks, guides, personas, templates"
echo "  CLAUDE.md.template  — reference template"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project's repo info, build commands, and architecture"
echo "  2. Verify Python 3.10+ is available (hooks need it)"
echo "  3. Review .claude/settings.local.json and adjust permissions"
