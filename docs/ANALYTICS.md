# Paywall-baseline analytics events

Helpers live in `lib/Utilities/analytics.dart` (Firebase Analytics / GA4). All params are anonymous: no PSN usernames or user ids.

Spec: hive `agents/product-manager-mvnobx3u/paywall-v1-spec.md`. User property `tier` = free | trial | premium | legacy_grace.

| Event | Params | Where |
|---|---|---|
| `cap_hit` | `type` (star/complete), `count` (manual items saved; PSN-synced never count) | `premiumGate` (paywall_page.dart) |
| `paywall_viewed` / `paywall_closed` | `source` (cap_star, cap_complete, settings, counter, legacy_notice, legacy_reminder); closed adds `purchased` 0/1 | `PaywallPage` |
| `plan_selected` | `plan` (monthly/annual) | plan card tap |
| `purchase_started` | `plan`, `trial` 0/1 | `PremiumProvider.purchase` |
| `trial_started` | `plan` | after purchase if entitlement periodType = trial |
| `purchase_success` | `plan`, `price` (number), `currency`, `country` (store), `trial` 0/1 | `PremiumProvider.purchase` |
| `purchase_failed` | `plan`, `error_code`, `user_cancelled` 0/1 | `PremiumProvider.purchase` |
| `restore_tapped` / `restore_result` | `result` (restored/none/error) | `PremiumProvider.restore` |
| `legacy_grace_started` / `legacy_grace_ended` | none | `PremiumProvider._init` |

## QA / build flags
- `--dart-define=RC_ANDROID_KEY=goog_… --dart-define=RC_IOS_KEY=appl_…`: RevenueCat public keys. If these are empty, the store is unavailable.
- `--dart-define=DEBUG_DAY_OFFSET=83`: shifts the grace clock. It only works in debug and profile builds; release builds ignore it.
- Legacy marker: `Games.db` already existed when this build first launched. The flag is stored once as prefs `legacy_checked`.

## Human steps in GA4
- Register custom dimensions (event scope): `type`, `source`, `plan`, `trial`, `price`, `currency`, `country`, `error_code`, `user_cancelled`, `purchased`, `result`; user property `tier`; custom metric: `count`.
- Mark `purchase_success` (and `trial_started`) as key events when wired.
- Unique users who "would hit the cap" = users with a `cap_hit` event, split by `kind`.
