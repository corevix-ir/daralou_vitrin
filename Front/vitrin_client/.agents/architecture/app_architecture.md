# Streamlined Application Architecture Specification

## 1. Overview & Architecture Philosophy

The **Daralou Copper Kiosk Vitrin** (`vitrin_client`) uses a simplified **Feature-First Architecture**.
The core features currently implemented are:
- `features/auth/` (Device login modal, token storage & refresh)
- `features/news/` (Hero section news fetching from `GET /contents/vitrin`)
- `features/home/` (Main dashboard aggregator screen & Bento cards)

---

## 2. Directory Hierarchy

```
lib/
├── main.dart                          # Application entry point & runner
├── core/                              # Global infrastructure
│   ├── config/app_config.dart         # Base URL & runtime environment
│   ├── constants/app_constants.dart   # Timeouts, default strings, keys
│   ├── network/                       # Core HttpClient (Dio), Auth Token Storage & Interceptors
│   ├── theme/                         # AppColors, AppTypography, KioskTheme
│   └── utils/global_keys.dart         # Global messenger key for snackbars
├── shared/                            # Global UI components
│   └── widgets/                       # BentoCard, KioskPrimaryButton, GlobalSnackBar
└── features/                          # Feature Modules
    ├── auth/                          # Device login & token management
    ├── news/                          # Vitrin news service & Hero Carousel
    └── home/                          # Home screen layout & Bento cards
```

---

## 3. Mandatory Rules
1. **Core HTTP Client:** All remote HTTP traffic must route through `CoreHttpClient` with Dio.
2. **State & Mock:** `/contents/vitrin` fetches live backend data. Other cards use mock state until their endpoints are ready.
3. **Persisted Auth:** Access and refresh tokens are persisted via `AuthTokenStorage`.
