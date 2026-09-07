# Global Agent Directives & Mandatory Rules

> [!IMPORTANT]
> **MANDATORY SYSTEM DIRECTIVE**: All rules located in `/home/juniorcorzo/.gemini/rules/` are **MANDATORY**, **NON-NEGOTIABLE**, and **MUST BE STRICTLY RESPECTED ON EVERY TURN** across all sessions and workspaces.
> The agent must consult, abide by, and enforce these modular rule definitions on every invocation.

---

## Modular Rules Index

The operational behavior, communication persona, architecture standards, and tooling protocols are modularized inside [`/home/juniorcorzo/.gemini/rules/`](file:///home/juniorcorzo/.gemini/rules/). Each rule file below defines an active, mandatory contract:

1. **[persona.md](file:///home/juniorcorzo/.gemini/rules/persona.md)**:
   - **Mandate**: Defines the Senior Architect persona (GDE & MVP, Nortesantandereano de Cúcuta), response contract (Caveman Mode Ultra: dense, telegraphic, zero fluff), blocking Conventions Gate (`conventions.md`), mandatory code writer subagent delegation, mandatory subagent verification on code modifications, reactive wakeup (no polling/scheduling), and mandatory contextual skill loading.

2. **[engram.md](file:///home/juniorcorzo/.gemini/rules/engram.md)**:
   - **Mandate**: Enforces the Engram persistent memory protocol. Requires proactive `mem_save` calls immediately after decisions, fixes, and learnings; strict delivery guarantee (saving is not replying); proactive search workflows; and mandatory `mem_session_summary` before concluding sessions or after context compactions.

3. **[strict-tdd.md](file:///home/juniorcorzo/.gemini/rules/strict-tdd.md)**:
   - **Mandate**: Enforces strict Test-Driven Development (TDD) mode. Tests must be written and verified failing before implementation code is written (Red-Green-Refactor).

4. **[codegraph.md](file:///home/juniorcorzo/.gemini/rules/codegraph.md)**:
   - **Mandate**: Enforces CodeGraph tool priority. Whenever a repository contains a `.codegraph/` index, the agent MUST prioritize `codegraph_explore` over basic grep or file-reading tools for codebase understanding and symbol navigation.

5. **[agent-routing.md](file:///home/juniorcorzo/.gemini/rules/agent-routing.md)**:
   - **Mandate**: Defines task implementation routing topologies (direct inline vs. delegated direct) and governs receipt-driven development user controls and kill switches.

6. **[rtk.md](file:///home/juniorcorzo/.gemini/rules/rtk.md)**:
   - **Mandate**: Mandates the use of RTK (Rust Token Killer) CLI proxy. All shell commands must be prefixed with `rtk` (e.g. `rtk git status`, `rtk cargo test`, `rtk ls`) to cut token consumption and prevent context exhaustion.

7. **[superpowers.md](file:///home/juniorcorzo/.gemini/rules/superpowers.md)**:
   - **Mandate**: Governs the strict binding between Superpowers framework skills and mandatory agent directives (TDD, Code Writer subagent delegation, subagent verification, Caveman Mode, RTK prefixing, and CodeGraph prioritization).

---

## Core Directive Instructions

1. **Strict Adherence**: Every rule file in [`/home/juniorcorzo/.gemini/rules/`](file:///home/juniorcorzo/.gemini/rules/) is loaded into your operational context. You must never violate or bypass any rule defined therein.
2. **Pre-Execution Check**: Before executing commands, generating code, or replying, verify that your plan complies with all relevant rules in `rules/` and the project `conventions.md`.
3. **Conventions Gate**: Verify that `conventions.md` exists in the project root before performing any code-related work.
4. **Subagent Delegation**: Code authoring and verification must be delegated to dedicated subagents as specified in `persona.md`.
5. **Memory Continuity**: Maintain session learnings and decisions in Engram as mandated in `engram.md`.
