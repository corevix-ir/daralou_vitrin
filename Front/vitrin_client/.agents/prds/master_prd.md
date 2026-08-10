# Master Product Requirement Document (PRD): Daralou Copper Kiosk Vitrin

## 1. System Overview & Executive Summary

The **Daralou Copper Kiosk Vitrin** (`vitrin_client`) is an interactive, enterprise-grade digital kiosk application designed for installation in the main lobby of Daralou Copper Company (شرکت مس درآلو). The platform serves as a multi-functional information hub, live commodity ticker, employee self-service portal (leave registration & sports booking), corporate news wall, facility map, feedback collector, and emergency broadcast terminal.

### Key Hardware & Operational Constraints
- **Target Screen & Orientation:** 55-inch Commercial Kiosk, Portrait Mode.
- **Native Resolution:** 1080 x 1920 pixels (Full HD Portrait).
- **Target Frame Rate:** 60 FPS continuous smooth rendering with hardware acceleration.
- **Language & Directionality:** Right-to-Left (RTL) primary language (Persian / Farsi).
- **Touch Ergonomics:** Dual-zone layout balancing high-reach visual broadcast zones with comfortable touch-reach interaction zones.
- **Offline / Connectivity Strategy:** Continuous operation resilience. If backend connectivity fails, the app seamlessly degrades to cached mock data with ambient state indicators.

---

## 2. Updated Ergonomics & Bento Layout Map (1080 x 1920)

```
+-------------------------------------------------------------+ 0px
| [1] REDESIGNED HEADER: Logo Placeholder (Circle), Company   | H: 120px
|     Title & 2-Line Clock, Date, Weather Info Bar            |
+-------------------------------------------------------------+ 120px
|                                                             |
| [2] HERO NEWS CAROUSEL: Visual Broadcast & Key Updates      | H: 420px
|     (High visibility broadcast zone - non-interactive)     |
|                                                             |
+------------------------------+------------------------------+ 540px
| [3] LEAVE REGISTRATION CARD  | [4] LME COPPER TICKER        | H: 300px
|     (Exclusive Staff Leave)  |     ($9,450 / ton +2.1%)     |
+------------------------------+------------------------------+ 840px
| [5] SPORTS RESERVATION CARD  | [6] LATEST NEWS CARD         | H: 340px
|     (رزرو ورزشی)             |     (آخرین اخبار)            |
+--------+---------------------+------------------------------+ 1180px
| [7] FACILITY MAP             | [8] FEEDBACK & SUGGESTIONS   | [9] RESTAURANT MENU | H: 620px
|     (نقشه طبقات)             |     (انتقادات و پیشنهادات)   |     (منوی رستوران) |
+--------+---------------------+------------------------------+ 1800px
| [10] EMERGENCY & SYSTEM TICKER FOOTER (911 Protocol Bar)   | H: 120px
+-------------------------------------------------------------+ 1920px
```

### Reachability Hierarchy
- **Broadcast Zone (0px - 540px):** Non-touch or minimal-touch visual information (Redesigned Header & Hero News Carousel). Easily scannable from 3–5 meters away.
- **Primary Touch Zone (540px - 1800px):** Positioned within comfortable height from floor level. Hosts all interactive cards (Leave Registration, LME Copper, Sports Booking, Latest News, Map, Feedback, Restaurant Menu).
- **Safety & Status Zone (1800px - 1920px):** High-visibility bottom ticker bar reserved for facility safety protocols and system status broadcasts.

---

## 3. Core Functional Module Specifications

### Module 1: Redesigned Top Header Bar
- **Description:** Fixed header with corporate logo placeholder (circular gray frame), main company title (`شرکت مس درآلو`), and a 2-line metadata display for time, Jalali/Gregorian date, and live weather status.
- **UI Components:**
  - Logo Spot: Circular gray avatar frame (`CircleAvatar` / `BoxShape.circle`).
  - Company Title: Bold header text (`شرکت مس درآلو`).
  - 2-Line Metadata:
    - Line 1: Real-time clock (`10:24`) & Weather status (`28°C - آفتابی`).
    - Line 2: Today's date (`شنبه ۱۸ مرداد ۱۴۰۵`).
- **Data Refresh:** Clock updates every second; Weather & Date update periodically.

### Module 2: Hero News Carousel
- **Description:** Dynamic, auto-advancing visual report carousel showcasing corporate achievements and facility announcements.
- **UI Components:**
  - Content Tag: High-energy pill badge (`گزارش تصویری`).
  - Title: Display typography (`بازدید هیئت مدیره از زیرساخت‌های جدید لابی`).
  - Pagination Indicators: Animated active dash indicators.

### Module 3: Exclusive Staff Leave Registration (ثبت مرخصی)
- **Description:** Card dedicated exclusively to staff leave requests (`ثبت مرخصی`), enabling quick submission and status tracking.
- **UI Components:**
  - Tag: `مرکز خدمات پرسنلی`.
  - Icon: Document / ID badge vector icon.
  - Title: `ثبت مرخصی`.
  - Subtitle/Description: `ثبت و پیگیری آنلاین درخواست‌های مرخصی ساعتی و روزانه`.
  - Primary CTA Button: Full-width vibrant orange button (`ثبت درخواست`).

### Module 4: LME Copper Price Ticker (قیمت مس LME)
- **Description:** Real-time global commodity ticker tracking London Metal Exchange (LME) copper prices.
- **UI Components:**
  - Header: `قیمت مس LME` with stock trend vector icon.
  - Live Price Display: Monospace formatted price string (`$9,450 / تن`).
  - 24-Hour Delta Badge: Highlighting daily movement (`+2.1% 24h`) in emerald green.

### Module 5: Sports Facility Reservation (رزرو ورزشی)
- **Description:** Self-service portal card allowing employees to reserve sports complex slots, gym sessions, and recreational facilities.
- **UI Components:**
  - Tag: `خدمات رفاهی`.
  - Title: `رزرو ورزشی`.
  - Subtitle: `رزرو نوبت‌های استخر، سالن ورزشی و زمین چمن`.
  - CTA Button: `رزرو نوبت`.

### Module 6: Latest News Card (آخرین اخبار)
- **Description:** Dynamic card replacing percentage stock tickers, presenting high-priority corporate news items and quick announcements.
- **UI Components:**
  - Tag: `اطلاعیه‌ها`.
  - Title: `آخرین اخبار`.
  - News Snippet: `برگزاری دوره آموزشی ایمنی و بهداشت صنعتی در سالن همایش`.
  - Action Link: `مشاهده همه اخبار`.

### Module 7: Facility Map (نقشه)
- **Description:** Quick-access map card for building layouts, emergency exits, and floor department directory.
- **UI Components:**
  - Icon: Blueprint / Location Map vector icon.
  - Title: `نقشه طبقات`.
  - Subtitle: `مسیریابی بخش‌ها و خروجی‌های اضطراری`.

### Module 8: Feedback & Suggestions (انتقادات و پیشنهادات)
- **Description:** Direct portal for staff and lobby visitors to submit anonymous or identified feedback and suggestions.
- **UI Components:**
  - Icon: Feedback / Speech bubble vector icon.
  - Title: `انتقادات و پیشنهادات`.
  - Subtitle: `ارسال نظرات جهت بهبود خدمات مجموعه`.

### Module 9: Restaurant Menu (منوی رستوران)
- **Description:** Daily cafeteria menu overview with food selection details.
- **UI Components:**
  - Icon: Fork and knife vector in accent orange.
  - Title: `منوی رستوران`.
  - Action Link: `مشاهده غذاهای امروز`.

### Module 10: Emergency & System Footer Ticker
- **Description:** Bottom-anchored continuous security protocol bar.
- **UI Components:**
  - Full-width dark red indicator bar.
  - Ticker Text: `وضعیت سیستم: فعال | پروتکل اضطراری فعال: با امنیت سایت داخلی ۹۱۱ تماس بگیرید`.

---

## 4. Non-Functional Requirements (NFR)

1. **Architecture Rule:** Feature-First directory layout. Every feature encapsulates `data/models`, `data/services`, `presentation/screens`, `presentation/widgets`, and `mock/`.
2. **Unified Networking:** All HTTP operations must pass through `CoreHttpClient` with Dio interceptors.
3. **Performance:** Maximum CPU utilization under 25% on embedded ARM architecture; zero memory leaks during 24/7 continuous uptime.
4. **Reliability & Resilience:** Automatic recovery from network dropouts. Default to local SQLite / JSON mock layer without displaying broken images or error dialogs.
