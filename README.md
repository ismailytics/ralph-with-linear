# Ralph Advanced with Linear and Playwright

![Ralph](ralph.webp)

Ralph is an autonomous AI agent loop that runs [Amp](https://ampcode.com) repeatedly until all PRD items are complete. Each iteration is a fresh Amp instance with clean context. Memory persists via git history and Linear (projects, issues, and comments).

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

> **Fork Notice:** This project is a fork of [snarktank/ralph](https://github.com/snarktank/ralph) with the following modifications:
> - **Linear MCP Integration**: Replaced file-based task management (`prd.json`, `progress.txt`) with [Linear MCP](https://linear.app/docs/mcp) for cloud-based project management
> - **Playwright MCP Support**: Added Playwright MCP as primary browser testing tool with dev-browser as fallback
> - **Optional TDD Workflow**: Added optional Test-Driven Development support with Red-Green-Refactor cycle
> - **Interactive Setup**: Added `setup-prompt.md` for interactive Linear project selection

## Prerequisites

- [Amp CLI](https://ampcode.com) installed and authenticated
- [Linear MCP](https://linear.app/docs/mcp) configured in your MCP settings
- `jq` installed (`brew install jq` on macOS)
- A git repository for your project

## Setup

### 1. Configure Linear MCP

Follow the [Linear MCP documentation](https://linear.app/docs/mcp) to set up the Linear MCP server. This enables Ralph to read and write Linear projects and issues.

### 2. Copy Ralph to your project

```bash
# From your project root
mkdir -p scripts/ralph
cp /path/to/ralph/ralph.sh scripts/ralph/
cp /path/to/ralph/prompt.md scripts/ralph/
cp /path/to/ralph/setup-prompt.md scripts/ralph/
chmod +x scripts/ralph/ralph.sh
```

### 3. Install skills globally (optional)

Copy the skills to your Amp config for use across all projects:

```bash
cp -r skills/prd ~/.config/amp/skills/
cp -r skills/ralph ~/.config/amp/skills/
```

### 4. Configure Amp auto-handoff (recommended)

Add to `~/.config/amp/settings.json`:

```json
{
  "amp.experimental.autoHandoff": { "context": 90 }
}
```

This enables automatic handoff when context fills up, allowing Ralph to handle large stories that exceed a single context window.

## Workflow

### 1. Create a PRD

Use the PRD skill to generate a detailed requirements document directly in Linear:

```
Load the prd skill and create a PRD for [your feature description]
```

Answer the clarifying questions. The skill will:
- Create a Linear project with the PRD as description
- Create Linear issues for each user story
- Save `.ralph-project` with the project configuration

### 2. Or convert an existing PRD

If you have an existing markdown PRD, use the Ralph skill to convert it:

```
Load the ralph skill and convert tasks/prd-[feature-name].md to Linear
```

This creates a Linear project and issues from your markdown PRD.

### 3. Run Ralph

```bash
./scripts/ralph/ralph.sh [max_iterations]
```

Default is 10 iterations.

On first run, if `.ralph-project` doesn't exist, Ralph will interactively prompt you to select or create a Linear project.

Ralph will:
1. Create a feature branch (from project description)
2. Pick the highest priority issue with "Todo" status
3. Mark it as "In Progress"
4. Implement that single story
5. Run quality checks (typecheck, tests)
6. Commit if checks pass
7. Mark issue as "Done"
8. Add a comment with implementation details and learnings
9. Repeat until all issues are done or max iterations reached

## Key Files

| File | Purpose |
|------|---------|
| `ralph.sh` | The bash loop that spawns fresh Amp instances |
| `prompt.md` | Instructions given to each Amp instance |
| `setup-prompt.md` | Interactive setup for Linear project selection |
| `.ralph-project` | Local config with Linear project ID (gitignored) |
| `skills/prd/` | Skill for generating PRDs in Linear |
| `skills/ralph/` | Skill for converting markdown PRDs to Linear |
| `flowchart/` | Interactive visualization of how Ralph works |

## Linear Integration

Ralph uses Linear MCP for all task management:

| Old Approach | New Linear Approach |
|--------------|---------------------|
| `prd.json` | Linear Project (PRD in description) |
| User stories in JSON | Linear Issues in the project |
| `passes: true/false` | Issue status (Todo/In Progress/Done) |
| `progress.txt` | Issue comments with learnings |
| `priority: 1-4` | Linear Issue priority |

### Issue Format

User stories are stored in Linear issues with this description format:

```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Typecheck passes
```

### Learnings as Comments

After completing a story, Ralph adds a comment to the Linear issue:

```markdown
## Implementation Complete

**Thread:** https://ampcode.com/threads/...

### What was implemented
- Added new component
- Updated database schema

### Files changed
- src/components/Feature.tsx
- db/migrations/001_add_feature.sql

### Learnings for future iterations
- Pattern: Use existing Button component for actions
- Gotcha: Must run migrations before typecheck
```

Future iterations read these comments to learn from past work.

## Flowchart

[![Ralph Flowchart](ralph-flowchart.png)](https://ismailytics.github.io/ralph-with-linear/)

**[View Interactive Flowchart](https://ismailytics.github.io/ralph-with-linear/)** - Click through to see each step with animations.

The `flowchart/` directory contains the source code. To run locally:

```bash
cd flowchart
npm install
npm run dev
```

## Critical Concepts

### Each Iteration = Fresh Context

Each iteration spawns a **new Amp instance** with clean context. The only memory between iterations is:
- Git history (commits from previous iterations)
- Linear issues and comments (status and learnings)
- AGENTS.md files (reusable patterns)

### Small Tasks

Each issue should be small enough to complete in one context window. If a task is too big, the LLM runs out of context before finishing and produces poor code.

Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### AGENTS.md Updates Are Critical

After each iteration, Ralph updates the relevant `AGENTS.md` files with learnings. This is key because Amp automatically reads these files, so future iterations (and future human developers) benefit from discovered patterns, gotchas, and conventions.

Examples of what to add to AGENTS.md:
- Patterns discovered ("this codebase uses X for Y")
- Gotchas ("do not forget to update Z when changing W")
- Useful context ("the settings panel is in component X")

### Feedback Loops

Ralph only works if there are feedback loops:
- Typecheck catches type errors
- Tests verify behavior
- CI must stay green (broken code compounds across iterations)

### Browser Verification for UI Stories

Frontend stories must include "Verify in browser" in acceptance criteria. Ralph auto-selects the best available tool:

| Tool | When Used | Type |
|------|-----------|------|
| Playwright MCP | `mcp__playwright__*` tools available | Automated E2E testing |
| dev-browser skill | Fallback when Playwright unavailable | Manual visual verification |

The agent documents which tool was used in the Linear issue comment.

### Test-Driven Development (Optional)

For stories with complex business logic, you can add "Tests written first (TDD)" to acceptance criteria. This triggers a Red-Green-Refactor cycle:

1. **RED**: Write failing test, commit as `test: [Issue-ID] - Add failing test`
2. **GREEN**: Implement minimum code to pass test
3. **REFACTOR**: Clean up, commit as `feat: [Issue-ID] - [Title]`

TDD is recommended for:
- Complex business logic
- Utility functions and algorithms
- APIs with defined contracts

TDD is optional for:
- Simple UI changes
- Configuration updates
- Documentation

### Stop Condition

When all issues have "Done" status, Ralph outputs `<promise>COMPLETE</promise>` and the loop exits.

## Debugging

Check current state via Linear:
- View the project in Linear to see issue status
- Read issue comments for implementation learnings
- Check git history for commits

Or via command line:

```bash
# Check local project config
cat .ralph-project

# Check git history
git log --oneline -10
```

## Customizing prompt.md

Edit `prompt.md` to customize Ralph's behavior for your project:
- Add project-specific quality check commands
- Include codebase conventions
- Add common gotchas for your stack

## Resetting for a New Feature

To start a new feature:

1. Delete `.ralph-project` to clear the current project link
2. Run `./ralph.sh` - it will prompt you to select or create a new project
3. Or use the `/prd` skill to create a new PRD directly in Linear

Previous work remains in Linear for reference.

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Amp documentation](https://ampcode.com/manual)
- [Linear MCP documentation](https://linear.app/docs/mcp)
