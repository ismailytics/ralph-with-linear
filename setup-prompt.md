# Ralph Setup - Linear Project Configuration

You are setting up Ralph to work with a Linear project. Your task is to help the user select or create a Linear project, then save the configuration.

## Your Task

### Step 1: Get Available Teams

Use `mcp__linear-server__list_teams` to get the available teams.

### Step 2: Get Available Projects

Use `mcp__linear-server__list_projects` to list existing projects.

### Step 3: Ask User to Select or Create

Present the user with options:

1. **Use existing project** - Show a numbered list of existing projects
2. **Create new project** - Ask for project name and create it

Ask the user which option they prefer.

### Step 4a: If Using Existing Project

- Get the project ID from the user's selection
- Use `mcp__linear-server__get_project` to get project details
- Extract the branch name from the project description (first line should be `Branch: ralph/...`)
- If no branch name found, ask the user for the branch name

### Step 4b: If Creating New Project

Ask the user for:
- **Project name** (e.g., "Task Priority Feature")
- **Branch name** (e.g., `ralph/task-priority`)
- **Optional: Project description** (the PRD content)

Then create the project:
```
mcp__linear-server__create_project({
  name: "<project-name>",
  team: "<selected-team-id>",
  description: "Branch: ralph/<feature-name>\n\n<optional-description>",
  state: "planned"
})
```

### Step 5: Save Configuration

Create the file `.ralph-project` in the same directory as this prompt with the following JSON content:

```json
{
  "linearProjectId": "<project-id>",
  "branchName": "ralph/<feature-name>"
}
```

Use the Write tool to save this file.

### Step 6: Confirm

Tell the user the setup is complete and show them:
- The selected/created project name
- The project ID
- The branch name
- How to start Ralph: `./ralph.sh [max_iterations]`

## Important Notes

- Always ask the user before making decisions
- The branch name MUST start with `ralph/`
- The .ralph-project file must be valid JSON
- If the user cancels, do not create the .ralph-project file
