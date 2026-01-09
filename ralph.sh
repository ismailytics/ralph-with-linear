#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop with Linear MCP integration
# Usage: ./ralph.sh [max_iterations]
#
# Prerequisites:
# - Linear MCP must be configured (https://linear.app/docs/mcp)
# - Claude Code CLI must be installed
#
# On first run, Ralph will prompt you to select or create a Linear project.
#
# Security: When not running in a container, Ralph will use Docker sandbox
# if available for isolation during AFK mode.

set -e

# Function to run Claude with optional Docker sandbox
run_claude() {
  local prompt_file="$1"

  # Check if already running in a container
  if [ -f /.dockerenv ]; then
    # Already in container - run directly
    cat "$prompt_file" | claude --dangerously-skip-permissions -p
  else
    # Not in container - use Docker sandbox if available
    if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
      cat "$prompt_file" | docker sandbox run claude --dangerously-skip-permissions -p
    else
      # Docker not available - run directly (with warning on first run)
      if [ -z "$DOCKER_WARNING_SHOWN" ]; then
        echo "Note: Running without Docker sandbox. Consider using Docker for AFK safety."
        export DOCKER_WARNING_SHOWN=1
      fi
      cat "$prompt_file" | claude --dangerously-skip-permissions -p
    fi
  fi
}

MAX_ITERATIONS=${1:-10}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$SCRIPT_DIR/.ralph-project"

# Check if .ralph-project exists, if not run setup
if [ ! -f "$PROJECT_FILE" ]; then
  echo "═══════════════════════════════════════════════════════"
  echo "  Ralph Setup - Linear Project Configuration"
  echo "═══════════════════════════════════════════════════════"
  echo ""
  echo "No Linear project configured. Starting interactive setup..."
  echo ""

  # Run Claude Code with setup prompt to create .ralph-project
  # Setup runs interactively (no -p flag) so user can answer questions
  claude --dangerously-skip-permissions "$SCRIPT_DIR/setup-prompt.md"

  # Verify .ralph-project was created
  if [ ! -f "$PROJECT_FILE" ]; then
    echo ""
    echo "Setup was not completed. Please run ./ralph.sh again."
    exit 1
  fi

  echo ""
  echo "Setup complete! Starting Ralph loop..."
  echo ""
fi

# Read project configuration
PROJECT_ID=$(jq -r '.linearProjectId // empty' "$PROJECT_FILE" 2>/dev/null || echo "")
BRANCH_NAME=$(jq -r '.branchName // empty' "$PROJECT_FILE" 2>/dev/null || echo "")

if [ -z "$PROJECT_ID" ]; then
  echo "Error: linearProjectId not found in .ralph-project"
  echo "Delete .ralph-project and run ./ralph.sh again to reconfigure."
  exit 1
fi

echo "Starting Ralph - Max iterations: $MAX_ITERATIONS"
echo "Linear Project: $PROJECT_ID"
[ -n "$BRANCH_NAME" ] && echo "Branch: $BRANCH_NAME"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  Ralph Iteration $i of $MAX_ITERATIONS"
  echo "═══════════════════════════════════════════════════════"

  # Run Claude Code with the ralph prompt
  OUTPUT=$(run_claude "$SCRIPT_DIR/prompt.md" 2>&1 | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    exit 0
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check your Linear project for status."
exit 1
