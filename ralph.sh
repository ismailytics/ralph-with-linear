#!/bin/bash
# Ralph Wiggum - Long-running AI agent loop with Linear MCP integration
# Usage: ./ralph.sh [max_iterations]
#
# Prerequisites:
# - Linear MCP must be configured (https://linear.app/docs/mcp)
# - amp CLI must be installed
#
# On first run, Ralph will prompt you to select or create a Linear project.

set -e

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

  # Run amp with setup prompt to create .ralph-project
  cat "$SCRIPT_DIR/setup-prompt.md" | amp --dangerously-allow-all

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

  # Run amp with the ralph prompt
  OUTPUT=$(cat "$SCRIPT_DIR/prompt.md" | amp --dangerously-allow-all 2>&1 | tee /dev/stderr) || true

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
