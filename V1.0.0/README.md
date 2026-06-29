# TailTopia · Design Tokens (V1.0.0, BMAD Phase 1)

The adopted token set driving the TailTopia app, extracted from the Figma file
**“Vet Care – veterinary care app UI (Community)”** (`YU083N0uVpVVTS6k4rVxB2`, light mode, mobile 430 px).

This superseded the earlier blue "Paw Buddy" working name/theme during the TailTopia rebrand;
that older blue token set no longer exists in this project. All pages under `页面/` import this
file directly (`../tokens.css`).

| File | Role |
|------|------|
| `tokens.json` | W3C DTCG **source of truth** (two-tier: `color.primitive.*` + semantic refs) |
| `tokens.css`  | CSS custom properties — primitives + semantic (light) + **dark** remap |
| `preview.html`| Open in a browser to eyeball the palette, type scale, radii & shadows |

Provenance tags throughout: **`[F]`** read directly from Figma · **`[d]`** derived/scaled from a
Figma anchor · **`[p]`/proposed** added to satisfy the BMAD checklist (no value in the static mockup).

---

## The design at a glance

- **Mono-violet brand.** Primary `#845EC9` (Log In button, active category — softened from the
  original Figma `#7D16FF` on 2026-06-15). Soft companion `#9E83DA` (cards), light `#C2B0EC`
  (borders/circles), tint `#F8F2FF` (canvas). No second hue.
- **Plum ink for text** `#544864` (headings + primary body), over a neutral *“Neuturals”* grey
  ramp (`#343434 / #808080 / #A7A7A7 / #B6B6B6`).
- **Poppins everywhere** — Regular 400 / Medium 500 / SemiBold 600 / Bold 700.
- **Signature radius 12 px** on buttons & inputs; 16 px on cards; 28–32 px on the glass login
  card and bottom nav. Soft navy shadow (`shadow/medium` = `rgba(22,34,51,.08)`).

## The four BMAD token categories (§1.1)

| # | Category | Coverage |
|---|----------|----------|
| ① | **Color** | brand primary/secondary, bg default/surface/subtle/brand, text primary→disabled, borders, status success/warning/error/info, **+ dark mode** |
| ② | **Typography** | `font.display` & `font.body` (Poppins), 8-step size scale (12→34 px), weights 400–700, 4 line-heights, 3 tracking steps |
| ③ | **Spacing & sizing** | 4 px-based `space.0→20`, `radius.sm→full`, `border.width.thin/thick` |
| ④ | **Effects & motion** | `shadow.sm/md/lg/brand`, `duration.fast/normal/slow`, `easing.default/enter/exit` |

## §1.3 Phase-1 exit checklist

- ✅ Primary color defined — `--color-brand-primary` = `#845EC9`; secondary = `#9E83DA`.
- ✅ Body font defined — Poppins (covers **Latin-Extended**, so Bahasa Indonesia renders cleanly).
- ✅ Size scale defined — 8 steps (≥ 5 required).
- ✅ Spacing system defined — 4 px base.
- ✅ `tokens.css` created — importable & AI-referenceable; `tokens.json` is the mirror.
- ✅ Dark-mode values provided (Indonesia-market note).

## Usage

```css
/* pages under 页面/ import this file directly */
@import '../tokens.css';
```

```css
.btn-primary {
  background: var(--color-brand-primary);
  color: var(--color-text-on-brand);
  border-radius: var(--radius-lg);          /* 12px signature */
  font: var(--font-weight-semibold) var(--text-sm)/1 var(--font-body);
  box-shadow: var(--shadow-brand);
  transition: background var(--duration-normal) var(--easing-default);
}
.btn-primary:hover { background: var(--color-brand-primary-hover); }
```

Dark mode: set `<html data-theme="dark">` (or rely on the `prefers-color-scheme` fallback).

> **AI prompt header (BMAD §1.2):** *“Use the following Design Tokens to generate the UI. Do not
> hard-code any color, font size, or spacing — reference variable names only. `@import
> tokens.css`.”*

## Token labels vs the BMAD reference ladder

Sizes/radii are **Figma-faithful**, so a few token *names* sit at different px than the suggested
BMAD §1.1 ladder. Same values, offset labels — noted so nobody matches names 1:1 and is surprised:

- **fontSize:** spec `lg=20` lives at our **`xl`**; our `lg=18`/`2xl=24` are Figma in-betweens; top
  step is `4xl=34` (no 36px). `13px` category labels round into `sm=14`.
- **radius:** spec `lg=16` lives at our **`xl`**; our **`lg=12`** is the Figma *signature* button radius.
- **lineHeight:** `normal=1.5` (Figma body 16/24); the spec's `1.6` is exposed as **`relaxed`**.

## Accessibility — full contrast disclosure (WCAG 2.1, verified)

Recomputed 2026-06-23 against the current softened palette (`#845EC9` primary, see "softened
2026-06-15" note above) — the prior table here still cited pre-softening hex values and stale
ratios. Most pairings pass AA; the ones that don't are **faithful to the Figma source** and are
listed here so you use them correctly. Targets: normal text **4.5:1**, large/bold text & UI **3:1**.

| Pairing | Ratio | Verdict | Guidance |
|---------|------:|---------|----------|
| text-primary (`#544864`) on bg-default/surface | 8.37 | ✅ AA | default body & headings |
| white on **brand-primary** (`#845EC9`) — buttons | 4.75 | ✅ AA (tight margin) | primary CTA, any size — closer to the 4.5:1 floor than before softening, don't darken further |
| link (`#845EC9`) on bg-default | 4.70 | ✅ AA (tight margin) | — |
| info-text (`#563A8E`) / success / warning / error **-text** on their `-subtle` | 4.8–8.2 | ✅ AA | use `--color-*-text` for badge labels |
| white on **brand-secondary** (`#9E83DA`, violet-400 cards) | 3.13 | ⚠️ large-only, barely | **≥18.66px bold / ≥24px or icons only** (matches Figma card labels); for small text use brand-primary. Only 0.13 above the 3:1 floor — flag for design review if this pairing gets reused elsewhere |
| **text-secondary** (`#808080`) on light bg | 3.95 | ⚠️ large-only | for small AA body, override to `var(--grey-700)` `#545454` (7.57:1) |
| **text-tertiary** (`#A7A7A7`) on light bg | 2.41 | ⛔ < 3:1 | **placeholder / timestamp / hint only — never content.** Need readable tertiary text? use `--grey-700` |
| **border-brand** (`#C2B0EC`, violet-300) on bg-default | 1.94 | ⛔ < 3:1 | **decorative borders only**, more so than before softening. Sole-indicator/interactive bounds → `--color-border-focus` (violet-500, 4.70:1, passes) |

**Dark theme:** brand-primary is held at violet-500 so white CTA text stays **4.75:1**; text-primary
**18.75:1**, text-secondary **13.29:1**, link (violet-300) **10.14:1** — all AA. Status chips stay
tonal (own bg + AA text) and remain legible on dark. To keep small **secondary/tertiary** text
AA-safe by default across the app, remap `--color-text-secondary` → `--grey-700` and
`--color-text-tertiary` → `--grey-700`.
