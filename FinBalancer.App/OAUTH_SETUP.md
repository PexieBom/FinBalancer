# Postavka Google i Apple prijave

## Google Sign-In

### Web

1. Otvori [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Odaberi projekt (ili kreiraj novi)
3. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**
4. Ako traži konfiguraciju ekrana za dohvat, prvo dovrši **OAuth consent screen**
5. Za Application type odaberi **Web application**
6. Unesi **Name** (npr. "FinBalancer Web")
7. U **Authorized JavaScript origins** dodaj:
   - `http://localhost` (za razvoj)
   - `http://localhost:7357` (ako koristiš `flutter run -d chrome`)
   - `https://tvoj-domen.com` (za produkciju)
8. Spremi i kopiraj **Client ID** (oblik: `123456789-xxx.apps.googleusercontent.com`)
9. U `web/index.html` zamijeni `REPLACE_WITH_GOOGLE_CLIENT_ID` s tvojim Client ID‑em u meta tagu:
   ```html
   <meta name="google-signin-client_id" content="TVOJ_CLIENT_ID.apps.googleusercontent.com">
   ```

### Android

1. U Google Cloud Console kreiraj **OAuth client ID** tipa **Android**
2. Unesi package name (npr. `com.example.fin_balancer_app`) i SHA-1 fingerprint
3. SHA-1: `cd android && ./gradlew signingReport` ili iz Android Studio

### iOS

1. U Google Cloud Console kreiraj **OAuth client ID** tipa **iOS**
2. Unesi bundle ID (npr. `com.example.finBalancerApp`)

---

## Apple Sign-In

Apple Sign-In radi **izravno samo na iOS i macOS** (bez dodatne konfiguracije osim "Sign in with Apple" capability u Xcode).

Na **webu** i **Androidu** gumb se ne prikazuje jer zahtijeva Apple Developer konfiguraciju (Service ID, domains, itd.). Za web/Android potreban je Apple Developer nalog i posebna postavka.
