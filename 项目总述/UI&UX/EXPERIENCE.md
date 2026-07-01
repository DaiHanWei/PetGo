---
name: TailTopia
status: draft
sources:
  - Pet Project/TailTopia/V1.1.0/v1-1-0PRD.md
  - Pet Project/TailTopia/V1.1.0/v1-1-0后台prd.md
  - Pet Project/TailTopia/V1.0.0/V1-0-0PRD.md
updated: 2026-06-30
---

# TailTopia — Experience Spine

> Scope: behavioral spec for V1.1.0's net-new flows (paid AI/vet consultation, PawCoin, health records, monthly recap, starter tasks, pet ID card paid download, Apple Sign-In), layered onto the existing V1.0.0 IA (54-screen prototype). `DESIGN.md` is the visual identity reference — this spine owns behavior, not appearance. Spine wins on conflict with any mock or PRD wording nuance; the PRDs in `sources` are the requirements of record, this spine is the UX layer on top of them.

## Foundation

Single-surface mobile, iOS + Android, no tablet/desktop. Built in **Flutter** (one codebase, no platform-specific UI forks except the Apple Sign-In visibility rule below) — favor Flutter's standard widget/animation primitives over bespoke rendering wherever the spec allows, to keep implementation fast (see `DESIGN.md` Brand & Style for the one exception, the splash animation). Bottom tab bar (Feed / Paspor / Konsultasi / Profil / Create) for the five core destinations; every V1.1.0 addition is either a sheet, a full-screen flow reached via `data-notab` (tab bar hidden), or a state layered onto an existing screen — none of them add a sixth tab. Dark mode is **specified but not yet implemented in any shipped version** — colors are finalized (see `DESIGN.md` Colors), behavior described here (vet-professional surfaces always locked light regardless of the toggle) is the target once it's built, tracked in `待讨论事项.md`. Indonesian (Bahasa Indonesia) is the only shipped UI language.

## Information Architecture

| Surface | Reached from | Purpose |
| --- | --- | --- |
| AI 解锁支付弹层 | AI 问诊结果页, after free quota exhausted | FR-43A — choose QRIS/DANA or PawCoin to unlock full AI detail |
| 兽医咨询确认+支付 | Konsultasi hub → "兽医咨询" | FR-43D — prepay before entering the match queue |
| 订单页 | Profil → 订单记录 entry; also linked from 已暂停 banners | FR-54 — payment-method-agnostic transaction ledger (QRIS/DANA/PawCoin all show here) |
| 退款方式选择 | 订单页 → 已暂停 order → "申请退款" | FR-43D/50C — choose real-money refund (manual review) or PawCoin credit (instant + premium) |
| PawCoin 余额页 | Profil → "PawCoin" entry; also the "余额不足" deep-link from any paywall | FR-50 — balance, top-up entry, get/spend ledgers |
| 充值档位选择页 | PawCoin 余额页 → "充值"; or inline from a paywall's "去充值" link | FR-50A — 4 fixed tiers (Rp10,000/25,000/50,000/100,000), no custom amount |
| 健康记录列表/录入 | Paspor → 健康记录 entry | FR-45 — text-only structured log (vaccine, deworming, etc.), no photo attachment in V1.1.0 |
| 月度回顾卡片 | Paspor, auto-surfaced when ≥5 records exist for the prior month | FR-46 — auto-generated recap, shareable |
| 新手任务清单 | Profil or a first-two-weeks home banner | FR-47 — 6-task checklist, S-tier celebration reused from V1.0.0 milestones |
| 情绪彩蛋便签 | Surfaces contextually (e.g. late-night AI submission) | FR-48 — localized mood micro-copy, not a separate destination |
| 宠物身份证付费解锁 | Paspor → 身份证 card → "下载高清图" | FR-49D — free low-res preview, paid unlock for watermark-free download |
| Apple 登录 | Login / login-gate / soft-login-card, iOS only | FR-44 — peer-level with Google, shown first on iOS, hidden entirely on Android |
| 客服反馈/工单 | Profil → 帮助与反馈 | FR-52 — replaces V1.0.0's simple feedback form with a tracked ticket + CSAT loop |

→ Composition reference: `V1.0.0/页面/preview-core-pages.html` (54-screen baseline IA), `V1.0.0/页面/preview-new-splash-auth-0623.html` (Apple Sign-In, login-gate), [`mockups/preview-extraction.md`](mockups/preview-extraction.md) (distilled component/interaction patterns behind the rows below). Spine wins on conflict.

## Voice and Tone

Microcopy. Brand aesthetic posture lives in `DESIGN.md.Brand & Style`. Overall register: **warm companion for everyday content, precise and procedural the moment money, health, or an irreversible action enters the screen.**

| Do | Don't |
| --- | --- |
| "Mochi belajar duduk manis hari ini! 🐱" (feed/social — warm, first-person-pet voice) | Emoji or playful tone on payment, refund, or health-record copy |
| "Saldo PawCoin tidak cukup — isi ulang?" (plain, factual paywall copy) | "Yuk isi saldo dulu! 💰" on a paywall (money needs to read as serious, not gamified) |
| "Tindakan ini tidak dapat dibatalkan." stated plainly before any irreversible action | Burying irreversibility in a subordinate clause or skipping the warning |
| Exact figures in all payment/refund copy ("Rp40,000", "3 hari kerja") | Vague terms like "segera" (soon) where a concrete number exists |
| Indonesian-language vaccine/medical copy reviewed by a native-speaking vet or local ops before ship | Literal-translated medical terminology without local review |

## Component Patterns

Behavioral. Visual specs live in `DESIGN.md.Components`.

| Component | Use | Behavioral rules |
| --- | --- | --- |
| Paywall sheet | AI unlock, vet consultation, ID card download | Two payment options shown side by side (QRIS/DANA vs PawCoin); PawCoin option auto-disables and shows "去充值" deep-link when balance is insufficient — never just greys out without an escape hatch |
| PawCoin ledger row | Balance page get/spend lists | Each row is one immutable transaction: amount (always signed, + or −), reason tag, timestamp. No edit, no delete — corrections happen via new offsetting entries (refunds), never by mutating history. **PawCoin balance is non-transferable between user accounts — no UI anywhere (this surface or any future one) may offer sending/gifting PawCoin to another user.** This is a regulatory boundary (Indonesian e-money rule PBI 20/6/PBI/2018, PRD FR-50D), not a product preference — any future "gift PawCoin" feature request must be escalated for legal review before design work starts, not treated as a normal feature addition |
| Recharge tier card | Top-up tier picker | Exactly 4 cards, fixed amounts, no custom-amount field anywhere in the flow. Selecting a tier goes straight to the shared FR-43 payment sheet (QRIS/DANA only — you can't buy PawCoin with PawCoin) |
| Refund choice sheet | 已暂停 order → 申请退款 | Two options always shown together, never one without the other: "退回真钱" (manual review, 3 business days SLA, user must type in their own payout account) vs "转为 PawCoin" (instant, includes a premium %). Once chosen, the choice is locked for that request — no switching mid-review. **The payout-account field validates format before submission is allowed** (channel-appropriate pattern check, e.g. phone-number-length for e-wallets), and requires an explicit confirm-before-submit step showing the typed account back to the user — this is real money leaving a manual-review queue with no self-service correction path afterward, so catching typos before submission is the only safety net |
| 已暂停 banner | Order list / order detail | Always states the order is still valid and money isn't lost, regardless of which of the two paths (QRIS/DANA Cancel/Void failure, or PawCoin timeout/cancel) put it there — see `DESIGN.md` for the visual treatment, the copy itself must never let the user think they lost money |
| Health record row | 健康记录列表 | Text-only fields (type, date, note) — no photo attachment field in V1.1.0. Rabies-vaccine entries get a one-time contextual tip about annual boosters/inter-province travel documentation, shown inline at the entry-confirm step, not as a popup |
| Monthly recap card | Paspor, auto-surfaced | Generated only when the prior month has ≥5 happy-moment records; below that threshold, no card appears at all (no "too few entries" placeholder — silence is the correct empty state here) |
| Starter task item | 新手任务清单 | Each of the 6 tasks completes independently; completion triggers the same S-tier celebration animation reused from V1.0.0 milestones (half-screen sheet, 1–2s, badge reveal) — no bespoke animation work for this feature |
| Pet ID card paywall | 身份证 card detail | Free state always shows a usable (if lower-res/watermarked) preview — paying never unlocks content that was previously completely invisible, only removes the watermark/raises resolution |
| Account-deactivation two-step sheet | Settings → 注销账号 | Step 1's consequences list is **two explicitly separate groups, never blended into one paragraph**: (1) **deleted entirely and unrecoverable** — account, pet profile, health records, and the pet ID card's public H5 link (invalidated immediately); (2) **retained but anonymized** — posts/comments stay visible in Feed and other users' threads, with the avatar replaced by a default placeholder and nickname replaced with "已注销用户." Paid-benefit forfeiture (PawCoin balance included) is stated as its own line, not folded into either group. Step 2: type the literal confirmation word to enable the final destructive button. This is the one sanctioned two-deep sheet stack in the system — reuse this exact pattern for any future irreversible, high-consequence action; don't invent a new one |
| Apple Sign-In button | Login / login-gate / soft-login-card | iOS only, rendered above Google, identical height/radius/weight to the Google button — never visually subordinate. Hidden entirely (not disabled) on Android |

## State Patterns

| State | Surface | Treatment |
| --- | --- | --- |
| Free quota exhausted | AI 问诊结果 | Result still shows in full for green/yellow tiers below the fold; detail is blurred/truncated with the paywall sheet as the unlock path. Red-tier safety alert is **never** gated — full red detail always shows free, regardless of quota |
| PawCoin balance insufficient | Any paywall sheet | PawCoin option stays visible but shows current balance + shortfall, with a "去充值" link that deep-links into the top-up flow and returns to the exact same paywall step on completion — never restarts the user's in-progress action |
| 已暂停 (payment held) | Order detail | See Component Patterns above — distinguish the two trigger paths in any debugging/support tooling, but the user-facing copy and available actions are identical regardless of cause |
| Vet match timeout | Konsultasi waiting screen | After the 1-minute window, offer "retry matching" or "cancel" — cancellation triggers the same refund-method choice as any other un-rendered-service refund |
| Refund under manual review | Order detail | Status reads "审核中"; the in-progress refund request cannot be withdrawn or resubmitted until the review resolves (prevents concurrent state mutation) |
| Refund rejected twice | Order detail | Self-service "申请退款" entry is replaced with "联系客服处理" after 2 consecutive real-money-refund rejections on the same order — no third self-service attempt |
| Empty health record list | 健康记录列表 | Friendly empty state inviting the first entry — this is a content gap, not an error, so it uses the warm/social voice register, not the procedural one |
| Monthly recap below threshold | Paspor | No card, no placeholder, no "not enough entries yet" message — see Component Patterns |
| New user, starter tasks in progress | Home banner / Profil | Progress shown as "N/6 selesai"; banner persists through the first two weeks regardless of completion, then disappears whether or not all 6 are done (no guilt-tripping incomplete users) |
| Account deactivation in progress | Settings | Once Step 2's confirmation word is typed correctly and submitted, no further confirmation — the action is immediate and irreversible per the copy shown in Step 1 |
| Empty order list | 订单页 | New user with zero transactions: friendly empty state inviting first use of a paid feature, same warm/social register as the health-record empty state — this is a content gap, not an error |
| Recharge payment failure/pending | 充值档位选择页 | Follows the shared FR-43F rule: failed/cancelled payment rolls back to the tier-selection step with balance unchanged, no PawCoin granted, no order record created for the failed attempt — identical rollback behavior to any other FR-43 payment surface, not a PawCoin-specific exception |
| Recharge unavailable (float-threshold pause) | 充值档位选择页 | When platform-wide PawCoin float balance trips the regulatory monitoring threshold (see FR-50A) and operations pauses top-ups, the 充值 entry shows a distinct "暂不可充值" state with plain copy explaining it's temporary — **never the generic payment-failure error**, since this is a deliberate operational pause, not something the user or a payment gateway did wrong |

## Interaction Primitives

- Tap to act everywhere; no swipe gestures anywhere in the prototype baseline — don't introduce swipe-to-dismiss or swipe-to-refund for V1.1.0 surfaces without a corresponding Component Pattern entry.
- Long-press is reserved system-wide for the feed content-report menu (500ms hold) — do not repurpose long-press for any V1.1.0 surface (e.g., don't add long-press-to-delete on PawCoin ledger rows or health records).
- Bottom sheets open **and** close with a slide animation (`{components.sheet}` in `DESIGN.md`) — this applies to every new V1.1.0 sheet (paywall, refund choice, recharge tier picker uses a full page not a sheet, deactivation steps).
- Countdown-gated acknowledgment (disabled button + visible timer, auto-enables) is reserved for the red AI-result safety alert. Do not reuse this pattern for payment confirmations or PawCoin spend — those use a normal enabled button, since artificially slowing down a paid transaction serves no safety purpose.
- Type-to-confirm (must type an exact word to enable the destructive button) is reserved for the single highest-consequence action in the app, account deactivation. Do not extend it to PawCoin refund requests or order cancellations — those use the standard two-button neutral/danger sheet.
- **Banned:** swipe gestures, long-press outside the feed-report menu, a third tier of confirmation friction beyond type-to-confirm, custom one-off animations for any single V1.1.0 feature (reuse the existing celebration/sheet/spinner primitives instead).

## Accessibility Floor

Behavioral. Visual contrast lives in `DESIGN.md`.

- Tap targets ≥ 44pt/48dp on every new interactive element (paywall option cards, recharge tier cards, refund choice buttons, health-record row, starter-task checkbox), and on every icon-only control named in this spine (PawCoin balance page icon buttons, order-detail status icons). **PawCoin ledger rows are explicitly non-interactive** (no tap affordance, no detail view — see Component Patterns) and are exempt from this minimum.
- Every icon-only control (the PawCoin balance page's icon buttons, the order-detail status icons) carries an accessible label — icons are never the only signal of meaning, especially for the 已暂停/refund states where misreading the icon could make a user think money is lost.
- `text-secondary` (`#808080` light) passes AA at large-text sizes only — any V1.1.0 copy using this token at body size (16px/400) must step up to `text-primary` instead; this matters most for payment/refund copy where legibility is non-negotiable.
- Reduce Motion: the splash dog/cat run animation, the countdown-gated red-alert button, and **the S-tier celebration sheet (starter tasks, milestones) all respect the system Reduce Motion setting**. Splash jumps straight to the settled end-state (same as the existing "already shown today" fast-path); the countdown timer still enforces its dwell time but without the spinning/pulsing visual, just the numeric countdown; the celebration sheet shows a static badge with a simple cross-fade instead of its slide/bounce entrance — a full-screen animated takeover is exactly the motion category most likely to cause vestibular discomfort, so it does not get a Reduce-Motion exemption just because it's reused/familiar.
- Dynamic type: PawCoin amounts and Rupiah figures must never truncate at the largest accessibility text size — test the recharge tier cards and ledger rows specifically, since they pack a label + amount + timestamp into a fixed-width row. **Reflow order when space runs out: the timestamp wraps to a second line first; label and amount are the last elements to ever shrink or wrap, and amount text never truncates under any circumstance** (a partially-hidden money figure is worse than an extra line of height).
- Localization sizing: all component prose in this spine uses Chinese placeholder copy for brevity, but real Bahasa Indonesia strings are very likely longer ("Kembalikan ke uang asli" vs. "退回真钱") — **before sign-off, every label-dense, fixed-width component (recharge tier cards, refund choice buttons, badges) must be tested with actual Indonesian copy, not the placeholders in this document.** Overflowing labels wrap to a second line; they are never truncated with an ellipsis, since a cut-off financial or consent-related label is a comprehension risk, not just a cosmetic one.
- Account-deactivation Step 2's type-to-confirm input must be screen-reader-announced as required and must announce success/failure of the match in real time as the user types, not just on submit.

## Inspiration & Anti-patterns

Decisions made by directly comparing real explorations side by side (see `.decision-log.md` for the full reasoning) — recorded here so the rejections aren't silently lost once only the winning choice remains visible in the spines.

- **Rejected — a second brand hue (`#7D45F6`) for splash/auth "brand moments":** `preview-new-splash-auth-0623.html` explored splitting the identity into a violet for splash/login/login-gate and the standing `{colors.brand-primary}` for everything else. Rejected — a two-tone identity is a harder system to keep consistent than it's worth, and the app already reads as branded with one violet. The rest of that exploration (dog/cat run animation, Apple Sign-In treatment, two-step deactivation pattern) was kept, just recolored to `{colors.brand-primary}`.
- **Rejected — one-directional bottom-sheet animation:** `preview-core-pages.html`'s original sheets only animated the open (`animation:slideUp`, vanish instantly on close). Rejected in favor of `cs-contact-sheet.html`'s bidirectional `transform`/`transition` pattern (see `DESIGN.md` Components) — closing a sheet should feel as deliberate as opening one, not like it was never there.
- **Adopted — `tokens.json`'s idealized typography scale over the prototype's hand-measured pixel values:** the prototype's actual sizes (26/19/15/13/11px) were never on a consistent step; `tokens.json`'s 4px-stepped scale (28/20/16/14/12) was chosen instead so new screens have a learnable ramp rather than per-component magic numbers. Confirmed by visual side-by-side comparison (`mockups/typography-comparison.html`) — the difference reads as imperceptible on-screen, so there was no visual-fidelity cost to standardizing.
- **Rejected — forcing radius onto the same kind of abstract scale:** the opposite call from typography. The prototype's actual per-component radii (button 14px, input 11px, large card 20px, sheet 24px) were kept as-is rather than rounding them onto a generic sm/md/lg/xl scale, because the visual side-by-side (`mockups/radius-comparison.html`) showed radius differences read as more perceptually meaningful than the 1-2px font differences did — rounding them would have been a small but visible regression against the shipped V1.0.0 screens.

## Key Flows

### Flow 1 — AI 问诊先用后付解锁 (Sari, third AI check-in this month, just used her last free unlock)

1. Sari uploads a photo and symptom note for her cat in the AI 问诊 flow.
2. Result comes back yellow — she sees the danger-tier banner and a truncated care summary, free.
3. She taps to see the full structured advice; the paywall sheet opens, QRIS/DANA and PawCoin shown side by side.
4. Her PawCoin balance is Rp4,000 — short of the Rp10,000 unlock price. The PawCoin option shows the shortfall and a "去充值" link instead of greying out.
5. She taps "去充值," lands on the recharge tier page, picks Rp10,000, pays via QRIS.
6. **Climax:** she's returned automatically to the exact same paywall step — not the result page, not the home screen — taps "用 PawCoin 解锁" once more, and the full advice unlocks instantly. The detour to top up never made her lose her place.

Failure path: if she abandons the top-up mid-flow, the AI result stays exactly as she left it (yellow tier still free-visible, detail still locked) — no state is lost.

### Flow 2 — 兽医咨询预付费 + 已暂停 (Budi, it's 11pm, his dog has been favoring a paw for two days)

1. Budi opens Konsultasi, picks 兽医咨询 directly (skips AI — he wants a person).
2. Confirmation page shows the Rp50,000 price and the "进队列前预付费" model explained in one line.
3. He pays via PawCoin (he has a balance from a prior top-up) — payment confirms instantly, request enters the match queue.
4. 1 minute passes with no vet online (it's late). The request times out.
5. Because he paid in PawCoin, the order routes straight into 已暂停 — no Cancel/Void fallback path exists for PawCoin, this is always the primary path for this payment method.
6. **Climax:** the order-page banner reads clearly that his Rp50,000-worth of PawCoin is safe and the order is still valid, with two buttons: "重新发起匹配" (free, no repayment) or "取消" (instant PawCoin refund). He picks retry — no money left his account, and his case re-enters the queue identically to a fresh request, costing him only patience.

Contrast note: had Budi paid with QRIS instead, he'd see 已暂停 only in the rare event Cancel/Void itself failed — the vast majority of QRIS/DANA timeouts resolve invisibly.

### Flow 3 — PawCoin 充值 + 消费 (Rani, wants to top up ahead of a planned vet visit rather than pay in the moment)

1. From Profil, Rani taps the PawCoin entry — sees her current balance (Rp0) and two ledgers (获取明细 / 消费明细), both empty.
2. Taps 充值, lands on the 4-tier picker (Rp10,000/25,000/50,000/100,000) — no custom-amount field.
3. Picks Rp50,000, pays via DANA through the shared FR-43 payment component.
4. **Climax:** back on the balance page, a success toast reads "Sudah masuk 50,000 PawCoin," the balance updates instantly, and the 获取明细 ledger shows one new immutable row: +50,000, "Charge," timestamped.
5. A week later she uses the balance for a vet consultation; the 消费明细 ledger gets its own new row: −50,000, "Vet consultation," timestamped — the get and spend histories never merge into one undifferentiated list.

Failure path: if her DANA payment fails or she backs out mid-payment (FR-43F), the tier picker reappears unchanged, her balance stays at Rp0, and no ledger row is created — a failed top-up leaves no trace, successful or not.

### Flow 4 — 健康记录录入 (Dewi, just got back from the vet with her dog's rabies booster)

1. From Paspor, Dewi opens 健康记录, taps to add a new entry.
2. Picks record type "疫苗" → "狂犬病疫苗," enters the date.
3. Because she picked rabies specifically, a one-time inline tip appears at the confirm step: annual booster reminder + advice to keep proof for inter-province travel — localized to Indonesian regulation language.
4. **Climax:** she saves the entry with no photo attachment required (V1.1.0 is text-only) — the record appears instantly in her pet's health list, contributing silently to the data base that 1.3.0's reminder feature will eventually use.

Failure path: if the save fails (network drop, etc.), her entered text is preserved on the entry form, not discarded — she can retry without retyping the date/type/note.

### Flow 5 — 月度回顾打开 (Putri, opens the app on the 1st of the month)

1. Putri's pet had 7 happy-moment posts last month — comfortably over the 5-record minimum.
2. A recap card appears at the top of her Paspor tab, unprompted.
3. She taps it open — sees a generated summary card of the month's moments.
4. **Climax:** she shares it (FR-46C share action) — the recap becomes the retention hook it's designed to be, proof that showing up casually all month adds up to something worth looking back on.

Contrast: her friend, whose cat had only 2 posts that month, sees no recap card at all and no message explaining its absence — silence is correct here, not a "you didn't post enough" notice.

### Flow 6 — 新手任务完成 (Agus, signed up four days ago)

1. Agus sees a home banner: "2/6 selesai" for his starter checklist.
2. He completes task N-2 ("first AI consultation") — judged complete the instant a result successfully generates, regardless of whether he reads the detail or pays to unlock it.
3. **Climax:** the same S-tier celebration sheet used for V1.0.0 milestones fires — half-screen, 1–2 seconds, badge reveal. No new animation was built for this; the existing primitive does the job.
4. By his third week, whether he finished all 6 or stalled at 3, the banner simply stops appearing — no nagging follow-up.

### Flow 7 — 宠物身份证付费下载 (Lina, wants a clean copy of her dog's ID card for a vet-clinic form)

1. Lina opens her dog's 身份证 card in Paspor — sees the free preview, lower-res with a watermark, fully viewable.
2. She taps "下载高清图" — the paywall sheet opens (Rp5,000, QRIS/DANA or PawCoin).
3. She has enough PawCoin from a prior top-up, pays instantly.
4. **Climax:** the watermark-free, full-resolution image downloads — the free preview was never useless filler, just lower fidelity; paying only removed the watermark and raised resolution, nothing was hidden outright.

Failure path: if her payment fails (FR-43F), the paywall sheet reopens at the same state — the free watermarked preview remains fully visible throughout, so a failed payment never leaves her looking at a broken or blank card.

### Flow 8 — Apple 登录 (Wisnu, has an iPhone, taps a protected feature for the first time)

1. Wisnu, not yet signed in, taps "兽医咨询" — the login-gate sheet opens (FR-0C).
2. Because he's on iOS, Apple Sign-In renders above Google, same height/radius/weight, no visual subordination (FR-44).
3. He taps "Lanjutkan dengan Apple," completes the system Apple authentication sheet.
4. The app checks his Apple-provided email/identifier against existing accounts. No match exists — a new account is created automatically (matching the soft-login-card's "Akun baru dibuat otomatis — cukup satu tap!" promise, FR-44/FR-0D parity).
5. **Climax:** he's returned directly to the 兽医咨询 flow he originally tapped — login was a detour, not a destination, and the account-merge branch (FR-44A) never had to trigger because no prior account existed.

Contrast (account-merge branch): had Wisnu previously created an account via Google using the same email, FR-44A's merge logic applies instead of creating a duplicate account — out of scope for this flow's visual walkthrough, but the entry point (same Apple Sign-In button, same login-gate sheet) is identical regardless of which branch fires server-side.

Platform note: on Android, this entire flow doesn't exist — the Apple Sign-In button is absent (not disabled) from every login surface, and Google is the sole option.
