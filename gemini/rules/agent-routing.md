<!-- gentle-ai:agent-routing -->
## Implementation Routing

Route work for the requested outcome with the smallest useful topology. Every change takes exactly one implementation route: direct inline or delegated direct.

- **Direct inline:** decide or verify from 1–3 files inline. Keep one mechanical, already-understood file change inline only when it needs no research and has no unresolved design decision.
- **Delegated direct:** delegate one narrow exploration when understanding needs 4+ files; delegate one writer for 2+ non-trivial files. Reading that prepares a write and broad research also delegate.
- These are implementation routes, not a ban on per-action delegation. Tests, builds, installs, and review actors may still use fresh workers without changing the selected route.

### Receipt-driven development is user-owned

The user controls receipt-driven development with a kill switch: `gentle-ai review mode enable|disable|status`.

- `status` is read-only. It reports the deciding source and the effective mode, and changes nothing.
- When the user asks to stop using receipt-driven development, run `disable`. Do not argue, do not work around it, and do not propose alternatives first.
- While it is disabled, keep implementing organically through direct inline or delegated direct: do not start reviews, do not retry, do not reactivate it, and do not fall back to any retired path.
- Delivery under a disabled switch follows ordinary repository policy and reports `disabled/unmanaged`, never a fabricated approval.
- Never enable receipt-driven development on the user's behalf unless the user explicitly asks for it.
<!-- /gentle-ai:agent-routing -->
