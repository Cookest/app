# Cookest Mobile App — Agent Instructions

You are working on the **Cookest Mobile App**, a Flutter application using Riverpod and GoRouter.

## Quick Reference

| Attribute | Value |
|-----------|-------|
| Language | Dart 3.x |
| Framework | Flutter 3.x |
| State | Riverpod 2.5 |
| Navigation | GoRouter 17 |
| HTTP | Dio 5.9 + cookie manager |
| Design | Material 3, sage green (#7A9A65) |

## Documentation

📖 **Full documentation**: https://cookest-docs.vercel.app/docs (or run locally from `../docs/`)

Key pages:
- [Architecture Overview](../docs/content/docs/architecture/overview.mdx)
- [Repository Guide](../docs/content/docs/architecture/repositories.mdx)
- [Mobile Overview](../docs/content/docs/mobile/overview.mdx)
- [Mobile Architecture](../docs/content/docs/mobile/architecture.mdx)
- [Screens](../docs/content/docs/mobile/screens.mdx)
- [Theme](../docs/content/docs/mobile/theme.mdx)
- [Best Practices](../docs/content/docs/contributing/best-practices.mdx)
- [Agent Instructions](../docs/content/docs/ai/instructions.mdx)

## Architecture

```
lib/src/
├── core/
│   ├── api/           ← Dio HTTP client, interceptors, base URL
│   ├── errors/        ← Error models
│   ├── services/      ← Auth token manager
│   └── storage/       ← Secure/local storage wrappers
├── features/
│   ├── auth/          ← Login, register, onboarding
│   ├── home/          ← Featured recipes, alerts
│   ├── recipes/       ← List, filters, detail, cook mode
│   ├── meal_plan/     ← Weekly view, slot management
│   ├── pantry/        ← Inventory CRUD
│   ├── shopping_list/ ← List with price comparison
│   ├── chat/          ← AI assistant
│   ├── profile/       ← User profile, preferences
│   └── subscription/  ← Upgrade flow, tier management
└── shared/
    ├── components/    ← Reusable UI components
    ├── theme/         ← ColorScheme, TextTheme
    └── widgets/       ← Chips, cards, buttons
```

## Key Rules

1. **Riverpod for all state** — no `setState` except ephemeral UI state
2. **GoRouter for navigation** — no manual `Navigator.push`
3. **Access token in-memory only** — never persisted to storage
4. **Refresh via httpOnly cookie** — Dio cookie manager handles automatically
5. **Subscription tier from JWT** — decoded locally to gate UI
6. **`const` constructors** wherever possible
7. **Max ~150 lines** per widget file — decompose further

## Design System

- Brand: `#7A9A65` (sage green)
- Fonts: Playfair Display (headings), Inter (body)
- Material 3 with light + dark mode

## Commit Format

```
<type>(<scope>): <description>
```

Scopes: `auth`, `home`, `recipes`, `pantry`, `shopping`, `chat`, `theme`, `navigation`

## MCP Server

For programmatic documentation access, use the MCP server at `../docs/mcp/`.

---

## Session Protocols

### Startup (every session — non-negotiable)

1. `vault_read("Agents/context.md")` — live project memory
2. `vault_read("Errors/error-log.md")` — past mistakes to avoid repeating
3. `vault_read("Learnings/learning-log.md")` — past discoveries to reuse
4. `get_project_context()` — live system snapshot
5. If working with Flutter/Dart packages: `query-docs` via Context7 (IDs in `vault/Learnings/library-ids.md`)

### Context7 — Use Before Any Library Code

Do NOT guess package APIs from training data. Fetch the current docs:

```
query-docs({ libraryId: "/flutter/flutter", query: "your question" })
query-docs({ libraryId: "/rrousselGit/river_pod", query: "your question" })
```

Key IDs: Flutter `/flutter/flutter` · Riverpod `/rrousselGit/river_pod` · Dio `/cfug/dio`

### Shutdown (every session — non-negotiable)

1. `vault_append("Changes/changelog.md", entry)` — **append**, never overwrite
2. `vault_write("Sessions/YYYY-MM-DD-topic.md", content)` — session log
3. New screens? Update `agents/ui-agent.md`
4. New pattern or bug fix? `vault_append("Learnings/learning-log.md", ...)` or `vault_append("Errors/error-log.md", ...)`

### Coding Reference

- Patterns to follow: `vault/Patterns/code-patterns.md`
- Best practices: `vault/Patterns/coding-guidelines.md`
- What NOT to do: `vault/Patterns/anti-patterns.md`
