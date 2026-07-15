---
name: TailTopia
description: Indonesian pet-care & community app — AI symptom triage, paid vet consultations, social feed, milestone tracking. Mono-violet identity, Poppins type for Bahasa Indonesia coverage, light + dark themes (vet-facing surfaces locked to light).
colors:
  brand-primary: '#845EC9'
  brand-primary-hover: '#6C48AE'
  brand-primary-active: '#563A8E'
  brand-secondary: '#9E83DA'
  brand-subtle: '#F8F6FF'
  bg-default: '#FEFEFE'
  bg-surface: '#FFFFFF'
  bg-subtle: '#F8F2FF'
  text-heading: '#2E2742'
  text-primary: '#544864'
  text-secondary: '#808080'
  text-tertiary: '#A7A7A7'
  text-disabled: '#B6B6B6'
  text-on-brand: '#FFFFFF'
  border-default: '#E6E6E6'
  border-strong: '#CCCCCC'
  border-brand: '#C2B0EC'
  border-focus: '#845EC9'
  status-success: '#1FB877'
  status-success-subtle: '#E7F8F0'
  status-success-text: '#0E7A4D'
  status-warning: '#F6A609'
  status-warning-subtle: '#FEF3DE'
  status-warning-text: '#8A5A00'
  status-error: '#F0425A'
  status-error-subtle: '#FDE7EB'
  status-error-text: '#C4263C'
  status-info: '#845EC9'
  status-info-subtle: '#F8F6FF'
  status-info-text: '#563A8E'
  accent-mint: '#5BCBBB'
  vet-header: '#2B2540'
  brand-primary-dark: '#845EC9'
  brand-primary-hover-dark: '#9E83DA'
  brand-primary-active-dark: '#6C48AE'
  bg-default-dark: '#0B0810'
  bg-surface-dark: '#2A2336'
  bg-subtle-dark: '#181220'
  text-primary-dark: '#F4EFFB'
  text-secondary-dark: '#C0B6D4'
  text-tertiary-dark: '#8B8299'
  text-disabled-dark: '#5A5468'
  text-on-brand-dark: '#FFFFFF'
  border-default-dark: '#2E2740'
  border-strong-dark: '#3D3458'
  border-brand-dark: '#9E83DA'
  border-focus-dark: '#C2B0EC'
typography:
  display:
    fontFamily: ['Poppins', 'system-ui', 'Segoe UI', 'Roboto', 'sans-serif']
    fontSize: 30px
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: ['Poppins', 'system-ui', 'Segoe UI', 'Roboto', 'sans-serif']
    fontSize: 24px
    fontWeight: 700
    lineHeight: 1.25
  title:
    fontFamily: ['Poppins', 'system-ui', '-apple-system', 'Roboto', 'Segoe UI', 'sans-serif']
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.3
  body:
    fontFamily: ['Poppins', 'system-ui', '-apple-system', 'Roboto', 'Segoe UI', 'sans-serif']
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.45
  label:
    fontFamily: ['Poppins', 'system-ui', '-apple-system', 'Roboto', 'Segoe UI', 'sans-serif']
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.4
  caption:
    fontFamily: ['Poppins', 'system-ui', '-apple-system', 'Roboto', 'Segoe UI', 'sans-serif']
    fontSize: 13px
    fontWeight: 400
    lineHeight: 1.4
  micro:
    fontFamily: ['Poppins', 'system-ui', '-apple-system', 'Roboto', 'Segoe UI', 'sans-serif']
    fontSize: 11px
    fontWeight: 400
    lineHeight: 1.3
rounded:
  sm: 6px
  md: 12px
  lg: 14px
  xl: 16px
  2xl: 20px
  3xl: 24px
  4xl: 32px
  full: 9999px
spacing:
  '0': 0
  '1': 4px
  '2': 8px
  '3': 12px
  '4': 16px
  '5': 20px
  '6': 24px
  '8': 32px
  '10': 40px
  '12': 48px
  '16': 64px
  '20': 80px
components:
  button-primary:
    radius: '{rounded.lg}'
    bg: '{colors.brand-primary}'
    text: '{colors.text-on-brand}'
    fontSize: '{typography.label.fontSize}'
    fontWeight: '{typography.label.fontWeight}'
    padding: '13px 24px'
    shadow: '0 6px 18px rgba(132,94,201,.28)'
    disabledBg: '{colors.text-disabled}'
  button-secondary:
    radius: '{rounded.lg}'
    bg: transparent
    border: '1.5px solid {colors.border-brand}'
    text: '{colors.brand-primary}'
  card:
    radius: '{rounded.xl}'
    bg: '{colors.bg-surface}'
    shadow: '0 4px 12px rgba(22,34,51,.06)'
  card-lg:
    radius: '{rounded.2xl}'
    bg: '{colors.bg-surface}'
    shadow: '0 6px 20px rgba(22,34,51,.08)'
  input:
    radius: '{rounded.md}'
    border: '1.5px solid {colors.border-default}'
    borderFocus: '1.5px solid {colors.accent-mint}'
    bg: '{colors.bg-surface}'
  chip:
    radius: '{rounded.full}'
    border: '1.5px solid {colors.border-default}'
    bgActive: '{colors.brand-primary}'
    textActive: '{colors.text-on-brand}'
  badge:
    radius: '{rounded.sm}'
    fontSize: '10px'
    fontWeight: 600
  sheet:
    radius: '{rounded.3xl} {rounded.3xl} 0 0'
    bg: '{colors.bg-surface}'
    scrim: 'rgba(14,10,20,.6)'
    transition: 'transform .32s cubic-bezier(.32,.72,0,1)'
  tabbar:
    radius: '{rounded.4xl} {rounded.4xl} 0 0'
    bg: '{colors.bg-surface}'
    height: '83px'
    shadow: '0 -4px 20px rgba(22,34,51,.08)'
status: confirmed
updated: 2026-07-10
---

# TailTopia — Design Spine

> Spine wins on conflict with any mock, wireframe, or import. Sources: `tokens.json` / `tokens.css` (authoritative token values), `V1.0.0/页面/preview-core-pages.html` (54-screen prototype, component patterns), `V1.0.0/页面/cs-contact-sheet.html` (bottom-sheet animation standard), `V1.0.0/页面/preview-new-splash-auth-0623.html` (splash mark, Apple Sign-In, account-deactivation pattern — colors recolored to brand-primary per decision log). Component CSS values below are distilled in [`mockups/preview-extraction.md`](mockups/preview-extraction.md); the Typography and Shapes scale choices were made against [`mockups/typography-comparison.html`](mockups/typography-comparison.html) and [`mockups/radius-comparison.html`](mockups/radius-comparison.html) (see `.decision-log.md` for the reasoning). Paired with `EXPERIENCE.md`.

## Brand & Style

TailTopia is a single mono-violet identity — one brand hue (`#845EC9`) carries the whole system, with no secondary hue competing for attention. The posture is warm-companion-meets-clinical-trust: social/content surfaces (feed, milestones, pet passport) read soft and rounded, while anything touching money, health, or a licensed professional (AI triage results, vet consultation, PawCoin, account deactivation) shifts to a more measured, high-contrast treatment without leaving the violet family.

Two deliberate signature moves carry the brand: the **Pop Art tab icon** (a red `#F0425A` shadow offset 3px behind the violet fill, like a mis-registered print) on the active bottom-tab icon, and the **dog + cat negative-space mark** that animates in on cold splash (a white silhouette runs across the screen and settles into a violet cutout). Both are brand-specific signatures — don't generalize the Pop Art treatment to other "active state" UI, and don't reuse the splash run animation outside the cold-start moment.

Vet-professional surfaces (`p-vet-*`) are a deliberate exception: they never follow the pet owner's light/dark preference and always render in a fixed light palette with a dedicated dark-purple header (`{colors.vet-header}`) — a professional, clinical surface that stays constant regardless of the consumer app's mode.

Indonesian-market requirement: Poppins covers Latin-Extended, used for 100% of UI text. No other typeface is part of the system (`Quicksand` appeared in one splash-tagline exploration but is not adopted — Poppins only).

**Build target: Flutter** (single codebase, iOS + Android). This system is a fully custom skin, not a Material/Cupertino reskin — so default to Flutter's standard declarative building blocks (`AnimatedContainer`/`AnimatedOpacity`/`Tween`-driven transitions, `showModalBottomSheet`, `BoxDecoration` for shadows/radius) to hit these specs quickly, rather than hand-rolling custom rendering. The one exception is the splash dog/cat run animation — its multi-waypoint path morph (see `EXPERIENCE.md` Interaction Primitives) is expensive to hand-build in Flutter widget code; **export it as a Lottie or Rive asset from the design tool and play it with the corresponding Flutter package**, don't reimplement the keyframes natively.

## Colors

The palette is built two-tier: **primitive** ramps (full violet/ink/grey/status scales, not exposed here — see `tokens.json` for the complete ramp) and the **semantic** roles below, which are what components actually reference.

- **`brand-primary` (`#845EC9`)** is the only brand hue in the system. Used for primary CTAs, active tab icon fill, links, focus rings, the tab-bar center FAB, and any "this is the app's signature color" moment. Hover/active states step down the same violet ramp (`brand-primary-hover` `#6C48AE`, `brand-primary-active` `#563A8E`) rather than introducing a new hue.
- **`brand-secondary` (`#9E83DA`)** is a lighter step of the same ramp — used for soft surfaces like the AI-consultation card gradient, never as a competing accent.
- **`bg-default` (`#FEFEFE`)** is the app canvas — one step off pure white, distinguishing it from `bg-surface` (`#FFFFFF`, pure white) used for cards and the tab bar sitting on top of it.
- **`bg-subtle` (`#F8F2FF`)** is the palest violet tint — chip backgrounds, stat-row fills, progress track, any "tinted zone" that needs to read as part of the brand without competing for attention.
- **`accent-mint` (`#5BCBBB`)** is reserved for two specific roles only: the online-status dot and vet-form input focus borders. It is intentionally hardcoded in implementation (never swapped via theme tokens) because it must stay legible against any card background, light or dark. Do not introduce mint elsewhere as a general accent.
- **Status colors** (`success`/`warning`/`error`/`info`) follow the standard tonal-chip pattern: a saturated value for icons/borders, a `-subtle` tint for chip backgrounds, and a `-text` value tuned for AA contrast on the subtle tint. `status-error` (`#F0425A`) doubles as the Pop Art tab-icon shadow color — same red, two different jobs (status communication vs. brand signature), never confuse the two in component specs.
- **Dark mode** is a parallel semantic remap (see `*-dark` tokens) — status colors are **intentionally not remapped**; they render as self-contained tonal chips that stay legible on dark surfaces without a separate dark variant. **Color values are finalized but dark mode has not actually shipped in any version yet** — treat the `*-dark` tokens as ready-to-build, not as confirmation the feature is live (tracked in `待讨论事项.md`). When it is built, map these directly to a Flutter `ColorScheme`/`ThemeMode.system` setup rather than per-widget conditionals.

Avoid: introducing a second brand hue (explored once at `#7D45F6` for a splash rebrand, explicitly rejected — see decision log), using `accent-mint` outside its two reserved roles, using raw primitive values in component specs instead of semantic tokens.

## Typography

Single typeface, Poppins, seven roles, aligned to the Flutter implementation's authoritative scale (`{typography.display.fontSize}` 30 / `{typography.headline.fontSize}` 24 / `{typography.title.fontSize}` 18 / `{typography.body.fontSize}` 15 / `{typography.label.fontSize}` 14 / `{typography.caption.fontSize}` 13 / `{typography.micro.fontSize}` 11). Updated 2026-07-01 from Flutter `typography.dart` as source of truth; previous design values were 28/20/—/16/14/12/— and are no longer valid. New work must target these token values exactly.

- `display` (30/700) — splash wordmark scale, hero headings like "Take Care Of Your Pet."
- `headline` (24/700) — primary section titles, dialog headings, onboarding step headings.
- `title` (18/600) — card headings, app-bar titles, doctor names.
- `body` (15/400) — standard body copy, banner text, feed content.
- `label` (14/500) — form labels, chips, secondary UI chrome.
- `caption` (13/400) — timestamps, ratings, descriptions under a card header.
- `micro` (11/400) — badge text, the smallest legible tier. Tab labels use 9px but are outside the standard role scale.

## Layout & Spacing

Scale: 0/4/8/12/16/20/24/32/40/48/64/80px (`{spacing.0}`–`{spacing.20}`). `{spacing.5}` (20px) is the standard screen-edge gutter — nearly every page margin and card inset in the prototype lands on 20px. `{spacing.4}` (16px) is the default internal padding for medium surfaces; `{spacing.3}` (12px) for compact rows (form fields, list entries).

Single-column mobile layout throughout — see `EXPERIENCE.md` Foundation for form-factor. Bottom sheets stack one level deep in the base pattern; the account-deactivation flow is the one sanctioned two-step exception (sheet → sheet), not a precedent for general two-deep stacking.

## Elevation & Depth

Shadows are soft and cool-toned (`rgba(22,34,51,*)`, not pure black) for neutral surfaces, with a dedicated warm violet-toned shadow (`rgba(132,94,201,*)`) reserved for brand-colored elements (primary buttons, the tab-bar FAB, brand-tinted cards).

- `sm` — `0 2-4px 8-12px rgba(22,34,51,.05-.08)` — small entries, timeline rows, compact cards.
- `md` — `0 6px 20px rgba(22,34,51,.08)` — standard and large cards (pet passport, consultation cards).
- `lg` — `0 20px 40px rgba(22,34,51,.16)` — sheets, large overlays.
- `brand` — `0 6-8px 18-20px rgba(132,94,201,.28-.30)` — primary CTAs, the tab-bar FAB, anything that needs to read as "the brand action" via glow rather than just color.

Sheets carry an additional inverted top-edge shadow (`0 -8px 40px rgba(0,0,0,.18)`) to read as floating above the content behind the scrim.

## Shapes

Radius is **not** forced onto a single abstract scale — it follows the actual measured values already shipping across the prototype, named by role rather than forced to round numbers:

- `{rounded.sm}` (6px) — badges, small status tags.
- `{rounded.md}` (12px) — form inputs, compact entries (timeline rows, health-alert entries, milestone bars).
- `{rounded.lg}` (14px) — **signature button radius** — primary/secondary buttons, the chip-style CTA family.
- `{rounded.xl}` (16px) — standard content cards.
- `{rounded.2xl}` (20px) — large cards: pet passport card, AI/vet consultation entry cards.
- `{rounded.3xl}` (24px) — bottom-sheet top corners.
- `{rounded.4xl}` (32px) — tab bar top corners.
- `{rounded.full}` — pills, chips, avatars, all circular elements (FAB, online-status dot, tab-bar center button).

Imagery (photo placeholders, avatar fills) follows its container's corner radius exactly — never a separate inner radius.

## Components

- **Primary button** (`{components.button-primary}`) — `{rounded.lg}`, `{colors.brand-primary}` fill, white text, brand-toned shadow. Disabled state drops to `{colors.text-disabled}` fill, no shadow, `cursor:not-allowed`. The countdown-gated variant (used once, on the red AI-result acknowledgment) starts disabled at `opacity:.55` and auto-enables after a fixed dwell timer — see `EXPERIENCE.md` for when this pattern applies.
- **Secondary button** (`{components.button-secondary}`) — transparent fill, `{rounded.lg}`, brand-colored 1.5px border and text. Used for "View profile"/"Cancel"-tier actions that shouldn't compete with a primary CTA on the same screen.
- **Card** (`{components.card}`) / **Card, large** (`{components.card-lg}`) — surface-on-canvas pattern, no border, soft shadow does the separation work. Large variant is for hero-tier content (pet passport, consultation entry points); standard variant for feed/list content.
- **Chip / filter tag** (`{components.chip}`) — pill-shaped, outlined by default, fills solid brand-primary with white text when active. Used for category filters and type selectors — never for status communication (that's badges).
- **Badge** — small rectangular tag, `{rounded.sm}`, always a tonal pair (tint background + matching saturated/text-tuned foreground) — story/happy-moment/health-tip categories each get their own tonal pair, not a single generic badge color.
- **Form input** (`{components.input}`) — `{rounded.md}`, neutral border by default, switches to `{colors.accent-mint}` border on focus (vet-form convention; extend this focus treatment to consumer-facing forms too — the static prototype didn't show an explicit focus state outside vet forms, but the mint-border convention should be the system-wide standard going forward).
- **Bottom sheet** (`{components.sheet}`) — **canonical pattern, supersedes the prototype's one-shot `animation:slideUp`**: scrim `rgba(14,10,20,.6)` fades in, sheet content slides via `transform:translateY(100%→0)` with `transition: transform .32s cubic-bezier(.32,.72,0,1)` — both opening *and* closing are animated (the closing slide-down was missing from the original prototype and is now standard). Toggled via a `.open`/`.show` class, not inline `display` flips. Handle bar: 36×4px, `{colors.border-default}`, `{rounded.full}`, centered, 18px bottom margin before content starts.
- **Tab bar** (`{components.tabbar}`) — fixed bottom, `{rounded.4xl}` top corners, center FAB pokes above the bar (`margin-top:-14px`). Active icon uses the Pop Art 3-layer effect (see Brand & Style); label switches to `{colors.brand-primary}` + 600 weight on active.
- **Avatar** — circular (`{rounded.full}`), two sizes (small 34px for lists/rows, large 62px for profile headers), solid-color or gradient fill with initials/emoji.
- **Online-status dot** — `{colors.accent-mint}` fill, **always a hardcoded white 2px border** (never a token) so it stays legible on any card background.

### V1.1.0 components

- **Recharge tier card** — exactly 4 cards in a fixed grid, each `{components.card}` (`{rounded.xl}`, `{colors.bg-surface}`). Selected state: `{colors.border-brand}` 1.5px border + `{colors.bg-subtle}` fill, no separate "selected" color invented. No custom-amount input anywhere in this surface.
- **PawCoin ledger row** — flat list row (no card shell), `{spacing.3}` vertical padding, `{colors.border-default}` 1px bottom divider between rows. Amount text colored by sign: `{colors.status-success-text}` for credits (+), `{colors.text-primary}` for debits (−, never `status-error` — a normal spend isn't an error state). Non-interactive — no tap affordance, no chevron, since rows are immutable history (see `EXPERIENCE.md`).
- **Refund choice sheet** — inherits `{components.sheet}`. Two full-width option rows stacked (not side-by-side, unlike the paywall sheet), each styled as `{components.button-secondary}` at rest; once one path is chosen, the unchosen option is removed from view rather than disabled-grayed (avoids an ambiguous disabled state on a financial choice). Only ever presented after a CS ticket is approved — see `EXPERIENCE.md`.
- **Order status banner** (待接单 / 待支付 / 退款处理中) — inline banner card, `{rounded.md}`, persists at the top of the order detail view, never a dismissible toast. Three tonal variants, none of them `status-error` since none are failure states: 待接单 and 待支付 use `{colors.status-warning-subtle}` fill + `{colors.status-warning}` accent (待支付 additionally shows a live countdown); 退款处理中·审核中 uses `{colors.status-info-subtle}`/`{colors.status-info}` (CS hasn't decided); 退款处理中·待选方式 uses `{colors.status-success-subtle}`/`{colors.status-success}` (CS approved, action available). Supersedes the deprecated prepay-model's single-purpose "已暂停 banner" — that state no longer exists.
- **Order card, 4 types** — 兽医咨询 / PawCoin 充值 / AI 解锁 / 身份证高清图 (FR-54A–D) share one `{components.card}` shell, differentiated by a 3px top-edge gradient bar, never by color alone (type is read from icon + label text): amber→gold (`#F6A609`→`#FFD166`) for anything awaiting action (待接单/待支付); green (`{colors.status-success}`→`{colors.accent-mint}`) for completed/already-credited outcomes (已完成/已到账/已解锁/已购买); blue (`#0369A1`→`#2196C9`) for anything refund-related (审核中/待选方式/已退款).
- **Vet active-session row** (`p-vet-active`) — list row, same shell rhythm as the vet queue card (avatar chip + patient name/species + elapsed time), but exactly one action, "Lanjutkan Chat," styled as full-width `{components.button-secondary}` — resuming a paid session isn't a new commitment the way accepting a case is, so it doesn't compete visually with the queue's primary accept action. Empty state is a plain centered caption, no illustration.
- **Health record row** — list row pattern matching the PawCoin ledger row's divider/spacing convention, with a leading `{rounded.md}` icon chip (`{colors.bg-subtle}` background) keyed to record type (vaccine/deworming/etc.). Text-only — no image thumbnail slot in V1.1.0.
- ~~Monthly recap card~~ — removed 2026-07-10: this feature (原 FR-46 系列) was pulled from V1.1.0 scope 2026-07-08 (PRD §3.3), version TBD. **2026-07-11: the prototype (`p-recap` + 12-theme skin work in `preview-v1.1.0-new-pages.html`) has been deleted, not kept for reuse** — don't point future work at that file expecting to find it.
- **Starter task item** — list row, leading circular checkbox (`{rounded.full}`, unchecked: `{colors.border-default}` outline; checked: `{colors.brand-primary}` fill + checkmark). Completing a task triggers the existing S-tier celebration sheet, not a new visual treatment on the row itself beyond the checkbox state flip.
- **Pet ID card paywall** — the free preview renders at full layout fidelity with a visible watermark overlay (diagonal, low-opacity wordmark) and reduced resolution — never a blur/blackout treatment, since the point is "lower quality," not "hidden." The unlock CTA is `{components.button-primary}` overlaid at the bottom edge of the preview, not a separate sheet.
- **Account-deactivation two-step sheet** — inherits `{components.sheet}`. Icon chip uses the danger variant (`{colors.status-error-subtle}` background, `{colors.status-error}` icon), matching the logout/delete-post sheets' neutral/danger pattern rather than inventing a third icon treatment. **Cancel/Batal is always present at both steps and matches the primary action's tap-target size and visual weight** — never shrunk to a text-only link beneath a full-width destructive button.

## Do's and Don'ts

| Do | Don't |
| --- | --- |
| One brand hue (`{colors.brand-primary}`) for every "this is the app" moment | Introduce a second brand hue for splash/auth screens (rejected exploration — see decision log) |
| Animate both the open *and* close of every bottom sheet (`{components.sheet}` transition) | Ship a sheet that slides up but disappears instantly on close |
| Keep `accent-mint` scoped to online-status dots and vet-form focus borders | Use mint as a general-purpose accent or status color |
| Keep switch-knob and online-status-dot borders hardcoded white | Swap them to a theme token — they must stay legible regardless of light/dark mode |
| Lock all `p-vet-*` surfaces to the fixed light palette + `{colors.vet-header}` | Let vet-facing screens follow the pet owner's dark-mode preference |
| Use the Pop Art shadow-offset effect only on the active bottom-tab icon | Generalize Pop Art to other "active" states elsewhere in the app |
| Gate genuinely irreversible actions (account deactivation) behind a two-step sheet (explain → type-to-confirm) | Use the two-step type-to-confirm pattern for routine confirmations (logout, normal deletes use the single neutral/danger sheet) |
| Show Apple Sign-In peer-level with and above Google on iOS, hide entirely on Android | Treat Apple Sign-In as a subordinate/secondary option to Google on iOS (App Store Guideline 4.8) |
| Build standard shapes/shadows/sheets with Flutter's built-in widgets (`BoxDecoration`, `showModalBottomSheet`, `Tween`/`Animation`) | Hand-roll a `CustomPainter` for anything a standard widget already achieves |
| Export the splash dog/cat run animation as a Lottie/Rive asset | Hand-code the multi-waypoint path-morph animation natively in Flutter |
| Treat PawCoin as strictly non-transferable between user accounts — top-up and spend only | Add any UI affordance for sending/gifting PawCoin to another user without legal review first (regulatory boundary, not a product preference — see decision log / PRD FR-50D) |
