# preview-core-pages.html — Component & Interaction Extraction (subagent report, 2026-06-30)

Source: `Pet Project/TailTopia/V1.0.0/页面/preview-core-pages.html` (4312 lines, 54 pages). Raw subagent findings — feeds DESIGN.md Components + EXPERIENCE.md Component/Interaction Patterns at Finalize distillation. See `.decision-log.md` for the typography/radius discrepancy this report surfaced against `tokens.json`.

## 1. Component inventory

### Buttons
| Component | Class | Key CSS | States | Lines |
|---|---|---|---|---|
| Primary | inline | padding 13-14px 24-32px; bg #845EC9; radius 14px; font 14px/700; color #fff; shadow 0 6px 18px rgba(132,94,201,.28) | default/disabled(.off) | 151-152, 3954 |
| Secondary (outline) | inline | padding 6-14px; border 1.5px #C2B0EC; transparent bg; radius 8-9px; color #845EC9; font 12-14px/600 | default/hover | 365-368, 130 |
| Icon button | `.ibtn` | 38×38px; radius 11px; bg surface; shadow 0 2px 8px rgba(22,34,51,.07) | default/active(scale .92) | 54-55, 30 |
| Tab button | `.tab` | flex:1; gap 3px; padding 4px 2px | default/active(.on, Pop Art effect) | 29-42 |
| Tab plus (FAB in bar) | `.tabplus .plusinner` | 56×56px; radius full; bg #845EC9; shadow 0 8px 20px rgba(132,94,201,.30); margin-top -14px | default/active(scale .93) | 45-47 |
| FAB (share float) | inline | 54×54px; radius full; gradient(145deg,#9E83DA,#845EC9,#6C48AE); multi-layer shadow | default/active(scale .93) | 3962-3965 |
| Disabled | `.pubbtn.off` | bg #B6B6B6; no shadow; cursor not-allowed; opacity .55 | disabled | 152 |
| Countdown button | `#btn-red-ok` | opacity .55→1 after countdown, transition .3s | disabled→enabled | 3550, 3557 |

### Cards & surfaces
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| Feed/content card | `.card` | margin 0 20px 10px; bg surface; radius 16px; shadow 0 4px 12px rgba(22,34,51,.06) | 60, 2298-3309 |
| Pet passport card | `.petcard` | margin 0 20px 14px; radius 20px; padding 18px; shadow 0 6px 20px rgba(22,34,51,.08) | 77 |
| Consultation card (AI) | `.kcard-ai` | radius 20px; padding 18px; gradient(135deg,#845EC9,#9E83DA) | 109 |
| Consultation card (vet) | `.kcard-vet` | bg surface; border 1.5px #E6E6E6; shadow 0 6px 20px | 110 |
| Mini profile card | `.petmini` | flex; gap 11px; bg #F8F6FF; radius 13px; padding 11px | 131 |
| Timeline entry | `.tentry` | margin 0 20px 9px; bg surface; radius 13px; padding 11px; shadow 0 2px 8px | 93 |
| Health alert entry | `.hentry` | bg #FDE7EB; radius 12px; padding 10px 13px | 99 |

### Badges & tags
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| Badge base | `.badge` | padding 3px 8px; radius 6px; font 10px/600 | 68 |
| Story badge | `.b-story` | bg #F8F6FF; color #845EC9 | 69 |
| Happy-moment badge | `.b-happy` | bg #E7F8F0; color #0E7A4D | 70 |
| Health-tip badge | `.b-tips` | bg #FEF3DE; color #8A5A00 | 71 |
| Filter chip | `.chip` | padding 6px 13px; radius full; font 12px; border 1.5px #E6E6E6; bg surface | default/active(.on, #845EC9 bg) — 58-59 |
| Type chip | `.tchip` | padding 7px 13px; radius full; font 12px/600; border 1.5px #E6E6E6 | default/active(.on) — 155-156 |
| Health status badge | inline | padding 4px 8px; bg #F0425A; color #fff; radius 7px; font 10px/700 | 102 |
| Major milestone badge | inline | bg #845EC9; border 2px #141019; radius full; padding 3px 12px; font 10px/700 | 2371 |

### Avatar & identity
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| Avatar small | `.av` | 34×34px; radius full; font 13px/700; color #fff | 63 |
| Avatar large | `.avlg` | 62×62px; radius full; font 26px | 64 |
| Online status dot | inline | 8-11px; radius full; bg #5BCBBB; **border 2px #fff (hardcoded, never token)** | 1563, 3182 |
| Vet status indicator | inline | 8px; radius full; bg #5BCBBB; no border | 2262 |
| Notification red dot | inline | 8px; bg #F0425A; border 2px var(--color-bg-surface); radius full | 4014 |

### Form inputs
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| Textarea wrapper | `.textarea-wrap` | margin 0 20px 11px; bg surface; border 1.5px #E6E6E6; radius 11px; padding 11px | 167 |
| Fake textarea (placeholder) | `.fake-ta` | font 13px; color tertiary; min-height 70px; line-height 1.6 | 168 |
| Char counter | `.charcount` | text-align right; font 11px; color tertiary | 169 |
| Date row | `.daterow` | flex; gap 7px; padding 9px 0; border-top 1px #E6E6E6 | 170-173 |
| Radio (form) | inline | accent-color #845EC9 | 1005 |
| Input field (vet form) | inline | border 1.5px #5BCBBB(active)/#E6E6E6(default); radius 11-12px; padding 11-12px 13-14px | 3658-3688 |
| Select dropdown (vet) | inline | border 1.5px #E6E6E6; radius 11px; padding 11px 13px; flex space-between | 3683 |

### Navigation
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| App bar | `.appbar` | flex space-between; padding 8px 20px 12px | 52 |
| App bar title | `.appbar-title` | font 19px/700; color primary | 53 |
| Nav button (internal dev nav) | `.navbtn` | padding 3px 9px; bg #F8F6FF; radius 6px; font 10px/600; color #845EC9 | default/hover/.cur — 244-245 |

### Progress & stats
| Component | Class | Key CSS | Lines |
|---|---|---|---|
| Progress track | `.track` | height 5px; bg subtle; radius full; overflow hidden | 91 |
| Progress fill | `.fill` | height 100%; bg #845EC9; radius full | 92 |
| Milestone bar | `.msbar` | margin 0 20px 11px; bg surface; radius 12px; padding 11px 15px; shadow 0 2px 8px | 87 |
| Stats row | `.statsrow` | flex; bg subtle; radius 12px; overflow hidden | 82 |
| Stat column | `.statcol` | flex:1; padding 10px 8px; text-center; border-left 1px #E6E6E6 (except first) | 83-84 |

### Shadows observed in the wild
| Shadow | Usage |
|---|---|
| `0 2px 8px rgba(22,34,51,.05)` | small entries |
| `0 2px 10px rgba(22,34,51,.08)` | cards, small containers |
| `0 4px 12px rgba(22,34,51,.06)` | standard cards |
| `0 6px 20px rgba(22,34,51,.08)` | larger cards (pet, consult) |
| `0 8px 20px rgba(132,94,201,.30)` | primary CTA buttons, overlays |
| `0 4px 16px rgba(0,0,0,.22)` | FAB (large depth) |
| `0 -8px 40px rgba(0,0,0,.18)` | bottom sheets (top-edge shadow) |

## 2. Bottom sheet / drawer pattern (confirmed + extended)

Container (consistent across all 8+ sheet instances):
```
display:none; position:absolute; inset:0; background:rgba(14,10,20,.6); z-index:998;
align-items:flex-end; overflow:hidden; touch-action:none;
onclick="if(event.target===this)this.style.display='none'"
onwheel/ontouchmove="if(event.target===this)event.preventDefault()"
```
Content box: `bg surface; radius 24px 24px 0 0; width:100%; padding:20px 22px 36-40px; animation:slideUp .25s ease-out` (one variant uses `cubic-bezier(0,0,.2,1)` instead — `profil-edit-sheet`). Handle bar: `36×4px; bg #E6E6E6; radius full; margin:0 auto 18px`.

Sheet instances: `feed-longpress-sheet`, `mini-profile-sheet`, `detail-more-sheet`, `report-type-sheet`, `delete-confirm-sheet` (all in p-detail), `paspor-share-sheet`, `profil-edit-sheet`. Plus two full-page-as-sheet patterns using `flex; justify-content:flex-end`: `p-vet-status-popup`, `p-milestone-sheet`.

Confirms prior memory note: sheets use `position:absolute` (not `fixed`) + `animation:slideUp .25s`.

## 3. Page container pattern

```css
.page{position:absolute;inset:0;overflow-y:auto;overflow-x:hidden;display:none;padding-bottom:4px;background:var(--color-bg-default)}
.page::-webkit-scrollbar{display:none}
.page.on{display:block}
```
Toggle via JS: remove `.on` from all, add to target, `scrollTop=0`.

Flex-layout pages (`display:flex` instead of block when `.on`): `p-ai-result-red`, `p-vet-final-diagnosis`, `p-vet-status-popup`, `p-milestone-sheet`, `p-vet-chat`, `p-vet-profile`, `p-chat`.

`data-notab="true"` hides both tab bar and home bar — used on ~40 of the 54 pages (all single-purpose/modal-style flows; full list in JS toggle logic).

`data-theme="light"` lock — overrides ~24 CSS variables to permanent light values, applied to all `p-vet-*` pages (vet-dashboard, vet-login, vet-queue, vet-case, vet-case-direct, vet-chat, vet-history, vet-profile, vet-final-diagnosis, vet-status-popup) — vet professional surfaces never follow the pet-owner's dark-mode preference.

## 4. Tab bar / navigation pattern

`.tabbar`: height 83px; bg surface; radius 32px 32px 0 0; shadow 0 -4px 20px rgba(22,34,51,.08); flex; z-index 10.

`.tab`: flex:1, column, gap 3px, padding 4px 2px; `:active{scale(.92)}`.

Icon stack — 3-layer SVG "Pop Art" effect: `ishadow` (red #F0425A offset +3px/+3px, opacity 0→1 on active), `iout` (outline, opacity 1→0 on active), `ifill` (violet fill, opacity 0→1 on active). 150ms ease-out, opacity-only transition.

Label: inactive 10px/500/tertiary; active 10px/600/`#845EC9`.

`.tabplus` (center FAB-in-bar): 56×56px circle, `#845EC9`, `margin-top:-14px` (pokes above the bar), `:active{scale(.93)}`.

`tabMap` (JS) — maps non-tab pages back to their parent tab for highlight sync: `feed/feed-guest/feed-empty/feed-error→feed`, `paspor/catatan-calendar/timeline-empty/paspor-no-profile→paspor`, `konsultasi→konsultasi`, `profil→profil`, `create→create`.

Home bar: 10px tall, centered 130×4px pill at `opacity:.25`.

## 5. Page inventory (54 pages, grouped)

**Onboarding & auth (8):** p-splash (animated cold/hot start), p-feed-guest (read-only + soft login banner), p-login-gate (hard blocking modal), p-login, p-nickname, p-pet-select, p-onboard, p-notif-gate (push permission ask)

**Core tabs (5):** p-feed, p-paspor (growth passport timeline+milestones+stats+share FAB), p-konsultasi (AI/vet entry hub), p-profil, p-create

**Feed & content (2):** p-detail (full card + comments + 4 action sheets), p-notif (notification center)

**AI consultation (5):** p-ai-upload, p-ai-result, p-ai-result-green, p-ai-result-red (5s countdown-gated ack button), p-publish-reviewing

**Vet consultation (11):** p-konsultasi-home, p-konsultasi-offline (no vets online), p-match-wait (pulsing rings), p-match-timeout, p-chat, p-rate, p-vet-login, p-vet-dashboard, p-vet-queue, p-vet-case, p-vet-case-direct

**Vet chat & profile (4):** p-vet-chat, p-vet-history, p-vet-profile, p-vet-final-diagnosis (7-field diagnosis form)

**Pet management (4):** p-pet-create, p-pet-success, p-pet-edit, p-archive-confirm

**Milestones (4):** p-milestone, p-milestone-sheet, p-milestone-unlock, p-badge-gallery

**Timeline/calendar (1):** p-catatan-calendar

**Settings & moderation (4):** p-settings (incl. dark-mode toggle), p-publish-done, p-publish-rejected, p-delete-account

**Sharing (1):** p-namecard (shareable H5 namecard, dark backdrop)

**Status modal (1):** p-vet-status-popup

**Empty/error states (6):** p-notif-empty, p-feed-empty, p-feed-error, p-timeline-empty, p-paspor-no-profile, p-network-error

## 6. Notable interaction patterns

- **Long-press context menu**: 500ms touchstart/mousedown timer → opens `feed-longpress-sheet` (report flow only, no share — matches confirmed V1.0.0 Non-Goal).
- **Countdown-gated acknowledgment button**: red AI result page — button disabled (`opacity:.55`) with 5s visible countdown text, JS `setInterval` decrements, auto-enables at 0 (forces a minimum dwell time before dismissing a red/danger result).
- **Pop Art tab icon**: 3-layer SVG shadow-offset effect described above — distinctive brand signature, not a generic "active state".
- **Slide-up sheet animation**: `@keyframes slideUp{0%{transform:translateY(100%)}100%{transform:translateY(0)}}`, backdrop `rgba(14,10,20,.6)`, `touch-action:none` to block background scroll.
- **Theme toggle**: `data-theme` attribute on `<html>`, persisted to `localStorage('tt-theme')`, switch knob always stays white regardless of on/off bg color.
- **Form focus state**: vet form inputs shift border `#E6E6E6→#5BCBBB` (mint) on focus — no token-based focus ring observed elsewhere (light/pet-owner-facing forms don't show an explicit focus treatment in the static prototype).
- **Pulse/breathing animations**: `breathGlow`, `pulseRingSq`, `matchPulse` keyframes — splash glow, vet-match waiting ring, milestone-unlock backdrop.
- **Loading spinner**: SVG circle, `stroke-dasharray:60 180`, `animation:spin 1.4s linear infinite`.
- **Moderation progress bar**: `animation:reviewProgress 5s linear forwards`, width 0%→100%.

## 7. Token-system exceptions (intentional hardcodes — candidate Do's/Don'ts)

| Element | Hardcoded value | Note |
|---|---|---|
| Online-status dot | `#5BCBBB` fill, **`#fff` border always** | Never swap border to a token — must stay legible against any card background |
| Theme-toggle switch knob | `#fff` always | Same rule — knob never follows theme tokens |
| Pop-Art tab shadow | `#F0425A` | Brand signature accent, not part of general semantic palette |
| Vet-page header bg | `#2B2540` | Hardcoded dark purple, not a CSS var — vet pages have their own constant header treatment independent of the light/dark toggle |
| Sheet backdrop | `rgba(14,10,20,.6)`; login-gate backdrop `rgba(14,10,20,.72)` | Two near-identical dark overlays, slightly different opacity by context (modal block vs sheet) |

## 8. Discrepancy flagged for DESIGN.md drafting (see decision log)

The actual shipped HTML's measured type scale does **not** match `tokens.json`'s `typography.fontSize` scale:

| Role (as used in HTML) | HTML actual | Closest tokens.json value |
|---|---|---|
| Display heading | 26px / 700 | `3xl` = 28px |
| Section heading | 19px / 600 | `xl` = 20px |
| Body / button label | 15px / 500 | between `sm`(14) and `md`(16) |
| Card body text | 13px / 400 | between `xs`(12) and `sm`(14) |
| Caption/label | 11px / 500 | below `xs`(12) |

Similarly, several radii in active use (9px, 11px, 13px, 14px, 20px) fall *between* the defined token steps (sm4/md8/lg12/xl16/2xl28/3xl32) rather than on them.

Typography and spacing/radius in the HTML appear to be hand-tuned per component (no CSS custom properties for type/spacing — only **colors** are var()-based in this file), while `tokens.json` defines an idealized, evenly-stepped scale that the HTML never fully adopted.
