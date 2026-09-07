# OpenSpec + Superpowers Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modify three Superpowers skill files so that the brainstorming→writing-plans→finishing-a-development-branch pipeline generates and archives OpenSpec Change Folders instead of flat spec/plan docs.

**Architecture:** Three targeted edits to existing SKILL.md files — no new files, no new tooling beyond `openspec init` as a one-time repo setup. Brainstorming generates a Change Folder; writing-plans saves plan.md inside it; finishing-a-development-branch runs opsx:sync + opsx:archive as Step 0.

**Tech Stack:** Markdown (SKILL.md files), OpenSpec CLI (`@fission-ai/openspec`), bash (one-time init).

**Spec:** `docs/superpowers/specs/2026-09-07-openspec-superpowers-integration-design.md`

## Global Constraints

- Skill files live at: `~/.gemini/config/plugins/superpowers/skills/`
- Skill files are Markdown — no traditional unit tests; verification = grep confirming text is present
- Backward compatibility required: repos without `.openspec/` must not break
- Fallback behavior must be explicit in each modified skill
- Commit convention: `feat(superpowers): <subject>` — imperative mood, lowercase, no trailing period
- No AI attribution in commits

---

## File Map

| File | Action |
|---|---|
| `~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md` | Modify |
| `~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md` | Modify |
| `~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md` | Modify |

---

### Task 1: Modify `brainstorming` — output Change Folder

**Files:**
- Modify: `~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md`

**Interfaces:**
- Produces: Change Folder at `.openspec/changes/YYYY-MM-DD-<feature>/` with `proposal.md`, `design.md`, `tasks.md`, `specs/`
- Consumed by: Task 2 (`writing-plans`), Task 3 (`finishing-a-development-branch`)

- [ ] **Step 1: Locate the Documentation section in brainstorming/SKILL.md**

  ```bash
  grep -n "docs/superpowers/specs" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  ```
  Expected: one line showing the current save path.

- [ ] **Step 2: Replace the Documentation section**

  Find the block:
  ```
  - Write the validated design (spec) to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
    - (User preferences for spec location override this default)
  - Use elements-of-style:writing-clearly-and-concisely skill if available
  - Commit the design document to git
  ```

  Replace with:
  ```
  - **Pre-flight check:** before generating any artifact, verify `.openspec/` exists in the repo root.
    If it does not exist, stop and tell the user:
    > "OpenSpec is not initialized in this repo. Run `openspec init` first, then let me know to continue."
  - Write the validated design as a **Change Folder** to `.openspec/changes/YYYY-MM-DD-<feature>/`:
    - `proposal.md` — goal sentence + rationale (one paragraph)
    - `design.md` — full technical spec (same structure and depth as the current spec doc)
    - `tasks.md` — atomic checklist derived from the design, one task per independently testable deliverable
    - `specs/` — one `.md` per affected component, marked ADDED / MODIFIED / REMOVED
  - Commit the Change Folder to git
  ```

- [ ] **Step 3: Update the Spec Self-Review section — add two extra checks**

  Find the existing self-review list (4 items: Placeholder scan, Internal consistency, Scope check, Ambiguity check) and append after item 4:
  ```
  5. **tasks.md coherence:** every task in `tasks.md` maps to a component in `design.md`. No orphan tasks.
  6. **Delta spec tags:** every file in `specs/` is tagged ADDED, MODIFIED, or REMOVED. No untagged entries.
  ```

- [ ] **Step 4: Update the User Review Gate message**

  Find:
  ```
  > "Spec written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."
  ```

  Replace with:
  ```
  > "Change Folder written to `.openspec/changes/YYYY-MM-DD-<feature>/`. Please review `proposal.md`, `design.md`, and `tasks.md` before I invoke `writing-plans`."
  ```

- [ ] **Step 5: Verify changes are present**

  ```bash
  grep -c "Change Folder" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  grep -c "Pre-flight check" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  grep -c "tasks.md coherence" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  ```
  Expected: each returns 1 or more.

- [ ] **Step 6: Verify backward-compat text is NOT broken — old path gone**

  ```bash
  grep "docs/superpowers/specs" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  ```
  Expected: no output (old path removed).

- [ ] **Step 7: Commit**

  ```bash
  git -C ~/.gemini/config/plugins/superpowers add skills/brainstorming/SKILL.md
  git -C ~/.gemini/config/plugins/superpowers commit -m "feat(superpowers): output openspec change folder from brainstorming skill"
  ```

---

### Task 2: Modify `writing-plans` — read tasks.md, save plan.md inside Change Folder

**Files:**
- Modify: `~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md`

**Interfaces:**
- Consumes: `.openspec/changes/YYYY-MM-DD-<feature>/tasks.md` (from Task 1)
- Produces: `.openspec/changes/YYYY-MM-DD-<feature>/plan.md`
- Consumed by: `subagent-driven-development` (reads plan.md)

- [ ] **Step 1: Locate the save target line**

  ```bash
  grep -n "docs/superpowers/plans" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  ```
  Expected: one line with the current save path.

- [ ] **Step 2: Replace the save target**

  Find:
  ```
  **Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
  - (User preferences for plan location override this default)
  ```

  Replace with:
  ```
  **Save plans to:** `.openspec/changes/YYYY-MM-DD-<feature>/plan.md` (inside the active Change Folder)
  - **Fallback** (no Change Folder found): `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md` — legacy behavior, zero breaking change
  - (User preferences for plan location override this default)
  ```

- [ ] **Step 3: Add task source instruction at the start of the Overview section**

  Find the Overview section opening:
  ```
  Write comprehensive implementation plans assuming the engineer has zero context
  ```

  Prepend before it:
  ```
  **Task source:** if an OpenSpec Change Folder exists for this feature (`.openspec/changes/YYYY-MM-DD-<feature>/tasks.md`), read `tasks.md` as the starting task list and enrich each task with: actual test code, run commands, interface signatures, and TDD commit steps. Add tasks implied by `design.md` but missing from `tasks.md`. Do not reinvent tasks already defined there.

  ```

- [ ] **Step 4: Update the Spec field in the Plan Document Header**

  Find:
  ```
  **Spec:** [path to the spec/design doc this plan implements — the plan
  argues from the spec, so the spec travels with it; executors read both]
  ```

  Replace with:
  ```
  **Spec:** `.openspec/changes/YYYY-MM-DD-<feature>/design.md` (or legacy path if no Change Folder)
  ```

- [ ] **Step 5: Verify changes**

  ```bash
  grep -c "Change Folder" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  grep -c "tasks.md" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  grep -c "Fallback" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  ```
  Expected: each returns 1 or more.

- [ ] **Step 6: Verify old save path is gone**

  ```bash
  grep "^\*\*Save plans to:\*\* \`docs/superpowers" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  ```
  Expected: no output.

- [ ] **Step 7: Commit**

  ```bash
  git -C ~/.gemini/config/plugins/superpowers add skills/writing-plans/SKILL.md
  git -C ~/.gemini/config/plugins/superpowers commit -m "feat(superpowers): read tasks.md and save plan.md inside change folder"
  ```

---

### Task 3: Modify `finishing-a-development-branch` — add Step 0 (opsx sync + archive)

**Files:**
- Modify: `~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md`

**Interfaces:**
- Consumes: `.openspec/changes/YYYY-MM-DD-<feature>/` (from Tasks 1 & 2)
- Produces: `.openspec/archive/YYYY-MM-DD-<feature>/` + updated `.openspec/system/`

- [ ] **Step 1: Locate the Step 1 header**

  ```bash
  grep -n "^## Step 1" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md
  ```
  Expected: line number of `## Step 1: Verify Tests`.

- [ ] **Step 2: Insert Step 0 immediately before Step 1**

  Insert the following block just before `## Step 1: Verify Tests`:

  ```markdown
  ## Step 0: OpenSpec Sync & Archive (if applicable)

  Detect whether an active Change Folder exists for this branch:

  1. Check if `.openspec/changes/` exists in the repo root. If it does not exist, skip this step entirely.
  2. Read the `plan.md` header field `Spec:` to identify the active Change Folder path.
     If no `plan.md` is available, list `.openspec/changes/` and match by date/feature name to the current branch.
  3. If a matching Change Folder is found:
     ```bash
     opsx sync    # updates .openspec/system/ with completed changes
     opsx archive # moves .openspec/changes/<feature>/ to .openspec/archive/<feature>/
     ```
  4. If no matching Change Folder is found → skip silently.

  > **Note:** this step runs BEFORE verify-tests. Archiving records what was built,
  > regardless of whether the merge/PR subsequently succeeds.

  ```

- [ ] **Step 3: Renumber existing steps (Step 1 → Step 1, no renumber needed — Step 0 is new)**

  Verify the existing Step 1 header is still `## Step 1: Verify Tests` (not accidentally overwritten):
  ```bash
  grep -n "^## Step" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md
  ```
  Expected: `Step 0`, `Step 1`, `Step 2`, `Step 3`, `Step 4`, `Step 5`, `Step 6` in order.

- [ ] **Step 4: Verify Step 0 content is correct**

  ```bash
  grep -c "opsx sync" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md
  grep -c "opsx archive" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md
  grep -c "skip silently" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md
  ```
  Expected: each returns 1.

- [ ] **Step 5: Commit**

  ```bash
  git -C ~/.gemini/config/plugins/superpowers add skills/finishing-a-development-branch/SKILL.md
  git -C ~/.gemini/config/plugins/superpowers commit -m "feat(superpowers): add step 0 openspec sync and archive before merge menu"
  ```

---

### Task 4: Commit design doc to Gentleman.Dots and verify end-to-end

**Files:**
- No new files — verification only

**Interfaces:**
- Consumes: all three modified SKILL.md files from Tasks 1-3

- [ ] **Step 1: Verify all three skills have been modified**

  ```bash
  git -C ~/.gemini/config/plugins/superpowers log --oneline -3
  ```
  Expected: three commits matching the feat(superpowers) messages from Tasks 1-3.

- [ ] **Step 2: Spot-check cross-consistency — brainstorming output matches writing-plans input**

  ```bash
  grep "tasks.md" ~/.gemini/config/plugins/superpowers/skills/brainstorming/SKILL.md
  grep "tasks.md" ~/.gemini/config/plugins/superpowers/skills/writing-plans/SKILL.md
  ```
  Expected: both reference `tasks.md` inside the Change Folder consistently.

- [ ] **Step 3: Spot-check finishing-a-development-branch Step 0 is before Step 1**

  ```bash
  grep -n "^## Step" ~/.gemini/config/plugins/superpowers/skills/finishing-a-development-branch/SKILL.md | head -4
  ```
  Expected first two lines: `Step 0: OpenSpec`, `Step 1: Verify Tests`.

- [ ] **Step 4: Commit Gentleman.Dots plan doc**

  ```bash
  git -C /home/juniorcorzo/Gentleman.Dots add docs/superpowers/plans/2026-09-07-openspec-superpowers-integration.md
  git -C /home/juniorcorzo/Gentleman.Dots commit -m "docs: add openspec superpowers integration implementation plan"
  ```

---

**Plan complete.** Two execution options:

1. **Subagent-Driven (recommended)** — dispatch fresh subagent per task, review between tasks
2. **Inline Execution** — execute tasks in this session using executing-plans
