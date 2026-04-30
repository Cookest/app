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
