# OpenCode Setup

This template includes optional AI development support via [OpenCode](https://opencode.ai) — an open source, terminal-based AI coding agent.

## What's included

The `.opencode/context/project-intelligence/` directory contains two context files the agent reads before writing any code or documentation:

| File | What it covers |
|---|---|
| `technical-domain.md` | Stack, architecture, naming conventions, code standards, packaging |
| `navigation.md` | Project layout, where to find things, how code flows |

This keeps AI-generated code consistent with the functional-core/imperative-shell architecture, Lua conventions, and project patterns established in this template — without you having to re-explain them on every prompt.

## Installation

Install OpenCode via the [official docs](https://opencode.ai/docs). It runs in your terminal alongside your editor.

## How it works

When you open this project in OpenCode, the agent automatically picks up the context files in `.opencode/context/`. Before writing any code, it loads:

- `technical-domain.md` — so it knows the stack, architecture rules, naming conventions, and code standards
- `navigation.md` — so it knows where files live and how to navigate the project

This means generated code will use the correct patterns (`state = game.update(state, dt)`, not direct mutation), correct naming (`camelCase` functions, `snake_case` files, `UPPER_SNAKE` constants), and correct module structure (always `local`, modules return a table of functions, no metatables).

## Agent control with OpenAgents Control

The `.opencode/` directory in this template follows the [OpenAgents Control (OAC)](https://github.com/darrenhinde/OpenAgentsControl?tab=readme-ov-file#openagents-control-oac) convention — an open source framework built on top of OpenCode that adds:

- **Pattern control** — define your coding standards once; the agent loads them before every task
- **Approval gates** — the agent proposes a plan and waits for your approval before writing or running anything
- **Editable agents** — agent behavior is plain markdown files you can read and modify directly
- **Team-ready** — context files are committed to the repo, so everyone on the team gets the same patterns automatically

The context files in `.opencode/context/project-intelligence/` are the project-intelligence layer of this system. They tell the agent about this specific project's architecture and conventions. OAC's core agent files (standards, workflows, commands) live in your global OpenCode config (`~/.config/opencode/`) and are not part of this template.

To use OAC with this template, follow the [OAC quick start](https://github.com/darrenhinde/OpenAgentsControl?tab=readme-ov-file#-quick-start). The project-intelligence context files included here will be picked up automatically once OpenCode is running.

## Removing it

If you don't plan to use OpenCode, delete the `.opencode/` directory entirely. Nothing else in the template depends on it.

```bash
rm -rf .opencode
```
