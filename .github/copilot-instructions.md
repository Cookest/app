You are working on the **Cookest Mobile App** (Flutter 3, Riverpod 2, GoRouter, Dart 3).

## Mandatory Startup — Run Before Anything Else

**VS Code (MCP available):** Call in order:
1. `vault_read("Agents/context.md")` — live project memory
2. `vault_read("Errors/error-log.md")` — past mistakes to avoid
3. `vault_read("Learnings/learning-log.md")` — past discoveries
4. `get_project_context()` — live system snapshot

**CLI (MCP unavailable):** Use `view` tool instead:
1. `view ../vault/Agents/context.md`
2. `view ../vault/Errors/error-log.md` (last 30 lines)
3. `view ../CONTEXT.md`

Do not skip. These reads take seconds and prevent hours of repeated mistakes.

## Mandatory — Use Context7 Before Writing Library Code

Before writing code that uses Flutter/Dart packages, call Context7:

```
query-docs({ libraryId: "/flutter/flutter", query: "your question" })
query-docs({ libraryId: "/rrousselGit/river_pod", query: "your question" })
query-docs({ libraryId: "/flutter/packages", query: "go_router your question" })
```

Pre-resolved IDs for all libraries: `vault/Learnings/library-ids.md`
Do not guess package APIs. Training data is outdated. Use Context7 instead.

## Flutter / Dart Rules (enforced)

1. Riverpod for all state — no `setState` except ephemeral single-widget UI state.
2. GoRouter for all navigation — no direct `Navigator.push` or `Navigator.pop`.
3. Access token is memory-only — never write to storage.
4. `const` constructors everywhere they compile — prevents unnecessary rebuilds.
5. Max ~150 lines per widget file — decompose into child widgets.
6. Design tokens from `shared/theme/` always — never hardcode colours or font sizes.
7. `ref.watch` in build method only — never inside conditionals or event handlers.
8. `AsyncNotifierProvider` for API-backed state, `NotifierProvider` for local state.
9. Check `vault/Patterns/code-patterns.md` for Flutter patterns before inventing new ones.
10. Check `vault/Patterns/coding-guidelines.md` for full Flutter best practices.
11. Check `vault/Patterns/anti-patterns.md` for things that caused bugs in this codebase.

## Mandatory Shutdown — Run at End of Every Session

**VS Code:** Use MCP tools:
1. `vault_append("Changes/changelog.md", "## [YYYY-MM-DD] ...
What was done and why")`
2. `vault_write("Sessions/YYYY-MM-DD-topic.md", fullSessionLog)`
3. If new screens were added: update `agents/ui-agent.md`
4. `vault_append("Errors/error-log.md", ...)` or `vault_append("Learnings/learning-log.md", ...)`

**CLI:** Use bash + edit:
1. `bash printf "
## [DATE] TOPIC
- what
- why
" >> ../vault/Changes/changelog.md`
2. `create ../vault/Sessions/YYYY-MM-DD-topic.md` with session summary
3. Append to errors/learnings similarly

## CLI Mode

If MCP tools are unavailable (running in the Copilot CLI without MCP):

| VS Code MCP | CLI equivalent |
|---|---|
| `vault_read("Agents/context.md")` | `view ../vault/Agents/context.md` |
| `vault_append("Errors/...", text)` | `bash printf "..." >> ../vault/Errors/error-log.md` |
| `vault_append("Changes/...", text)` | `bash printf "..." >> ../vault/Changes/changelog.md` |
| `query-docs({ libraryId, query })` | `web_fetch` to official docs URL |
| `get_project_context()` | `view ../CONTEXT.md` |

**CLI startup:** `view ../vault/Agents/context.md` then `view ../vault/Errors/error-log.md`
**CLI shutdown:** append to `../vault/Changes/changelog.md`

## Mid-Session Re-Anchor

If this conversation has grown long (15+ messages), re-read `vault/Agents/context.md` (via `vault_read` or `view ../vault/Agents/context.md`) before your next action.
