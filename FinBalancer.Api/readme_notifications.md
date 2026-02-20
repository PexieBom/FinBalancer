# Push notifikacije – što treba napraviti za osposobljavanje

Ovaj dokument opisuje korake potrebne za uključivanje push notifikacija u FinBalancer aplikaciju.

---

## Što je već implementirano

| Komponenta | Status |
|------------|--------|
| Tablica `device_tokens` u bazi | SQL migracija spremna |
| API endpointi za registraciju tokena | Implementirano |
| FCM servis za slanje | Implementirano |
| Flutter: firebase_messaging, registracija tokena | Implementirano |
| Automatsko slanje push-a uz in-app notifikacije | Implementirano |

Bez konfiguracije u nastavku, aplikacija radi normalno, ali push notifikacije neće biti poslane.

---

## Korak 1: Migracija baze

Ako baza još nema tablicu `device_tokens`, pokreni migraciju:

```bash
psql -U postgres -d finbalancer -f DatabaseSchema/011_device_tokens.sql
```

---

## Korak 2: Firebase projekt

1. Otvori [Firebase Console](https://console.firebase.google.com)
2. Kreiraj novi projekt (ili koristi postojeći)
3. U **Project Settings** (zupčanik) → **Cloud Messaging** provjeri da je Cloud Messaging API uključen
4. Ako piše „Legacy API disabled” – to je u redu, koristimo HTTP v1 API

---

## Korak 3: Flutter aplikacija

### 3.1 FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
cd FinBalancer.App
flutterfire configure
```

`flutterfire configure`:
- Povezuje projekt s Firebase projektom
- Kreira/ažurira `lib/firebase_options.dart`
- Dodaje `google-services.json` (Android)
- Dodaje `GoogleService-Info.plist` (iOS)

### 3.2 Android

`flutterfire configure` automatski dodaje Google Services plugin. Ako ručno postavljaš:

- `android/build.gradle` – classpath za `com.google.gms:google-services`
- `android/app/build.gradle` – `apply plugin: 'com.google.gms.google-services'`
- Datoteka `android/app/google-services.json` (generira FlutterFire)

### 3.3 iOS

1. Otvori `ios/Runner.xcworkspace` u Xcode
2. Odaberi target **Runner** → **Signing & Capabilities**
3. Klikni **+ Capability** i dodaj **Push Notifications**
4. Provjeri da postoji `GoogleService-Info.plist` (dodaje `flutterfire configure`)

---

## Korak 4: API backend – Firebase Service Account

1. U Firebase Console: **Project Settings** → **Service accounts**
2. Klikni **Generate new private key**
3. Spremi preuzetu JSON datoteku na sigurno mjesto (npr. `secrets/firebase-adminsdk-xxx.json`)
4. **Ne commitaj** ovu datoteku u git (dodaj u `.gitignore`)

### 4.1 Konfiguracija appsettings.json

```json
{
  "Push": {
    "FirebaseServiceAccountPath": "C:/path/to/firebase-adminsdk-xxx.json"
  }
}
```

Za Linux/Docker koristi apsolutnu putanju, npr.:
```
"/app/secrets/firebase-adminsdk-xxx.json"
```

### 4.2 Environment variable (alternativa)

Možeš koristiti env varijablu umjesto fiksne putanje u appsettings:

```bash
export Push__FirebaseServiceAccountPath="/path/to/firebase-adminsdk-xxx.json"
```

---

## Korak 5: Testiranje

1. Pokreni API s konfiguriranim `FirebaseServiceAccountPath`
2. Pokreni Flutter app na fizičkom uređaju ili emulatoru (web ne podržava FCM token)
3. Prijavi se u aplikaciju – token se automatski šalje na API
4. Pošalji pozivnicu za povezani račun – primatelj bi trebao dobiti push notifikaciju

---

## Troubleshooting

| Problem | Rješenje |
|---------|----------|
| „FirebaseOptions cannot be null” | Pokreni `flutterfire configure` |
| Push ne stiže na Android | Provjeri da je `google-services.json` u `android/app/` |
| Push ne stiže na iOS | Provjeri Push Notifications capability u Xcode |
| API ne šalje | Provjeri da je `FirebaseServiceAccountPath` točan i da datoteka postoji |
| Token se ne registrira | Provjeri da korisnik ima valjani auth token (prijavljen) |

---

## Sigurnost

- Service account JSON sadrži privatni ključ – nikad ga ne dijeljavaj i ne commitaj
- U produkciji koristi secrets manager (npr. Azure Key Vault, AWS Secrets Manager)
- `device_tokens` tablica povezana je s `users` – ON DELETE CASCADE briše tokene pri brisanju korisnika
