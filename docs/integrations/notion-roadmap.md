# Notion Integration Roadmap

## Why It Helps

Notion can become a structured knowledge base for Hermes: project notes, content plans, decision logs, CRM-like pages, meeting notes, and long-term reference material.

## Credentials

Likely required:

- Notion integration token
- selected page or database permissions
- optional workspace metadata

Store credentials only on the VDS or in an approved secret store. Do not commit them to this repo.

## Useful Hermes Skills Or Tools

- document summarization
- structured note creation
- research synthesis
- planning
- routing rules for read versus write tasks

## Data Hermes May Read

- selected pages
- selected databases
- project docs
- content plans
- public metadata for pages granted to the integration

## Data Hermes May Change

Only after explicit confirmation:

- create pages
- update task/status fields
- append notes
- create content drafts
- reorganize databases

## Actions Requiring Confirmation

- connecting real credentials
- granting new workspace/page access
- editing or deleting pages
- creating many pages in bulk
- sharing pages externally
- changing database schemas

## Verification

Start with read-only checks:

- list accessible pages/databases
- read a known test page
- create a disposable test page only after confirmation
- confirm that no token appears in logs or snapshots

## Risks

- overly broad workspace access
- accidental edits to important pages
- token leakage in logs
- schema drift if database properties are changed casually
- confusing memory with long-term document storage
