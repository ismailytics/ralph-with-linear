# Ralph with Claude Code, Linear & Playwright

![Ralph](ralph-computer.avif)

Ralph is an autonomous AI agent that runs [Claude Code](https://docs.anthropic.com/claude-code) in a loop until all tasks are complete. Each iteration is a fresh Claude Code instance with clean context. Memory persists via git history and Linear (projects, issues, comments).

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/claude-code) installed and authenticated
- [Linear MCP](https://linear.app/docs/mcp) configured
- [Superpowers](https://github.com/obra/superpowers) (recommended) or use the built-in `/prd` skill
- `jq` installed (`brew install jq` on macOS)

## Quick Start

**Important:** Always run `ralph.sh` from your project root, not from inside the ralph folder.

### 1. Create a Plan

Use the Superpowers brainstorm skill to create a `Plan.md`:

```
/superpowers:brainstorm [your feature idea]
```

**Alternative:** Use the built-in `/prd` skill if you don't have Superpowers installed.

### 2. Create Linear Project from Plan

Ask Claude Code to create a Linear project from your plan:

```
Create a Linear project from Plan.md with issues including labels, priorities, and dependencies. Set all issues to Todo status.
```

### 3. Initialize Ralph

```bash
./ralph-with-linear/ralph.sh
```

This opens an interactive Claude Code session to select/create a Linear project. After setup completes, a `.ralph-project` file is created with the project configuration.

### 4. Run the Autonomous Loop

Open a **new terminal** and run:

```bash
./ralph-with-linear/ralph.sh [iterations]
```

**Tip:** Set iterations to the number of issues in your Linear project.

### 5. Monitor and Review

- Track progress in Linear (issues move from Todo → In Progress → Done)
- Ralph commits after each completed task
- When done, run `/review` for a code review of unpushed commits

## Recovery

If Ralph gets stuck or stops responding:

1. Close the terminal
2. Run `./ralph-with-linear/ralph.sh` again

Ralph reads the current state from Linear and git, so it continues where it left off.

## How It Works

Each iteration:
1. Creates a feature branch (from project description)
2. Picks the highest priority "Todo" issue
3. Marks it "In Progress"
4. Implements the task
5. Runs quality checks (typecheck, tests, lint)
6. Commits if all checks pass
7. Marks issue "Done" and adds a comment with learnings
8. Repeats until all issues are done

## Run Modes

| Mode | Command | Use Case |
|------|---------|----------|
| **HITL** (human-in-the-loop) | `./ralph-with-linear/ralph-once.sh` | Learning, watching Ralph work |
| **AFK** (away from keyboard) | `./ralph-with-linear/ralph.sh [n]` | Bulk work, overnight runs |

Start with HITL to understand how Ralph works, then switch to AFK.

## File Structure

| File | Purpose |
|------|---------|
| `ralph.sh` | Main loop script (AFK mode) |
| `ralph-once.sh` | Single iteration (HITL mode) |
| `prompt.md` | Instructions for each Claude Code instance |
| `setup-prompt.md` | Interactive Linear project selection |
| `.ralph-project` | Local config with Linear project ID (gitignored) |

## Linear Integration

Ralph uses Linear MCP for task management:

| Concept | Linear Equivalent |
|---------|-------------------|
| PRD | Project description |
| User stories | Issues |
| Task status | Issue status (Todo/In Progress/Done) |
| Learnings | Issue comments |
| Priority | Issue priority (Urgent/High/Normal/Low) |

### Issue Format

```markdown
As a [user], I want [feature] so that [benefit].

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Typecheck passes
```

## Advanced Features

### Browser Testing

Ralph auto-selects the best available browser testing tool:

| Tool | When Used |
|------|-----------|
| Playwright MCP | When `mcp__playwright__*` tools available |
| dev-browser skill | Fallback |

Add "Verify in browser" to acceptance criteria for UI stories.

#### Playwright MCP Setup

For autonomous operation, Playwright MCP must run in **headless mode**. This prevents browser windows from opening and allows parallel agent instances.

**Installation via Claude Code CLI:**

```bash
claude mcp add playwright -- npx @playwright/mcp@latest --headless
```

**Manual configuration** (add to `~/.claude.json` or project `.mcp.json`):

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless", "--isolated"]
    }
  }
}
```

#### Configuration Flags

| Flag | Purpose | When to Use |
|------|---------|-------------|
| `--headless` | No browser GUI | Always for autonomous agents |
| `--isolated` | Profile in memory only | Avoid disk state between runs |
| `--no-sandbox` | Disable sandboxing | Docker/CI environments |
| `--port <port>` | HTTP transport | Remote server operation |
| `--host 0.0.0.0` | Bind to all interfaces | Remote access |

#### Environment-Specific Configurations

**Local autonomous operation:**
```json
["@playwright/mcp@latest", "--headless", "--isolated"]
```

**Docker/CI pipeline:**
```json
["@playwright/mcp@latest", "--headless", "--no-sandbox"]
```

**Remote server:**
```json
["@playwright/mcp@latest", "--headless", "--port", "8931", "--host", "0.0.0.0"]
```

#### Why Headless for Autonomous Agents?

- **No distractions** - Chrome windows don't pop up while you work
- **Resource efficient** - Lower CPU/RAM usage
- **Parallelizable** - Multiple agent instances can run simultaneously
- **CI/CD compatible** - Works on servers without displays

#### Verify Installation

After setup, run `/mcp` in Claude Code and navigate to `playwright` to see available tools.

### Test-Driven Development

Add "Tests written first (TDD)" to acceptance criteria to enable:

1. **RED:** Write failing test → commit
2. **GREEN:** Implement minimum code
3. **REFACTOR:** Clean up → commit

### Customizing Behavior

Edit `prompt.md` to customize:
- Quality check commands
- Codebase conventions
- Stack-specific gotchas

## Alternative: Using /prd Skill

If you don't have Superpowers, use the built-in `/prd` skill:

```
/prd [your feature description]
```

This guides you through:
1. Clarifying questions
2. Linear team selection
3. Project and issue creation
4. `.ralph-project` configuration

## Tips

- **Small tasks:** Each issue should complete in one context window. Split large tasks.
- **CLAUDE.md updates:** Ralph updates these files with learnings for future iterations.
- **Feedback loops:** Ensure typecheck and tests work - broken code compounds across iterations.

## Resetting

To start a new feature:

1. Delete `.ralph-project`
2. Run `./ralph-with-linear/ralph.sh` to set up a new project

Previous work remains in Linear for reference.

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Claude Code documentation](https://docs.anthropic.com/claude-code)
- [Linear MCP documentation](https://linear.app/docs/mcp)
- [Superpowers](https://github.com/obra/superpowers)
