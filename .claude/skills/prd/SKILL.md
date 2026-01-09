---
name: prd
description: "Generate a Product Requirements Document (PRD) as a Linear project with issues. Use when planning a feature, starting a new project, or when asked to create a PRD. Triggers on: create a prd, write prd for, plan this feature, requirements for, spec out."
---

# PRD Generator (Linear MCP Integration)

Create Product Requirements Documents directly in Linear as a project with issues. This enables seamless integration with Ralph for autonomous implementation.

**Prerequisites:** Linear MCP must be configured. See https://linear.app/docs/mcp

---

## The Job

1. Receive a feature description from the user
2. Ask 3-5 essential clarifying questions (with lettered options)
3. Select a Linear team (interactively)
4. Create a Linear project with the PRD as description
5. Create Linear issues for each user story
6. Save local `.ralph-project` configuration

**Important:** Do NOT start implementing. Just create the PRD in Linear.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

### Format Questions Like This:

```
1. What is the primary goal of this feature?
   A. Improve user onboarding experience
   B. Increase user retention
   C. Reduce support burden
   D. Other: [please specify]

2. Who is the target user?
   A. New users only
   B. Existing users only
   C. All users
   D. Admin users only

3. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Just the backend/API
   D. Just the UI
```

This lets users respond with "1A, 2C, 3B" for quick iteration.

---

## Step 2: Select Linear Team

Use `mcp__linear-server__list_teams` to get available teams and ask the user which team to use.

---

## Step 3: Create Linear Project

Use `mcp__linear-server__create_project` with the PRD content:

```json
{
  "name": "<Feature Name>",
  "team": "<team-id-or-name>",
  "description": "Branch: ralph/<feature-name-kebab-case>\n\n# <Feature Name>\n\n## Overview\n<Brief description>\n\n## Goals\n- Goal 1\n- Goal 2\n\n## Functional Requirements\n- FR-1: ...\n- FR-2: ...\n\n## Non-Goals\n- Non-goal 1\n\n## Technical Considerations\n- Notes...\n\n## Success Metrics\n- Metric 1",
  "state": "planned"
}
```

**Critical:** The first line of the description MUST be `Branch: ralph/<feature-name>` for Ralph to identify the correct git branch.

---

## Step 4: Create Linear Issues

For each user story, use `mcp__linear-server__create_issue`:

```json
{
  "title": "US-001: <Story Title>",
  "team": "<team-id-or-name>",
  "project": "<project-name-or-id>",
  "description": "As a <user>, I want <feature> so that <benefit>.\n\n## Acceptance Criteria\n- [ ] Criterion 1\n- [ ] Criterion 2\n- [ ] Typecheck passes",
  "priority": 1,
  "state": "Todo"
}
```

### Priority Mapping

Create issues in dependency order. Map story position to Linear priority:

| Story Position | Linear Priority |
|----------------|-----------------|
| 1st (first)    | 1 (Urgent)      |
| 2nd            | 2 (High)        |
| 3rd            | 3 (Normal)      |
| 4th and later  | 4 (Low)         |

### Issue Ordering Rules

Stories should be ordered by dependencies:
1. Database/Schema changes first
2. Backend/API logic second
3. UI components that use the backend third
4. Dashboards/aggregations last

---

## Step 5: Save Local Configuration

Create `.ralph-project` in the Ralph directory:

```json
{
  "linearProjectId": "<project-id-from-step-3>",
  "branchName": "ralph/<feature-name>"
}
```

Use the Write tool to save this file.

---

## User Story Format

Each story needs:
- **Title:** Short descriptive name
- **Description:** "As a [user], I want [feature] so that [benefit]"
- **Acceptance Criteria:** Verifiable checklist of what "done" means

**Important:**
- Acceptance criteria must be verifiable, not vague. "Works correctly" is bad. "Button shows confirmation dialog before deleting" is good.
- **For any story with UI changes:** Always include "Verify in browser" as acceptance criteria. (The agent will auto-select Playwright MCP or dev-browser based on availability)
- **For stories with testable logic (optional):** Consider adding "Tests written first (TDD)" as acceptance criteria when the story involves complex business logic, algorithms, or API contracts.
- **ALL stories:** Must include "Typecheck passes" as final criterion.

---

## Story Size Guidelines

Each story must be completable in ONE Ralph iteration (one context window). Right-sized stories:

**Good (single iteration):**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

**Too large (split these):**
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

**Rule of thumb:** If you can't describe the change in 2-3 sentences, it's too big.

---

## Writing for Junior Developers

The PRD reader may be a junior developer or AI agent. Therefore:

- Be explicit and unambiguous
- Avoid jargon or explain it
- Provide enough detail to understand purpose and core logic
- Number requirements for easy reference
- Use concrete examples where helpful

---

## Output Summary

After creating everything, show the user:

```
Created Linear Project: <Project Name>
Project ID: <uuid>
Branch: ralph/<feature-name>

Created Issues:
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

**User request:** "Create a PRD for adding task priority to our todo app"

**After clarifying questions, creates:**

1. **Linear Project:** "Task Priority System"
   - Description contains full PRD with `Branch: ralph/task-priority` on first line

2. **Linear Issues:**
   - `TEAM-101`: US-001: Add priority field to database (Urgent)
   - `TEAM-102`: US-002: Display priority indicator on task cards (High)
   - `TEAM-103`: US-003: Add priority selector to task edit (Normal)
   - `TEAM-104`: US-004: Filter tasks by priority (Low)

3. **Local file:** `.ralph-project` with project ID and branch name

---

## Checklist

Before finishing:

- [ ] Asked clarifying questions with lettered options
- [ ] Selected Linear team
- [ ] Created Linear project with PRD in description
- [ ] Project description starts with `Branch: ralph/<feature-name>`
- [ ] Created issues for all user stories
- [ ] Issues have correct priority (1-4 based on order)
- [ ] All stories include "Typecheck passes" criterion
- [ ] UI stories include "Verify in browser" criterion
- [ ] Stories with complex logic considered for "Tests written first (TDD)" criterion
- [ ] Stories are small enough for one iteration
- [ ] Stories are ordered by dependencies
- [ ] Saved `.ralph-project` configuration
