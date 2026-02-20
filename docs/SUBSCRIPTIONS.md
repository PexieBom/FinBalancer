# FinBalancer – Unified Subscriptions

Server-authoritative premium entitlement za iOS, Android i web.

## Pregled

- **Backend** je jedini izvor istine za premium pristup.
- **Verifikacija** uvijek preko servera – klijent nikad samostalno ne postavlja premium.
- Podržani kanali: iOS App Store, Google Play, web PayPal.

## Tablice u bazi

| Tablica | Opis |
|---------|------|
| `subscription_plans` | Mapiranje productCode → Apple/Google/PayPal ID-ovi |
| `subscription_purchases` | Transakcije (platform, external_id, status, start/end, raw_payload) |
| `user_entitlements` | Trenutni entitlement (is_premium, premium_until, source_platform) |
| `webhook_events` | Idempotentnost (provider, event_id) – duplikati se ignorišu |

## API endpointi

### Entitlement (autentificirano)

```
GET /api/billing/entitlement
→ { isPremium, premiumUntil, sourcePlatform, serverTimeUtc }
```

### Mobile (iOS/Android)

```
POST /api/billing/mobile/confirm
Body: { platform, productCode, storeProductId?, purchaseToken?, receiptData?, orderId? }
→ { isPremium, premiumUntil, sourcePlatform, serverTimeUtc }
```

### Web (PayPal)

```
POST /api/billing/paypal/create-subscription
Body: { productCode, paypalPlanId?, returnUrl, cancelUrl }
→ { approvalUrl, paypalSubscriptionId }

POST /api/billing/paypal/confirm
Body: { subscriptionId, productCode }
→ { isPremium, premiumUntil, sourcePlatform, serverTimeUtc }
```

### Webhooks (javni, potpis se provjerava)

```
POST /api/webhooks/apple
POST /api/webhooks/google
POST /api/webhooks/paypal
```

## Statusi pretplata

`active` | `grace` | `on_hold` | `canceled` | `expired` | `refunded`

Entitlement je aktivan samo za `active` i `grace`.

## Reconciliation job

- Pokreće se svakih sat vremena.
- Re-verificira active/grace pretplate s providerima.
- Označuje istekle pretplate.
- Ispravlja entitlement ako je webhook promašen.

## Aktivacija proizvoda / planova

1. U `subscription_plans` dodaj plan s:
   - `product_id` – interni ključ (npr. `finbalancer_premium_monthly`)
   - `apple_product_id` – App Store product ID
   - `google_product_id` – Google Play product ID
   - `paypal_plan_id` – PayPal plan ID (za web)

2. Kreiraj proizvode u svakom storeu (App Store Connect, Google Play Console, PayPal).

3. Webhooks:
   - Apple: App Store Server Notifications → `https://api.finbalancer.com/api/webhooks/apple`
   - Google: Real-time Developer Notifications → `https://api.finbalancer.com/api/webhooks/google`
   - PayPal: Webhooks u Developer Dashboard → `https://api.finbalancer.com/api/webhooks/paypal`

## Testiranje

### Sandbox / interno testiranje

- **iOS**: Sandbox Apple ID u Settings → App Store.
- **Android**: Internal testing track, test računi u Play Console.
- **PayPal**: Sandbox aplikacija, sandbox kupci.

### Klijent (Flutter)

- Na app startu i nakon kupnje poziva `GET /api/billing/entitlement` ili `GET /api/subscriptions/status` (backend koristi BillingService).
- Premium značajke uvijek gated prema backendu.
- Web: gumb „Subscribe with PayPal“ otvara approval URL; nakon redirecta se poziva `confirmPayPalSubscription`.
