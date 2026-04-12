const String baseUrl = 'http://127.0.0.1:8000/api/';
// const String baseUrl = 'https://pratikbaid3.pythonanywhere.com/api/';
const bool isTestEnv = false;
const String psnHelpUrl =
    'https://psnawp.readthedocs.io/en/stable/additional_resources/README.html';
const String psnLoginUrl = 'https://my.playstation.com/';
const String psnSsoCookieUrl = 'https://ca.account.sony.com/api/v1/ssocookie';

// PS4 endpoints
const String ps4GamesUrl = 'ps4/games';
const String ps4GuideUrl = 'ps4/guide/';

// PS5 endpoints
const String ps5GamesUrl = 'ps5/games';
const String ps5GuideUrl = 'ps5/guide/';

// Legacy aliases (keep for backward compatibility)
const String gamesUrl = ps4GamesUrl;
const String guideUrl = ps4GuideUrl;

// PSN endpoints
const String psnValidateUrl = 'psn/validate/';
const String psnSyncUrl = 'psn/sync/';
