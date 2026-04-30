# Cookest — Flutter Mobile App

This is the Flutter frontend for **Cookest**, an AI-assisted meal planning and kitchen management platform.

> **Moved from the API repository.**
> The Flutter codebase was previously maintained as a separate `ui` branch inside the Cookest API repository. That branch is **no longer active**. The app has been extracted into its own dedicated folder (`UI/`) within the project monorepo, allowing the frontend and backend to evolve independently. All Flutter development now happens here.

---

## Full documentation

The complete project documentation — covering UI design language, screen-by-screen guides, backend API reference, and setup instructions — lives in the Fumadocs site located at `../docs/`:

```bash
cd ../docs
bun run dev
# Open http://localhost:3000/docs
```

| Section | URL path |
|---|---|
| Project overview | `/docs` |
| Mobile UI & theming | `/docs/mobile/theme` |
| Screens reference | `/docs/mobile/screens` |
| User guide | `/docs/user-guide/overview` |
| API authentication | `/docs/backend/authentication` |
| API endpoints | `/docs/backend/endpoints/recipes` |

---

## What the app does

Cookest helps users cook smarter with less effort:

- **Onboarding** — collects cooking skill, household size, dietary restrictions, health goals, and cuisine preferences to personalise the experience from day one.
- **Recipe browser** — searchable and filterable recipe catalogue with dietary tags, cuisine filters, difficulty, and an *inventory match* mode ("what can I cook tonight?") that scores each recipe against the user's pantry.
- **Pantry (inventory)** — track ingredients at home with quantities, units, storage locations, and expiry dates. Expiring-soon alerts surface automatically.
- **Meal planner** — AI-generated weekly plan with breakfast, lunch, dinner, and snack slots across 7 days. Individual slots can be swapped, completed, or marked as a flex/relief day.
- **Shopping list** — synced from the active meal plan and filtered against current inventory; Pro users see live supermarket prices and a single-store/cheapest-split optimizer.
- **AI cooking assistant** — conversational chat powered by a local Ollama model with user context (inventory, preferences, cooking history) baked into the system prompt.
- **Profile & preferences** — household details, dietary settings, health goals, and the AI taste preference weights learned over time from ratings and cooking history.
- **Subscription** — Stripe-based Free / Pro / Family tier management with an in-app upgrade paywall.

---

## Quick start

### Prerequisites

- Flutter 3.x (`flutter doctor` to verify)
- Dart 3.x (`dart --version`)
- Android Studio or Xcode for device/emulator support
- A running Cookest API instance — see `../api/README.md`

### Setup

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

The app targets the Cookest API at:
- `http://10.0.2.2:8080` on Android emulator (maps to `localhost` on the host)
- `http://localhost:8080` on iOS simulator

To point at a different host, update `baseUrl` in `lib/src/core/api/`.

### Build

```bash
# Debug
flutter build apk --debug       # Android
flutter build ios --debug       # iOS (requires Xcode)

# Release
flutter build apk --release
flutter build ios --release
```

---

## Project structure

```
lib/
  main.dart                  — app entry point, theme and router setup
  src/
    core/
      api/                   — Dio HTTP client, interceptors, base URL config
      errors/                — error models and global error handling
      services/              — cross-feature services (auth token manager, etc.)
      storage/               — secure/local storage wrappers
    features/
      auth/                  — login, registration, onboarding screens
      home/                  — home screen, featured recipe, alerts
      recipes/               — recipe list, filters, detail, cook mode
      meal_plan/             — weekly meal plan view and slot management
      pantry/                — inventory management
      shopping_list/         — shopping list with price comparison
      chat/                  — AI cooking assistant chat
      profile/               — user profile and preferences
      subscription/          — upgrade flow and tier management
    shared/
      components/            — reusable UI components
      theme/                 — ColorScheme, TextTheme, AppTheme
      widgets/               — small shared widgets (chips, cards, buttons)
```

---

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Navigation | `go_router` |
| HTTP client | `dio` + `dio_cookie_manager` |
| Secure storage | `flutter_secure_storage` |
| Fonts | `google_fonts` (Playfair Display + Inter) |
| Animations | `flutter_animate` |
| Icons | `lucide_icons` |
| Image caching | `cached_network_image` |
| JWT decoding | `jwt_decoder` |

---

## Authentication flow

Access tokens are kept **in memory only** — never in SharedPreferences or secure storage. The httpOnly refresh cookie (set by the API on login) handles session persistence securely across app restarts via `dio_cookie_manager`.

```
App start
  └─ CookieJar has refresh cookie?
       Yes → POST /api/auth/refresh → new access token → proceed
       No  → show login screen

Login
  └─ POST /api/auth/login
       → access_token (in memory, 15-min TTL)
       → refresh_token cookie (httpOnly, 30-day TTL, auto-managed by Dio)

Authenticated request
  └─ Authorization: Bearer <access_token>

Token expiry
  └─ Dio interceptor catches 401 → POST /api/auth/refresh → retry original request
```

---

## Subscription gating

The JWT payload embeds the subscription tier so the app can show/hide Pro UI elements without an extra network call:

```dart
final payload = JwtDecoder.decode(accessToken);
final tier = payload['tier'] as String; // "free" | "pro" | "family"
if (tier == 'free') showUpgradePrompt();
```

Always handle HTTP **402** responses from the API by presenting the subscription upgrade paywall.

---

## Design system

| Token | Value |
|---|---|
| Brand colour | `#7A9A65` (sage green) |
| Primary font | Playfair Display (headings) |
| Body font | Inter |
| Theme | Material 3, light + dark support |

---

## Related

| Folder | Description |
|---|---|
| `../api/` | Rust + Actix-Web backend API |
| `../docs/` | Fumadocs documentation site |
| `../etl/` | Python ETL pipeline (data ingestion) |

