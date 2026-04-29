# Cookest — Flutter Mobile App

This is the Flutter frontend for **Cookest**, an AI-assisted meal planning and kitchen management platform.

> **Moved from the API repository.**  
> The Flutter codebase was previously maintained as a separate `ui` branch inside the Cookest API repository. It has since been extracted into its own dedicated folder (`UI/`) within the project monorepo, allowing the frontend and backend to evolve independently while sharing the same repository root.

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
| Fonts | `google_fonts` (Playfair Display + Inter) |
| Animations | `flutter_animate` |

