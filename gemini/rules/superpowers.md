<!-- gentle-ai:superpowers-integration -->
# Superpowers Framework & Directives Integration Contract

This rule governs the strict binding between the Superpowers skill framework and mandatory system directives (`rules/` & `conventions.md`).

## Mandatory Skill Mappings

1. **`test-driven-development`**:
   - MUST strictly enforce [`rules/strict-tdd.md`](file:///home/juniorcorzo/.gemini/rules/strict-tdd.md) and [`conventions.md: Section 2`](file:///home/juniorcorzo/.gemini/antigravity-cli/conventions.md).
   - Write failing test first (Red), verify failure, then minimal code (Green), then refactor. Never write implementation code before tests.

2. **`subagent-driven-development` & `dispatching-parallel-agents`**:
   - MUST delegate code authoring and modifications to a dedicated Code Writing Subagent as mandated by [`rules/persona.md`](file:///home/juniorcorzo/.gemini/rules/persona.md).
   - Orchestrator must not write implementation code directly in the main thread.

3. **`verification-before-completion`**:
   - MUST launch a dedicated Subagent Verification per [`rules/persona.md`](file:///home/juniorcorzo/.gemini/rules/persona.md) upon completing tasks that modified or created code.
   - Verify all rules, tests, and conventions pass before reporting completion.

4. **`brainstorming` & `writing-plans`**:
   - MUST strictly adhere to [`conventions.md`](file:///home/juniorcorzo/.gemini/antigravity-cli/conventions.md) and Caveman Mode Ultra: dense, telegraphic, zero fluff.
   - MUST ask at most one clarifying question at a time and wait for user response.

5. **Terminal Commands across ALL Skills**:
   - MUST be prefixed with `rtk` per [`rules/rtk.md`](file:///home/juniorcorzo/.gemini/rules/rtk.md) to eliminate token waste (e.g., `rtk git status`, `rtk cargo test`, `rtk ls`).

6. **Code Exploration across ALL Skills**:
   - Whenever `.codegraph/` is present in the repository root, MUST prioritize `codegraph_explore` MCP tool or `codegraph explore` CLI over grep/find/reading raw files per [`rules/codegraph.md`](file:///home/juniorcorzo/.gemini/rules/codegraph.md).
<!-- /gentle-ai:superpowers-integration -->
