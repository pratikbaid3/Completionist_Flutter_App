# Paywall-baseline analytics events

Helpers live in `lib/Utilities/analytics.dart` (Firebase Analytics / GA4). All params are anonymous: no PSN usernames or user ids.

| Event | Params | Status |
|---|---|---|
| `cap_hit` | `type` = `starred`\|`completed`; `count` (manual items already saved, >= 5) | Fired in `PS4GuideCard._underCap` when a free user is blocked. PSN-synced completions do not count. |
| `paywall_viewed` | `source` (`cap_starred`\|`cap_completed`) | `PaywallPage.initState` |
| `trial_started` | `plan` (store product id) | After purchase when entitlement `premium` has periodType trial |
| `purchase_success` | `plan`, `price` (localized), `country` (store country) | `PremiumProvider.purchase` |
| `purchase_fail` | `plan`, `price`, `country`, `reason` (`cancelled` or RC error code) | `PremiumProvider.purchase` |

## Human steps in GA4
- Register custom dimensions (event scope): `type`, `source`, `plan`, `price`, `country`, `reason`; custom metric: `count`.
- Mark `purchase_success` (and `trial_started`) as key events when wired.
- Unique users who "would hit the cap" = users with a `cap_hit` event, split by `kind`.
