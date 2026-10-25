# Paywall-baseline analytics events

Helpers live in `lib/Utilities/analytics.dart` (Firebase Analytics / GA4). All params are anonymous: no PSN usernames or user ids.

| Event | Params | Status |
|---|---|---|
| `cap_hit` | `kind` = `starred`\|`completed`; `game_name` (no numeric game id exists); `count` (items after this add, >= 5) | Wired in `InternalDbProvider.addTrophyToStarred/Complete`. Virtual: nothing is blocked. Fires on every add once count >= 5. |
| `paywall_viewed` | `source` | Defined, not wired (no paywall UI yet) |
| `trial_started` | `plan` | Defined, not wired |
| `purchase_success` | `plan` | Defined, not wired |
| `purchase_fail` | `plan`, `reason` (<=100 chars) | Defined, not wired |

## Human steps in GA4
- Register custom dimensions (event scope): `kind`, `game_name`, `source`, `plan`, `reason`; custom metric: `count`.
- Mark `purchase_success` (and `trial_started`) as key events when wired.
- Unique users who "would hit the cap" = users with a `cap_hit` event, split by `kind`.
