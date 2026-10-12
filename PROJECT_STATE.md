# PROJECT_STATE — axiom

Last reviewed: **2026-10-12 (America/New_York)**. Continuity schema: **1**.

This is a maintained project handoff, not an assertion that every historical chat or runtime behavior has been verified. Recheck Git and source at session start. Architecture and feature notes below describe the audited local project unless explicitly labeled remote default.

## End goal

A mobile-first roguelite RTS with tactical nodes/units and procedural progression.

## Architecture

Godot project with GameManager, AI brain, node/trace scripts and procedural explosion effects.

## Decisions and workflow

- Mobile touch and performance are explicit README design priorities.
- Procedural mission generation and upgrade systems must remain roadmap items unless verified.
- Preserve existing acceptance gates and uncommitted work. The 2026-10-12 authorization covers continuity documentation branches only, not merging features, deploying, or pushing unrelated code.

## Current status

- Local working branch at audit: `main`; code snapshot `9ca569db888d0e7057b9f77e8369d80998206026`.
- Pre-existing working-tree changes: **0** entries. These were not staged, committed or discarded by continuity setup.
- Live GitHub default: `main` at `9ca569db888d0e7057b9f77e8369d80998206026`.
- Documentation is prepared on `docs/project-continuity-2026-10-12` from that default. Feature-branch implementation described below is not thereby merged.
- Repository: https://github.com/ZuruiKyoku/axiom (public).

## Completed work

These are source/history findings; historical test reports are labeled and are not fresh runtime verification.

- Source includes AI, node interactions and procedural effects; latest Git history records those additions.

## Known issues and gaps

- README's next milestone is enemy swarm logic, but later commits include AIBrain; documentation and implementation need reconciliation.
- No matching chat transcript or runtime validation available.
- No directly associated local coding transcript was found in the reviewed inventory. Project goals come from source/README unless explicitly marked inferred.
- ChatGPT discovery returned a bounded recent list, not every project conversation. Some retrieved assistant messages contain only content-reference placeholders; attachments and unavailable responses were not reconstructed.

## Roadmap

- Play the current prototype and map working AI behavior before choosing the next milestone.
- Verify unit attributes, game-state transitions and mobile performance.
- Reconcile the missing historical context before treating this document as a complete replacement for old chats.

## Next steps

1. Read this file and applicable `AGENTS.md`; inspect the current branch, working tree and remote refs.
2. Play the current prototype and map working AI behavior before choosing the next milestone.
3. Perform the project's required checks for any code change, obtain existing acceptance where required, and update this handoff with actual results.

## Verification and evidence

- This session verified repository identity, local Git metadata/tracked paths, live remote refs where configured, and inspected documentation/source evidence. It changed documentation only.
- No application build, unit-test suite, device test, deployment check or live-service test is implied by this audit. Prior successful checks do not validate later uncommitted edits.
- Evidence labels: **source present** is static evidence; **historical report** is a past session claim; **verified now** requires an explicitly recorded current check; **planned/unknown** is not implemented.

- `autoloads/GameManager.gd` — present on remote default; same content locally.
- `scenes/nodes/AIBrain.gd` — present on remote default; same content locally.
- `scenes/nodes/node.gd` — present on remote default; same content locally.

### History sources and coverage

No directly associated local coding transcript was found in the reviewed inventory. Project goals come from source/README unless explicitly marked inferred.

- No matching local transcript identified.

## Session handoff

- Last task: establish PROJECT_STATE.md and additive agent instructions from available project evidence.
- Documentation scope: preserve all pre-existing code, assets, branches, indexes and acceptance gates. A documentation branch does not back up uncommitted application work.
- Publication state: consult the actual Git log/remote branch; do not assume a prepared branch was pushed or merged. The continuity report records the verified publication result.
- Next owner: follow Next steps above, fill historical gaps, and replace stale status with dated evidence after meaningful work.
- Archive readiness: incomplete history and any local-only implementation still need reconciliation; do not infer that archiving all project chats is lossless.
