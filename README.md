# FinBalancer

Modern personal finance application - Spendee/Revolut style.

## Architecture

- **Backend**: .NET 8 Web API (JSON file storage for MVP)
- **Frontend**: Flutter (Web, iOS, Android)

## Quick Start

### 1. Backend (API)

```bash
cd FinBalancer.Api
dotnet run
```

API runs at http://localhost:5292
Swagger UI: http://localhost:5292/swagger

### 2. Frontend (Flutter)

**Prerequisites**: Flutter SDK 3.5+

```bash
cd FinBalancer.App
flutter pub get
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

If the Flutter project was created manually, run `flutter create .` first to add platform folders.

### 3. First Run

1. Start the API
2. Start the Flutter app
3. Login (local only - tap Continue)
4. Add a wallet
5. Add income/expense transactions

## Project Structure

```
FinBalancer/
├── FinBalancer.Api/          # .NET 8 Web API
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   └── Data/                 # JSON storage
└── FinBalancer.App/          # Flutter app
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    └── web/
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/transactions | List all transactions |
| POST | /api/transactions | Add transaction |
| DELETE | /api/transactions/{id} | Delete transaction |
| GET | /api/wallets | List wallets |
| POST | /api/wallets | Add wallet |
| GET | /api/categories | List categories |

## Future Migrations

- **Database**: PostgreSQL (schema ready)
- **Auth**: JWT (structure prepared)
