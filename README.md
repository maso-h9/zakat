# Zakat App — تطبيق الزكاة

A professional Flutter application for calculating and managing Zakat (Islamic alms-giving), featuring AI-powered Islamic finance guidance.

## Architecture

The project follows **Clean Architecture** with feature-based organization:

```
lib/
├── core/                    # Shared utilities and infrastructure
│   ├── cache/              # CacheManager for Hive
│   ├── constants/          # App-wide constants
│   ├── di/                 # Service locator (get_it)
│   ├── errors/             # Exception hierarchy
│   ├── network/            # ApiClient for HTTP
│   └── utils/              # Logger, DataState, responsive helpers
├── domain/                 # Business logic layer
│   ├── entities/           # Domain models (WealthData, ZakatRecord, etc.)
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Single-purpose business operations
├── data/                   # Data layer
│   ├── datasources/        # Local (SharedPrefs, Hive) and remote (Firestore, Gemini)
│   └── repositories_impl/  # Concrete repository implementations
├── presentation/           # UI layer
│   ├── features/           # Feature-based ViewModels
│   └── dependency_provider.dart  # Provider DI bridge
├── features/               # Feature modules (barrel files)
├── models/                 # Legacy ZakatProvider (migration in progress)
├── screens/                # UI screens
├── services/               # Infrastructure services
└── widgets/                # Reusable UI components
```

## Features

- **Zakat Calculation** — Gold, silver, trade goods, debts, savings
- **Nisab System** — Global, official, and custom nisab thresholds with history tracking
- **Gold Price** — Live prices from Firestore with Hive cache fallback
- **AI Chat** — Gemini-powered Islamic finance assistant (Arabic + English)
- **Multi-Currency** — 12 currencies with automatic conversion
- **Localization** — Arabic and English
- **Firebase Sync** — Cloud backup of wealth data and zakat history
- **Notifications** — Zakat due date reminders, Ramadan mode, Fitr payment
- **Crashlytics** — Automatic error reporting

## AI Module

The AI chat uses Google's Gemini 3.1 Flash Lite model:
- System prompt includes user's wealth data for personalized advice
- Supports all 4 schools of Islamic thought (Hanafi, Maliki, Shafi'i, Hanbali)
- Bilingual error messages (Arabic + English)
- Technical errors never exposed to users

## Nisab Calculation

- **Global Nisab** = Gold price × 85 grams
- **Silver Nisab** = Silver price × 595 grams
- **Official Nisab** = Country-specific thresholds
- **Custom Nisab** = User-defined values
- History tracking of all nisab changes

## Country Sources

The app provides official Zakat authority links for each country:
- LYD (Libya), SAR (Saudi Arabia), AED (UAE), EGP (Egypt), USD, EUR, GBP, KWD, QAR, JOD, MAD, TND

## Firebase Setup

1. Run `flutterfire configure` to generate `firebase_options.dart`
2. In Firebase Console → Remote Config, add parameter: `gemini_api_key`
3. Get a free API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
4. Enable Firebase Auth (Anonymous + Email + Google)
5. Create Firestore database

## How to Run

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

## Environment Configuration

The Gemini API key is loaded in this order:
1. Firebase Remote Config (`gemini_api_key` parameter)
2. Compile-time: `flutter run --dart-define=GEMINI_API_KEY=your_key`

## Testing

- **Unit Tests**: `flutter test` (212+ tests)
- **Integration Tests**: `flutter test integration_test/`
- **Analysis**: `flutter analyze` (0 issues)

## CI/CD

GitHub Actions runs on every push/PR:
- `flutter analyze`
- `dart format --set-exit-if-changed .`
- `flutter test`
- `flutter build apk --debug`

## License

Proprietary — All rights reserved.
