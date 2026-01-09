# Ralph Agent Instructions

## Overview

Ralph is an autonomous AI agent loop that runs Claude Code repeatedly until all PRD items are complete. Each iteration is a fresh Claude Code instance with clean context. Task management is handled via Linear MCP.

## Prerequisites

- [Linear MCP](https://linear.app/docs/mcp) must be configured
- Claude Code CLI installed and authenticated

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

- `ralph.sh` - The bash loop that spawns fresh Claude Code instances
- `prompt.md` - Instructions given to each Claude Code instance
- `setup-prompt.md` - Interactive Linear project selection
- `.ralph-project` - Local config with Linear project ID (gitignored)
- `flowchart/` - Interactive React Flow diagram explaining how Ralph works
- `.claude/skills/prd/SKILL.md` - PRD generation skill
- `.claude/skills/ralph/SKILL.md` - PRD-to-Linear converter skill

## Creating a PRD

**When to use:** When a user wants to plan a new feature, start a project, or asks for a PRD/spec/requirements.

**Trigger phrases:** "create a prd", "write prd for", "plan this feature", "requirements for", "spec out"

**How to create a PRD:**

1. **Use the `/prd` skill** - This is the standard flow for creating PRDs
2. The skill will guide you through:
   - Asking 3-5 clarifying questions (with A/B/C/D options)
   - Selecting a Linear team
   - Creating a Linear project with PRD in description
   - Creating Linear issues for each user story
   - Saving `.ralph-project` configuration

**Key rules:**
- Project description MUST start with `Branch: ralph/<feature-name>`
- Issues are ordered by dependencies (DB → Backend → UI → Dashboards)
- Priority maps to story order (1st=Urgent, 2nd=High, 3rd=Normal, 4th+=Low)
- All stories must include "Typecheck passes" as acceptance criterion
- UI stories must include "Verify in browser" criterion
- Stories must be small enough for one context window

See `skills/prd/SKILL.md` for full details.

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

- Each iteration spawns a fresh Claude Code instance with clean context
- Memory persists via git history, Linear issues/comments, and CLAUDE.md files
- Stories should be small enough to complete in one context window
- Always update CLAUDE.md with discovered patterns for future iterations
- Branch name is stored in first line of Linear project description: `Branch: ralph/<feature>`
- Issue status flow: Todo → In Progress → Done
- Learnings are added as comments to completed issues

## Testing Patterns

### Browser Testing Tool Selection

Ralph auto-detects available browser testing tools:

1. **Check for Playwright MCP**: Look for `mcp__playwright__*` tools
2. **If available**: Use Playwright for automated E2E assertions
3. **If not available**: Fall back to `dev-browser` skill for manual verification

Always document which tool was used in the Linear issue comment.

### TDD Workflow

When acceptance criteria include "Tests written first (TDD)":

```
RED:      Write failing test → Commit "test: [Issue-ID] - Add failing test for [feature]"
GREEN:    Implement minimum code → Do not commit yet
REFACTOR: Clean up code → Commit "feat: [Issue-ID] - [Feature Title]"
```

### Test File Patterns

- Unit tests: `*.test.ts` or `*.spec.ts` next to source file
- E2E tests: `e2e/*.spec.ts` or `tests/*.spec.ts`
- Follow existing test patterns in the project
