# Todoist Integration Roadmap

## Why It Helps

Todoist can give Hermes a lightweight action layer: capture tasks from Telegram, organize next actions, set due dates, and review open commitments.

## Credentials

Likely required:

- Todoist API token
- project IDs or labels for routing
- optional webhook secret if inbound updates are used

Store credentials only on the VDS or in an approved secret store. Do not commit them to this repo.

## Useful Hermes Skills Or Tools

- task extraction
- planning
- daily review
- project routing
- confirmation prompts for writes

## Data Hermes May Read

- projects
- sections
- labels
- tasks
- comments
- due dates
- completion state

## Data Hermes May Change

Only after explicit confirmation:

- create tasks
- update task names/descriptions
- set dates and priorities
- add comments
- complete or reopen tasks
- move tasks between projects

## Actions Requiring Confirmation

- connecting real credentials
- creating or completing tasks
- changing due dates
- bulk edits
- deleting tasks
- adding webhook endpoints

## Verification

Start with a limited test project:

- read projects
- read a known test task
- create one test task after confirmation
- update that test task after confirmation
- confirm no API token appears in logs or snapshots

## Risks

- accidental task spam
- wrong due dates creating user stress
- destructive completion/deletion
- leaking personal task data into snapshots
- confusing tentative plans with committed tasks
