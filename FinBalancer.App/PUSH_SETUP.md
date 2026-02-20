# Push notifikacije – postavljanje

## Što je implementirano

- **API**: Tablica `device_tokens`, endpointi `POST /api/devicetokens/register` i `unregister`, FCM slanje kad se kreira in-app notifikacija
- **Flutter**: firebase_messaging, registracija tokena nakon logina, brisanje pri logoutu

## Koraci za aktivaciju

### 1. Firebase projekt

1. Kreiraj projekt na [Firebase Console](https://console.firebase.google.com)
2. Uključi **Cloud Messaging** u postavkama projekta
3. Dodaj Android i/ili iOS app u projekt

### 2. Flutter

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

To kreira `lib/firebase_options.dart` i dodaje `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

### 3. API (backend)

1. U Firebase Console: Project Settings → Service accounts → Generate new private key
2. Spremi JSON datoteku na server
3. U `appsettings.json` postavi putanju:

```json
"Push": {
  "FirebaseServiceAccountPath": "/path/to/firebase-adminsdk-xxx.json"
}
```

### 4. Android (ako koristiš)

- `android/build.gradle`: classpath `com.google.gms:google-services`
- `android/app/build.gradle`: apply plugin `com.google.gms.google-services`

To obično napravi `flutterfire configure`.

### 5. iOS (ako koristiš)

- Capability **Push Notifications** u Xcode
- `flutterfire configure` dodaje `GoogleService-Info.plist`
