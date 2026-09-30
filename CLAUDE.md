# CLAUDE.md

## Core Operating Rule

Do not perform substantial implementation work yourself if the task can be delegated effectively.

Use sub-agents for:
- independent workstreams
- parallelizable research or implementation
- repository exploration across multiple areas
- isolated tasks that do not require the full conversation context
- tasks where delegation reduces the main agent's context usage

For trivial tasks, single-file edits, simple lookups, or work that depends heavily on the current context, work directly instead of spawning a sub-agent.

## Model Routing

Do not default to the most expensive or most capable model for every task.

Choose the cheapest model that can reliably complete the task:

- **Haiku / lightweight model:** simple searches, file discovery, formatting, summaries, repetitive edits, straightforward transformations, basic checks
- **Sonnet / mid-tier model:** normal coding tasks, debugging, implementation, refactoring, repository analysis, most sub-agent work
- **Opus / highest-capability model:** complex architecture, difficult debugging, ambiguous multi-step reasoning, high-stakes decisions, or tasks where weaker models have already failed

When creating a sub-agent, explicitly select an appropriate model whenever model selection is available.

Prefer cheaper models for sub-agents unless the task clearly requires stronger reasoning.

## Delegation Strategy

Before starting a substantial task:

1. Break the task into independent workstreams.
2. Decide which workstreams can be delegated.
3. Assign each delegated task the lowest-cost model capable of completing it well.
4. Run independent sub-agents in parallel when possible.
5. Keep the main agent focused on orchestration, synthesis, validation, and final integration.

Avoid unnecessary agent spawning. Delegation should reduce cost, context usage, or execution time — not add overhead.

## Escalation

Start with the lowest reasonable model.

Escalate to a stronger model only when:
- the task requires deeper reasoning,
- the result is incomplete or unreliable,
- the sub-agent reports uncertainty,
- multiple attempts have failed,
- architectural or cross-system judgment is required.

Do not use Opus merely because it is available.

## Final Validation

The main agent remains responsible for:
- reviewing delegated output
- checking consistency
- catching obvious errors
- integrating changes
- ensuring the final result satisfies the original request

Optimize for:
1. correctness
2. low unnecessary token/context usage
3. low model cost
4. fast execution

## Jev Skills

Installed from https://github.com/wuyoscar/jev-skill (five-entry source preview, commit `b7593a624a1b452769b554e0a688786089bd4bd7`) into `.claude/skills/` (`jev`, `jev-act`, `jev-documents`, `jev-eval`, `jev-triage`).

Selected mode: **B — agent simulation**. Do not call the Jev API or install the `jev-decide` CLI; do not send data to OpenRouter or TypeSafe. Mark results `mode: agent_simulation`, `jev_called: false`, `probability: null`, `confidence: null`. Switching to real Jev (mode A) requires explicit user approval.
