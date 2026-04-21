# Gemini CLI Instructional Context: Aemo Finance (Aemo Loan App)

This document provides a comprehensive overview of the Aemo Finance project to guide future interactions and development within this codebase.

## Project Overview
Aemo Finance is a cross-platform Flutter application designed for loan management and financial services. It enables users to apply for loans, track their application status, and manage withdrawals. The application supports multiple countries (e.g., Belize, Panama, Oman, South Africa) with localized banking options and interest rates.

### Core Technologies
- **Framework:** [Flutter](https://flutter.dev/) (Dart SDK `^3.0.0`)
- **State Management:** [Riverpod](https://riverpod.dev/) (with `riverpod_generator`)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Backend:** [Firebase](https://firebase.google.com/) (Auth, Firestore, Storage)
- **Design:** Material Design with custom theming and responsive layouts.
- **Web Support:** Optimized for both mobile and desktop web browsers.

## Project Architecture
The project follows a feature-first directory structure, promoting modularity and scalability.

### Directory Structure
- `lib/app/`: Global application configuration, including the central router (`router.dart`).
- `lib/core/`: Application-wide constants, themes, and utility functions.
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
## Model Preferences

- Keep responses concise
- Do not use extended thinking mode
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
- **Generate Code:** `dart run build_runner build --delete-conflicting-outputs` (Required for Riverpod annotations).

### Running & Testing
- **Run App:** `flutter run -d <device_id>`
- **Analyze Code:** `flutter analyze`
- **Run Tests:** `flutter test`

### Deployment (Web)
- **Build Web:** `flutter build web --release`

## Development Conventions
- **Linting:** Follows `package:flutter_lints/flutter.yaml`.
- **State Management:** Use `ProviderScope` at the root and prefer `ConsumerWidget` or `ConsumerStatefulWidget` for accessing Riverpod providers.
- **Firebase:** All data operations should go through the services defined in `lib/data/services/`.
- **Responsive Design:** Use the `ResponsiveLayout` widget to handle desktop and mobile differences.

---
*Note: This file is intended for use by Gemini CLI to maintain project context. Updates should be made as the architecture evolves.*
