---
name: Amber Tech Narrative
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#383939'
  surface-container-lowest: '#0d0e0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#292a2a'
  surface-container-highest: '#343535'
  on-surface: '#e3e2e2'
  on-surface-variant: '#ddc1b2'
  inverse-surface: '#e3e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#a58c7e'
  outline-variant: '#564337'
  surface-tint: '#ffb68c'
  primary: '#ffb68c'
  on-primary: '#522300'
  primary-container: '#f58232'
  on-primary-container: '#5e2800'
  inverse-primary: '#9a4600'
  secondary: '#c8c6c5'
  on-secondary: '#303030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#c8c6c6'
  on-tertiary: '#303030'
  tertiary-container: '#a2a1a1'
  on-tertiary-container: '#383838'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdbc9'
  primary-fixed-dim: '#ffb68c'
  on-primary-fixed: '#321200'
  on-primary-fixed-variant: '#753400'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1b1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e4e2e1'
  tertiary-fixed-dim: '#c8c6c6'
  on-tertiary-fixed: '#1b1c1c'
  on-tertiary-fixed-variant: '#474747'
  background: '#121414'
  on-background: '#e3e2e2'
  surface-variant: '#343535'
typography:
  headline-lg:
    fontFamily: Geist
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Geist
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Geist
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Geist
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  gutter: 16px
  margin-mobile: 16px
  margin-desktop: 32px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

This design system is built for high-performance developer tools and technical platforms. The personality is precise, functional, and energetic, balancing a deep-space dark aesthetic with high-visibility technical accents. 

The style utilizes a **Modern Minimalist** foundation with **Glassmorphic** overlays to establish hierarchy without heavy shadows. It prioritizes data density and legibility, using sharp contrast to guide the user's eye through complex information architectures. The emotional response is one of reliability and "pro-level" control, evoking the feeling of a sophisticated terminal or command center.

## Colors

The palette is centered on a dark-mode-first philosophy. The primary color, **#F58232**, is a high-energy orange that serves as the singular brand anchor and primary action color. It replaces all copper-toned accents to provide a more vibrant, modern technical feel.

- **Primary (#F58232):** Used for primary calls-to-action, active states, progress indicators, and critical highlights.
- **Surface Scale:** Uses a series of tiered grays (Secondary and Tertiary) to create depth.
- **Text:** High-contrast off-whites for content, with the neutral hex used for metadata and disabled states.
- **Accents:** Semantic colors (error, success) should be desaturated to ensure the primary orange remains the dominant focal point.

## Typography

The typography system uses a dual-font approach to emphasize the technical nature of the product. **Geist** provides a clean, modern, and highly legible sans-serif face for all primary interface elements and content. **JetBrains Mono** is utilized for labels, data points, and code snippets to reinforce the developer-centric aesthetic.

Headlines use a tighter letter-spacing and heavier weights to create a strong visual anchor. Labels are set in all-caps when using JetBrains Mono to improve scanability at small sizes.

## Layout & Spacing

The design system employs a **Fluid Grid** model based on an 8px square system, with a 4px sub-grid for fine-tuned component internal spacing. 

- **Desktop:** 12-column grid with 16px gutters and 32px outer margins.
- **Tablet:** 8-column grid with 16px gutters and 24px outer margins.
- **Mobile:** 4-column grid with 12px gutters and 16px outer margins.

Vertical rhythm is maintained through standardized "stack" variables, ensuring consistent breathing room between logical sections.

## Elevation & Depth

In this dark-themed environment, depth is communicated through **Tonal Layers** and **Backdrop Blurs** rather than traditional drop shadows.

1.  **Level 0 (Base):** The darkest surface, used for the main application background.
2.  **Level 1 (Surface):** A slightly lighter gray for cards and containers.
3.  **Level 2 (Overlay):** Used for modals and floating menus, featuring a 12px backdrop blur and a subtle 1px border (#FFFFFF10) to define edges against the dark background.

Interactive elements use the primary orange color as a glow effect (outer stroke or low-opacity shadow) only when in a "focused" or "active" state.

## Shapes

The shape language is "Soft-Technical." By using a **0.25rem (4px)** base roundedness, the UI maintains a structured, efficient look that avoids the playfulness of larger radii while remaining more approachable than sharp corners. 

- **Buttons & Inputs:** Use the base 4px radius.
- **Large Cards:** Use the `rounded-lg` (8px) radius.
- **Search Bars:** May use `rounded-xl` (12px) if a more distinct separation from the grid is required.

## Components

### Buttons
- **Primary:** Solid #F58232 fill with black text. No gradient.
- **Secondary:** Transparent fill with #F58232 1px border and text.
- **Ghost:** Transparent fill, neutral text, appearing with a subtle gray background on hover.

### Input Fields
- Dark backgrounds (#1E1E1E) with a 1px border. The border transitions to #F58232 upon focus. Labels use the JetBrains Mono label-sm style.

### Chips/Tags
- Small, 4px rounded containers. For "active" filters, use a low-opacity #F58232 background with solid #F58232 text.

### Cards
- Background set to Level 1 surface. Borders are optional but should be low-contrast (#FFFFFF08) if used. 

### Data Tables
- Header rows use JetBrains Mono. Row separators use 1px lines in #FFFFFF08. Active or selected rows should use a subtle left-edge highlight in #F58232.