# UI Design System & Bento Grid Specification

## 1. Overview & Aesthetic Philosophy

The **Daralou Copper Kiosk UI Design System** is built specifically for high-impact portrait kiosk environments. Inspired by deep-space command centers and technical developer platforms, the visual design blends a dark charcoal backdrop with metallic copper accents, emerald performance highlights, and subtle glassmorphic depth.

---

## 2. Color Palette & Token Definitions

```dart
abstract class AppColors {
  // Base Surfaces (Tiered Grays)
  static const Color background = Color(0xFF121414);        // Level 0 Base Background
  static const Color surfaceDim = Color(0xFF121414);
  static const Color surfaceContainerLow = Color(0xFF1A1C1C); // Level 1 Card Container
  static const Color surfaceContainer = Color(0xFF1E2020);    // Level 1 Card Alternate
  static const Color surfaceContainerHigh = Color(0xFF292A2A); // Level 2 Card Highlight
  static const Color slateDark = Color(0xFF1E2028);
  static const Color logoCircleBackground = Color(0xFF383939); // Gray Circle Logo Placeholder

  // Primary Brand & Metallic Copper Accents
  static const Color primary = Color(0xFFF58232);           // High-Energy Orange Accent
  static const Color primaryFixed = Color(0xFFF37321);      // Metallic Copper Accent
  static const Color primaryContainer = Color(0xFFF58232);
  static const Color onPrimary = Color(0xFF522300);

  // Semantic Colors
  static const Color emeraldGreen = Color(0xFF219653);     // Success, Gain, Ticker positive
  static const Color errorRed = Color(0xFFFFB4AB);         // Error text
  static const Color errorContainer = Color(0xFF93000A);    // Emergency footer background

  // Typography & On-Surface Colors
  static const Color onSurface = Color(0xFFE3E2E2);        // Primary Text (Off-white)
  static const Color onSurfaceVariant = Color(0xFFDDC1B2); // Secondary Text (Muted warm)
  static const Color outline = Color(0xFFA58C7E);          // Active borders
  static const Color outlineVariant = Color(0x1AFFFFFF);   // Subtle 10% card border
}
```

---

## 3. Redesigned Bento Grid Layout Specification (1080 x 1920)

The interface is structured as a focused **Bento Grid** with 3 main columns and 4 vertical content rows, topped by a redesigned header and anchored by an emergency footer bar.

```
Total Screen Width: 1080px
Total Screen Height: 1920px
Outer Margins: 24px Left/Right/Top/Bottom
Grid Gutter: 16px horizontal and vertical

Header Section (Height: 120px):
- Right: Gray Circle Logo Placeholder (64x64 dp) + Company Title "شرکت مس درآلو"
- Left: 2-Line Metadata:
    Line 1: Clock "10:24" & Weather "28°C - آفتابی"
    Line 2: Jalali Date "شنبه ۱۸ مرداد ۱۴۰۵"

Content Rows Breakdown:
- Row 1 (Hero Carousel): 420px (Spans all 3 Columns)
- Row 2 (Staff Leave & LME Copper): 300px
    - Col 1 (2 units): Leave Registration Card ("ثبت مرخصی")
    - Col 2 (1 unit): LME Copper Price Ticker ("قیمت مس LME")
- Row 3 (Sports Reservation & Latest News): 340px
    - Col 1 (2 units): Sports Facility Reservation Card ("رزرو ورزشی")
    - Col 2 (1 unit): Latest Corporate News Card ("آخرین اخبار")
- Row 4 (Welfare Services Suite): 620px
    - Col 1 (1 unit): Facility & Floor Map Card ("نقشه طبقات")
    - Col 2 (1 unit): Feedback & Suggestions Card ("انتقادات و پیشنهادات")
    - Col 3 (1 unit): Restaurant Menu Card ("منوی رستوران")

Emergency Footer Bar (Height: 120px):
- Bottom-anchored security protocol & internal emergency extension broadcast.
```

---

## 4. Standard Component Styling Rules

### 1. Redesigned Header Component (`RedesignedHeader`)
- **Logo Placeholder:** Circular gray frame (`CircleAvatar`, diameter 56–64px, color `#383939`).
- **Company Title:** Bold header text using `Vazirmatn` Bold (24–28px).
- **2-Line Metadata Container:**
  - Top Line: `JetBrains Mono` for time (`10:24`), `Vazirmatn` for weather (`28°C - آفتابی`).
  - Bottom Line: `Vazirmatn` Medium (14px) for full Jalali date (`شنبه ۱۸ مرداد ۱۴۰۵`).

### 2. Bento Card Container (`BentoCard`)
- **Background:** `AppColors.surfaceContainerLow` (`#1A1C1C`) or `AppColors.slateDark` (`#1E2028`).
- **Border:** `1px` stroke with `AppColors.outlineVariant` (`0x1AFFFFFF`).
- **Corner Radius:** `16px` (`BorderRadius.circular(16)`).
- **Padding:** Internal padding `16px` to `20px`.

### 3. Primary CTA Button (`KioskPrimaryButton`)
- **Fill:** Solid Vibrant Orange `AppColors.primary` (`#F58232`).
- **Text Color:** Dark Brown / Black `AppColors.onPrimary` (`#522300`).
- **Typography:** `Vazirmatn` SemiBold 16px.
- **Height:** Minimum `56px` to ensure effortless touch trigger.
- **Corner Radius:** `12px`.
