# Project Conventions

All work within this workspace must strictly adhere to the following foundational conventions:

## 1. Commit Standards (Conventional Commits)
- Format: `<type>(<scope>): <subject>`
- Types:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation only changes
  - `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)
  - `refactor`: A code change that neither fixes a bug nor adds a feature
  - `perf`: A code change that improves performance
  - `test`: Adding missing tests or correcting existing tests
  - `build`: Changes that affect the build system or external dependencies
  - `ci`: Changes to CI configuration files and scripts
  - `chore`: Other changes that don't modify src or test files
- Commit messages must be written in the imperative mood, lowercased subject, without trailing periods.
- **NO AI ATTRIBUTION**: Never include `Co-Authored-By`, `Generated-by`, or any AI-related attribution in commit messages or pull requests.

## 2. Strict Test-Driven Development (TDD)
- **Strict TDD Mode**: Always enabled.
- **Red-Green-Refactor Cycle**:
  1. Write unit / integration tests covering expected behavior and edge cases before writing implementation code.
  2. Verify that tests fail for the intended reason (Red).
  3. Write the minimal implementation required to make tests pass (Green).
  4. Refactor cleanly while maintaining passing tests (Refactor).
- Unit test coverage is required for all business logic, services, and utilities.

## 3. Architecture & Code Quality
- **Clean / Hexagonal / Screaming Architecture**:
  - High cohesion, loose coupling.
  - Strict separation of domain logic from external frameworks, databases, and UI layers.
  - Dependency inversion: depend on abstractions, not concretions.
- **Design Patterns**: SOLID principles, container-presentational pattern for UI, atomic design where applicable.
- **Quality Gates**: No shortcuts, dead code, or temporary hacks left in production code.

## 4. Communication & Response Style
- **Response-Length Contract**: Default to concise, direct, high-density responses (Caveman Mode Ultra). Eliminate conversational filler and unnecessary pleasantries.
- **Technical Rigor**: When explanations or deep-dives are required, provide thorough, technically accurate reasoning with zero fluff.
- **Verification First**: Verify before agreeing. If user claims or assumptions are technically incorrect, explain why with concrete evidence.
- **One Question at a Time**: Ask at most one clarifying question at a time and wait for response.

## 5. Tooling & Execution Guidelines
- **Codegraph**: Prioritize `codegraph_explore` MCP tool first to search and navigate files in repositories where `.codegraph/` is present.
- **RTK (Rust Token Killer)**: Always prefix shell commands with `rtk` (e.g. `rtk git status`, `rtk cargo test`, `rtk ls`) to minimize token consumption.
- **Engram**: Mandatory persistent memory protocol (`mem_save`, `mem_context`, `mem_search`, `mem_session_summary`). Proactively record decisions, bugfixes, patterns, and configurations.
- **Subagents**:
  - Code writing must be delegated to dedicated writer subagents.
  - Launch a verification subagent upon completing code changes to ensure all conventions are satisfied.
  - Never poll or schedule tasks; Antigravity uses reactive wakeup upon completion.
