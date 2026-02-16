# FinBalancer - App Store & Google Play Subscription Setup

## Pregled

FinBalancer podržava in-app subscriptions putem **Apple App Store** i **Google Play**. Ova dokumentacija objašnjava kako konfigurirati produkte i backend.

## API - Tablice i modeli

### UserSubscription
- `UserId` - korisnik
- `Platform` - "apple" | "google"
- `ProductId` - ID proizvoda (npr. finbalancer_premium_monthly)
- `PurchaseToken` - Apple: originalTransactionId, Google: purchaseToken
- `Status` - active | expired | cancelled
- `ExpiresAt` - datum isteka
- `ReceiptData` - Apple receipt (base64)
- `OrderId` - Google order ID

### SubscriptionPlan
- Definira produkte u `subscription_plans.json` ili seed default plans
- Product IDs: `finbalancer_premium_monthly`, `finbalancer_premium_yearly`

## Apple App Store

1. **App Store Connect** → Vaša app → In-App Purchases
2. Kreiraj **Auto-Renewable Subscription**:
   - Product ID: `finbalancer_premium_monthly` (mora odgovarati kodu)
   - Subscription Group
   - Cijena i lokalizacije
3. Za sandbox testiranje koristi Sandbox Apple ID
4. **Backend validacija**: Postavi `Subscriptions:UseRealValidation: true` u appsettings i implementiraj Apple verifyReceipt API poziv u `SubscriptionValidationService.ValidateAppleReceiptProductionAsync`

## Google Play

1. **Google Play Console** → Monetization → Subscriptions
2. Kreiraj subscription proizvode:
   - Product ID: `finbalancer_premium_monthly`
   - Base plan
3. Poveži s appom (release)
4. **Backend validacija**: Dodaj Google Play Android Publisher API, servisni račun, i implementiraj `purchases.subscriptions.get` u `SubscriptionValidationService.ValidateGooglePurchaseProductionAsync`

## Flutter - in_app_purchase

- Paket `in_app_purchase` podržava iOS i Android
- Na Windows/Web store nije dostupan - prikazuje se poruka
- Product IDs se učitavaju iz API-ja (`/api/subscriptions/plans`)
- Nakon uspješnog kupnje, `serverVerificationData` se šalje na backend `/api/subscriptions/validate`

## Webhooks (Real-Time Notifications)

Za automatsko ažuriranje statusa pretplate kad korisnik otkaže ili obnovi:

- **Apple**: App Store Server Notifications V2
- **Google**: Real-Time Developer Notifications (Cloud Pub/Sub)

Implementacija u `SubscriptionService.ProcessStoreNotificationAsync` (TODO).
