# Ralph Agent Instructions

## Overview

Ralph is an autonomous AI agent loop that runs Amp repeatedly until all PRD items are complete. Each iteration is a fresh Amp instance with clean context. Task management is handled via Linear MCP.

## Prerequisites

- [Linear MCP](https://linear.app/docs/mcp) must be configured
- Amp CLI installed and authenticated

## Commands

```bash
# Run Ralph (interactive project selection on first run)
./ralph.sh [max_iterations]

# Run the flowchart dev server
cd flowchart && npm run dev

# Build the flowchart
cd flowchart && npm run build
```

## Key Files

- `ralph.sh` - The bash loop that spawns fresh Amp instances
- `prompt.md` - Instructions given to each Amp instance
- `setup-prompt.md` - Interactive Linear project selection
- `.ralph-project` - Local config with Linear project ID (gitignored)
- `flowchart/` - Interactive React Flow diagram explaining how Ralph works

## Linear MCP Integration

Ralph uses Linear for all task management:

### Reading Project and Issues
```
mcp__linear-server__get_project - Get project details (PRD in description)
mcp__linear-server__list_issues - Get user stories (filter by project and status)
```

### Updating Issue Status
```
mcp__linear-server__update_issue - Mark issues as "In Progress" or "Done"
```

### Adding Learnings
```
mcp__linear-server__create_comment - Add implementation details and learnings
mcp__linear-server__list_comments - Read learnings from completed issues
```

### Priority Mapping
| Position | Linear Priority |
|----------|-----------------|
| 1st      | 1 (Urgent)      |
| 2nd      | 2 (High)        |
| 3rd      | 3 (Normal)      |
| 4th+     | 4 (Low)         |

## Flowchart

The `flowchart/` directory contains an interactive visualization built with React Flow. It's designed for presentations - click through to reveal each step with animations.

To run locally:
```bash
cd flowchart
npm install
npm run dev
```

## Patterns

- Each iteration spawns a fresh Amp instance with clean context
- Memory persists via git history, Linear issues/comments, and AGENTS.md files
- Stories should be small enough to complete in one context window
- Always update AGENTS.md with discovered patterns for future iterations
- Branch name is stored in first line of Linear project description: `Branch: ralph/<feature>`
- Issue status flow: Todo → In Progress → Done
- Learnings are added as comments to completed issues
