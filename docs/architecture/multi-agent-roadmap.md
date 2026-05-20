# Multi-Agent Roadmap

Goal: evolve Hermes from one Telegram assistant into a personal multi-agent system.

The core pattern should stay simple: the main personal assistant receives a Telegram request, classifies the task, delegates to the right specialized agent or skill, reviews the result, and replies to the user.

## Stage 1: Main Hermes Agent

Keep one primary Hermes agent with strong memory hygiene, clear workspace rules, and reliable runbooks.

Priorities:

- stable Telegram gateway
- documented workspace
- safe sync snapshots
- durable user preferences in memory
- large text corpora stored in workspace docs, not memory

## Stage 2: Specialized Skills

Add focused skills for repeatable work such as copywriting, planning, research, summarization, and document cleanup.

Skills should have:

- clear trigger examples
- input contract
- output contract
- quality checklist
- safe storage rules

## Stage 3: Delegation And Subagents

Use delegation for complex tasks where parallel work helps: research plus drafting, code exploration plus implementation, or planning plus verification.

The main assistant remains responsible for:

- deciding when delegation is useful
- giving bounded tasks
- checking final output
- asking the user before irreversible actions

## Stage 4: Integrations

Add integrations such as Notion, Todoist, Google Workspace, CRM, email, and calendar only after credentials and permissions are designed.

Start read-only where possible. Require confirmation for writes, deletes, sends, shares, purchases, or changes to external systems.

## Stage 5: Agent Roles

Introduce named roles with an orchestrator-worker approach:

- orchestrator: routes tasks, applies safety rules, composes final answer
- copywriter: drafts and rewrites text
- planner: decomposes goals into tasks and timelines
- researcher: gathers and cites external information
- operator: prepares runbooks and deployment steps

Each role should have a small contract and tests.

## Stage 6: Separate Instances Or Services

Use separate Hermes instances or separate services only when real isolation is needed:

- separate credentials
- different reliability requirements
- risky tools
- independent deployment lifecycle
- heavy resource usage

Do not split services just to make the architecture look advanced.
