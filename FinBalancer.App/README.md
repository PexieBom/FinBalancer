# FinBalancer App

Flutter frontend for the FinBalancer personal finance application.

## Prerequisites

- Flutter SDK 3.5+
- Dart 3.5+

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (3.5+)
2. If this project was set up manually, run `flutter create .` in this folder to add platform folders
3. Ensure the backend API is running (`FinBalancer.Api` on http://localhost:5292)
4. Run `flutter pub get`
5. Run the app:
   - Web: `flutter run -d chrome`
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`

## API Configuration

The API base URL is set in `lib/services/api_service.dart`. Default: `http://localhost:5292/api`

For Android emulator, use `http://10.0.2.2:5292/api`
For iOS simulator, use `http://localhost:5292/api`
For physical device, use your computer's local IP (e.g. `http://192.168.1.x:5292/api`)
