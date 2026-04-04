# Completionist — Feature Roadmap

## Free Features

### Trophy Experience
- **Trophy Progress Bar** — Show completion percentage per game with a visual ring/bar (e.g., "72% complete - 5 trophies left")
- **Trophy Rarity Indicator** — Show how rare each trophy is (common, uncommon, rare, ultra rare) based on community data
- **Trophy Checklist Mode** — Simple toggle checklist view for grinding sessions — no guide text, just trophy names + checkboxes
- **Trophy Type Sorting** — Sort guides by bronze/silver/gold/platinum or by difficulty
- **Hidden Trophy Spoiler Toggle** — Option to reveal or hide secret trophy descriptions

### Game Library
- **PS5 Game Support** — Expand game database beyond PS4
- **Xbox Game Support** — Complete the existing "Coming Soon" Xbox section
- **Recently Played Section** — Auto-sort games by last activity
- **Game Search Filters** — Filter by genre, trophy difficulty, estimated completion time
- **Game Difficulty Rating** — Community-voted difficulty rating (1-10) for each game's platinum

### Social & Sharing
- **Share Trophy Card** — Generate a shareable image card showing a completed platinum or game progress for social media
- **Share Game Progress** — Share current completion stats for a game as a styled image

### Quality of Life
- **Dark/AMOLED Theme Toggle** — True black theme option for OLED screens
- **Offline Mode Indicator** — Clear UI showing which guides are cached and available offline
- **Notification Reminders** — Gentle reminders to continue incomplete games after X days of inactivity
- **Swipe Actions on Trophy Cards** — Swipe to star or mark complete instead of long-press menu

---

## Paid (Premium) Features

### Unlimited Tracking
- **Unlimited Starred Trophies** — Remove the current 5-trophy cap
- **Unlimited Completed Trophies** — Remove the current 5-trophy cap
- **Unlimited Game Library** — No restrictions on saved games

### Organization & Planning
- **Custom Trophy Lists** — Create custom collections like "Easy Platinums", "Weekend Grind", "Story Trophies Only"
- **Trophy Roadmap View** — Step-by-step ordered guide showing the optimal path to platinum with missable trophies flagged
- **Trophy Notes** — Add personal notes to any trophy (e.g., "need 2 players for this one")
- **Pin Trophies** — Pin specific trophies to the top for quick access during a session

### PSN Integration
- **PSN Account Linking** — Enter PSN username to auto-fetch earned trophies
- **Auto-Sync Trophies** — Compare PSN trophy data against guide database and auto-mark completed
- **PSN Profile Stats** — Display PSN level, total trophies, and rarity breakdown from linked account

### Statistics & Insights
- **Completion Statistics Dashboard** — Total platinums, trophy breakdown charts, average completion rate, monthly activity
- **Trophy Timeline** — Visual timeline of when trophies were earned
- **Trophy Timer / Session Tracker** — Track how long you've been grinding a specific game, estimate time to platinum
- **Weekly/Monthly Summary** — Digest showing trophies earned, games progressed, and streaks

### Data & Sync
- **Cloud Backup & Sync** — Sync progress across devices via account login
- **Export to CSV/PDF** — Export your trophy collection data
- **Import from PSNProfiles** — Bulk import trophy data from a PSNProfiles profile URL

### Customization
- **Custom Themes** — Choose from multiple color themes (neon green, red, cyberpunk, etc.)
- **App Icon Pack** — Choose from alternate app icons
- **Home Screen Widget** — Widget showing current game progress and next trophy target

---

## Technical Implementation Notes

### PSN Integration Options
There is no official public PSN API. Viable approaches:
1. **PSNAWP (Python)** — Reverse-engineered PSN API wrapper, fits existing Python backend
2. **psn-api (Node.js)** — Alternative if backend is migrated
3. **PSNProfiles scraping** — Fetch public profile data by username (fragile, ToS risk)
4. **PSNProfiles API** — Limited API for registered developers

Recommended v1 approach: user enters PSN username, backend fetches public trophy data via PSNAWP, auto-marks earned trophies.

### Priority Matrix

| Feature                          | Impact | Effort | Tier    |
|----------------------------------|--------|--------|---------|
| Remove 5-trophy limit            | High   | Low    | Paid    |
| Trophy progress percentage       | High   | Low    | Free    |
| PS5 game support                 | High   | Medium | Free    |
| Share trophy card                | High   | Medium | Free    |
| Custom trophy lists              | High   | Medium | Paid    |
| PSN account linking              | High   | High   | Paid    |
| Statistics dashboard             | Medium | Medium | Paid    |
| AMOLED theme                     | Medium | Low    | Free    |
| Trophy roadmap view              | Medium | High   | Paid    |
| Cloud backup                     | Medium | High   | Paid    |
| Home screen widget               | Medium | Medium | Paid    |
| Export to CSV/PDF                 | Low    | Low    | Paid    |
| Custom themes                    | Low    | Medium | Paid    |
| Trophy timer                     | Low    | Medium | Paid    |
