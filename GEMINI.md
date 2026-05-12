# Gemini CLI Instructional Context: Aemo Finance (Aemo Loan App)

This document provides a comprehensive overview of the Aemo Finance project to guide future interactions and development within this codebase.

## Project Overview
Aemo Finance is a cross-platform Flutter application designed for loan management and financial services. It enables users to apply for loans, track their application status, and manage withdrawals. The application supports multiple countries (e.g., Belize, Panama, Oman, South Africa) with localized banking options and interest rates.

### Core Technologies
- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK `>=3.0.0 <4.0.0`)
- **State Management:** [Riverpod](https://riverpod.dev/) (currently using manual `Provider` definitions in `lib/data/providers/`, but `riverpod_generator` and `riverpod_annotation` are available in pubspec).
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
- **Design:** Material Design with custom theming and responsive layouts.
- **Web Support:** Optimized for both mobile and desktop web browsers.

## Project Architecture
The project follows a feature-first directory structure, promoting modularity and scalability.

### Directory Structure
- `lib/app/`: Global application configuration, including the central router (`router.dart`).
- `lib/core/`: Application-wide constants, themes, and utility functions (`app_colors.dart`, `app_strings.dart`, `formatters.dart`).
- `lib/data/`: Data layer containing models, repositories, and Firebase service implementations.
- `lib/features/`: UI and business logic organized by feature:
  - `admin/`: Administrative dashboard and user management.
  - `auth/`: User registration, login, and password reset.
  - `calculator/`: Loan interest and payment calculators.
  - `dashboard/`: User-specific dashboard and profile management.
  - `landing_page/`: Responsive landing pages for mobile and desktop.
  - `loan_application/`: Multi-step loan application flow.
  - `loan_status/`: Real-time tracking of application progress.
  - `withdrawal/`: Fund withdrawal requests and history.
- `lib/shared/`: Reusable UI components and layouts.

## Core Data Symbols
- **Models:** `User` (`user_model.dart`), `LoanApplication` (`loan_application_model.dart`), `BankAccount` (`bank_account_model.dart`), `Withdrawal` (`withdrawal_model.dart`).
- **Services:** `FirebaseAuthService`, `FirestoreService`, `StorageService` (defined in `lib/data/services/`).
- **Providers:** Service providers are currently defined manually in `lib/data/providers/service_providers.dart`.

## Development Rules & Constraints
- **Model Preferences:** Keep responses concise. Do not use extended thinking mode.
- **Test-Driven Development (TDD):** Thorough tests (unit and widget tests) for new features MUST be written **before** you start developing the feature implementation. Place tests in the `test/` directory following the feature structure.
- **State Management:** Use `riverpod_generator` for all new providers. Avoid manual `Provider` definitions.
- **Widget Size Limit:** Keep widget files under 400 lines. Complex screens MUST be split into smaller, reusable private or shared widgets.
- **Logic Separation:** Business logic (Firebase calls, data transformations) MUST live in `Notifiers` or `Services`. Do not put complex logic inside `onPressed` handlers or `build` methods.
- **Routing & State:** NEVER rely on `state.extra` as the primary data source for a screen. Always use path/query parameters to fetch the "Source of Truth" to ensure page refreshes work correctly on Web.
- **Firebase Operations:** All data operations MUST go through the dedicated service classes defined in `lib/data/services/`. Do not call Firebase directly from UI widgets.
- **Responsive UI:** Always use the `ResponsiveLayout` widget for new screens.
- **Currency & Formatting:** Use `Formatters.currency(amount, countryCode)` for localized display.
## Navigation & Routing
Navigation is managed via `go_router` in `lib/app/router.dart`. Key routes include:
- `/home`: Landing page.
- `/login`, `/register`: Authentication.
- `/dashboard`: User workspace.
- `/apply`: Loan application.
- `/admin`: Administrative interface (guarded by role-based access).

## Development Commands

### Environment Setup
- **Install Dependencies:** `flutter pub get`
- **Generate Code:** `dart run build_runner build --delete-conflicting-outputs` (Required for Riverpod annotations and other generated files).

### Running & Testing
- **Run App:** `flutter run -d <device_id>`
- **Analyze Code:** `flutter analyze`
- **Run Tests:** `flutter test`

### Deployment (Web)
- **Mandatory Build:** ALWAYS run `flutter build web --release` before pushing changes to ensure the production-ready assets are up to date.
- **Source Control:** The `build/web` folder MUST be staged and pushed to git for deployment purposes.

### Development Commands
- **Install Dependencies:** `flutter pub get`
- **Generate Code:** `dart run build_runner build --delete-conflicting-outputs` (Required for Riverpod annotations and other generated files).
- **Build Web:** `flutter build web --release`
- **Run App:** `flutter run -d <device_id>`
- **Analyze Code:** `flutter analyze`
- **Run Tests:** `flutter test`