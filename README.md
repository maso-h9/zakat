# Zakat Calculator App

A professional Flutter application for calculating Zakat (Islamic charity) with live gold prices, AI-powered assistance, and comprehensive Islamic financial tools.

## Features

- **Zakat Calculator** — Calculate Zakat for cash, gold, silver, trade goods, livestock, and crops
- **Live Gold Prices** — Real-time gold and silver prices updated every 6 hours via GitHub Actions
- **AI Assistant** — Gemini-powered AI for Islamic rulings and Zakat guidance
- **Ramadan Mode** — Special mode with Fitr Zakat calculator, daily reminders, and Ramadan-specific features
- **Multi-Currency Support** — 30+ currencies with live conversion rates
- **Nisab Comparison** — Compare Gold vs Silver Nisab thresholds
- **Cloud Sync** — Firebase-backed sync across devices
- **Offline Support** — Full functionality without internet using local cache
- **Dark Mode** — Complete dark theme support
- **Arabic & English** — Full bilingual support with RTL layout

## Folder Structure

```
lib/
├── core/                    # Core utilities and shared code
│   ├── cache/               # Cache management
│   ├── constants/           # App-wide constants
│   ├── di/                  # Dependency injection (get_it)
│   ├── errors/              # Custom exception hierarchy
│   ├── l10n/                # Localization
│   ├── network/             # Network utilities
│   ├── utils/               # Helpers (logging, responsive, performance)
│   └── widgets/             # Reusable widgets
├── data/                    # Data layer
│   ├── datasources/         # Remote & local data sources
│   └── repositories_impl/   # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/            # Business entities
│   ├── repositories/        # Repository interfaces
│   └── usecases/            # Use cases
├── l10n/                    # Localization files (ARB)
├── models/                  # Legacy models (migrating to domain/entities)
├── presentation/            # Presentation layer
│   ├── features/            # Feature screens + ViewModels
│   └── dependency_provider.dart
├── screens/                 # Screen widgets
├── services/                # Business services
├── utils/                   # Theme, utilities
└── main.dart                # App entry point
```

## Architecture

This project follows **Clean Architecture** with three distinct layers:

### Domain Layer
- **Entities** — Pure business objects (`ZakatRecord`, `WealthData`, `GoldPriceResult`, `AiMessage`)
- **Repositories** — Abstract interfaces defining data contracts
- **Use Cases** — Single-responsibility business logic (`CalculateZakatUseCase`, `SendAiMessageUseCase`)

### Data Layer
- **Data Sources** — Remote (Firestore, Gemini API) and local (Hive, SharedPreferences)
- **Repository Implementations** — Concrete implementations of domain interfaces

### Presentation Layer
- **ViewModels** — `ChangeNotifier` classes managing UI state
- **Screens** — Flutter widgets consuming ViewModels via Provider

## State Management

The app uses **Provider** for state management:

- `ZakatProvider` — Legacy God-object handling core Zakat state (migrating to Clean Architecture)
- `AiChatViewModel` — AI chat state via `SendAiMessageUseCase`
- `CalculatorViewModel` — Zakat calculation state via `CalculateZakatUseCase`
- `SettingsViewModel` — Settings state via `SettingsRepository`
- `HomeViewModel` — Home screen state with gold price integration

## Firebase Services

| Service | Purpose |
|---------|---------|
| **Firestore** | Gold prices, user data sync, country sources |
| **Firebase Auth** | Email, Google, Phone authentication |
| **Remote Config** | Gemini API key management |
| **Crashlytics** | Error tracking and crash reporting |
| **FCM** | Push notifications |

### Firestore Collections

- `gold_prices` — Live gold/silver prices by currency
- `users/{uid}/wealth` — User wealth data
- `users/{uid}/zakat_history` — Payment history
- `country_sources` — Official Zakat sources per country

## AI Module

The AI assistant uses **Google Gemini** via Firebase:

- **Model**: `gemini-3.1-flash-lite`
- **API Key**: Managed via Firebase Remote Config
- **Features**: Islamic rulings, Zakat calculations, bilingual responses
- **Error Handling**: 11 error codes with bilingual messages

## Nisab System

Three Nisab calculation modes:

1. **Global** — Standard Gold (85g) / Silver (595g) thresholds
2. **Official** — Country-specific thresholds from Firestore
3. **Custom** — User-defined values

## Country Sources

The `country_sources` Firestore collection provides official Zakat references per country, including government portals and religious authority links.

## Installation

### Prerequisites
- Flutter SDK 3.27+
- Dart SDK 3.10+
- Firebase project configured
- Android Studio / VS Code

### Setup

```bash
# Clone the repository
git clone https://github.com/your-org/zakat-app.git
cd zakat-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Variables

Set via `--dart-define`:

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

## Build APK

```bash
# Debug
flutter build apk --debug

# Release (with obfuscation)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## Screenshots

| Home | Calculator | AI Assistant | Settings |
|------|-----------|--------------|----------|
| ![Home](screenshots/home.png) | ![Calculator](screenshots/calculator.png) | ![AI](screenshots/ai.png) | ![Settings](screenshots/settings.png) |

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
