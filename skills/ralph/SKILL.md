---
name: ralph
description: "Convert existing PRDs to Linear projects and issues for the Ralph autonomous agent system. Use when you have an existing PRD markdown file and need to set up Ralph. Triggers on: convert this prd, turn this into ralph format, set up ralph for this prd, ralph convert."
---

# Ralph PRD to Linear Converter

Converts existing PRD markdown files to Linear projects and issues for autonomous execution by Ralph.

**Prerequisites:** Linear MCP must be configured. See https://linear.app/docs/mcp

---

## The Job

1. Read the PRD markdown file provided by the user
2. Parse user stories and requirements
3. Select a Linear team (interactively)
4. Create a Linear project with PRD content
5. Create Linear issues for each user story
6. Save `.ralph-project` configuration

---

## Step 1: Parse the PRD

Read the PRD file and extract:
- **Title/Name** from `# PRD: [Name]` or first heading
- **Description/Overview** from Introduction section
- **Goals** from Goals section
- **User Stories** from User Stories section (parse US-XXX format)
- **Non-Goals** from Non-Goals section
- **Technical Considerations** from that section

---

## Step 2: Select Linear Team

Use `mcp__linear-server__list_teams` to get available teams and ask the user which team to use.

---

## Step 3: Create Linear Project

Use `mcp__linear-server__create_project`:

```json
{
  "name": "<PRD Title>",
  "team": "<team-id-or-name>",
  "description": "Branch: ralph/<feature-kebab-case>\n\n<Full PRD content as markdown>",
  "state": "planned"
}
```

**Critical:** The first line of the description MUST be `Branch: ralph/<feature-name>` for Ralph to identify the correct git branch.

---

## Step 4: Create Issues from User Stories

For each `### US-XXX:` section in the PRD:

1. Extract title (text after `US-XXX:`)
2. Extract description (the "As a..." line)
3. Extract acceptance criteria (the `- [ ]` items)
4. Map position to priority (1st=Urgent, 2nd=High, etc.)

Create issue using `mcp__linear-server__create_issue`:

```json
{
  "title": "US-001: <Title>",
  "team": "<team-id-or-name>",
  "project": "<project-id-or-name>",
  "description": "<As a... description>\n\n## Acceptance Criteria\n<Criteria as checklist>",
  "priority": 1,
  "state": "Todo"
}
```

### Priority Mapping

| PRD Story Position | Linear Priority |
|--------------------|-----------------|
| 1 (first)          | 1 (Urgent)      |
| 2                  | 2 (High)        |
| 3                  | 3 (Normal)      |
| 4+                 | 4 (Low)         |

---

## Step 5: Save Configuration

Create `.ralph-project` in the Ralph directory:

```json
{
  "linearProjectId": "<project-id>",
  "branchName": "ralph/<feature-name>"
}
```

---

## Story Size: The Number One Rule

**Each story must be completable in ONE Ralph iteration (one context window).**

Ralph spawns a fresh Amp instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard" - Split into: schema, queries, UI components, filters
- "Add authentication" - Split into: schema, middleware, login UI, session handling
- "Refactor the API" - Split into one story per endpoint or pattern

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

**Wrong order:**
1. UI component (depends on schema that does not exist yet)
2. Schema change

---

## Acceptance Criteria: Must Be Verifiable

Each criterion must be something Ralph can CHECK, not something vague.

### Good criteria (verifiable):
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"
- "Typecheck passes"
- "Tests pass"

### Bad criteria (vague):
- "Works correctly"
- "User can do X easily"
- "Good UX"
- "Handles edge cases"

### Always include as final criterion:
```
"Typecheck passes"
```

For stories with testable logic, also include:
```
"Tests pass"
```

### For stories with testable business logic (optional):
```
"Tests written first (TDD)"
```
Use this when the story involves complex logic, algorithms, or API contracts that benefit from test-first development.

### For stories that change UI, also include:
```
"Verify in browser"
```
(The agent will auto-select Playwright MCP or dev-browser based on availability)

---

## Validation Before Creating

Before creating in Linear, verify:

- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema → backend → UI)
- [ ] Every story has "Typecheck passes" as criterion
- [ ] UI stories have "Verify in browser"
- [ ] Stories with complex logic considered for "Tests written first (TDD)"
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story

If stories are too big, split them before creating issues.

---

## Output Summary

After creating everything, show the user:

```
Converted PRD to Linear:

Project: <Project Name>
ID: <uuid>
Branch: ralph/<feature-name>

Issues Created:
- <TEAM>-123: US-001: <Title> (Urgent)
- <TEAM>-124: US-002: <Title> (High)
- <TEAM>-125: US-003: <Title> (Normal)
- <TEAM>-126: US-004: <Title> (Low)

Saved .ralph-project configuration.

To start Ralph:
  ./ralph.sh [max_iterations]
```

---

## Example

**Input:** `tasks/prd-task-status.md`

**Creates:**
1. **Linear Project:** "Task Status Feature"
   - Description contains full PRD with `Branch: ralph/task-status` on first line

2. **Linear Issues:**
   - `TEAM-45`: US-001: Add status field to tasks table (Urgent)
   - `TEAM-46`: US-002: Display status badge on task cards (High)
   - `TEAM-47`: US-003: Add status toggle to task list rows (Normal)
   - `TEAM-48`: US-004: Filter tasks by status (Low)

3. **Local file:** `.ralph-project` with project ID and branch name

---

## Splitting Large PRDs

If a PRD has big features, split them:

**Original:**
> "Add user notification system"

**Split into:**
1. US-001: Add notifications table to database
2. US-002: Create notification service for sending notifications
3. US-003: Add notification bell icon to header
4. US-004: Create notification dropdown panel
5. US-005: Add mark-as-read functionality
6. US-006: Add notification preferences page

Each is one focused change that can be completed and verified independently.

---

## Checklist

Before finishing:

- [ ] Parsed PRD file successfully
- [ ] Selected Linear team
- [ ] Created Linear project with PRD in description
- [ ] Project description starts with `Branch: ralph/<feature-name>`
- [ ] Created issues for all user stories
- [ ] Issues have correct priority (1-4 based on order)
- [ ] All stories include "Typecheck passes" criterion
- [ ] UI stories include "Verify in browser" criterion
- [ ] Stories are small enough for one iteration
- [ ] Stories are ordered by dependencies
- [ ] Saved `.ralph-project` configuration
