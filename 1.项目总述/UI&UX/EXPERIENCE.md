---
name: TailTopia
status: draft
sources:
  - Pet Project/TailTopia/V1.1.0/v1-1-0PRD.md
  - Pet Project/TailTopia/V1.1.0/v1-1-0后台prd.md
  - Pet Project/TailTopia/V1.0.0/V1-0-0PRD.md
updated: 2026-07-10
---

# TailTopia — Experience Spine

> Scope: behavioral spec for V1.1.0's net-new flows (paid AI/vet consultation, PawCoin, health records, starter tasks, pet ID card paid download, Apple Sign-In), layered onto the existing V1.0.0 IA (54-screen prototype). `DESIGN.md` is the visual identity reference — this spine owns behavior, not appearance. Spine wins on conflict with any mock or PRD wording nuance; the PRDs in `sources` are the requirements of record, this spine is the UX layer on top of them.
>
> **Monthly recap (原 FR-46 系列) is not part of V1.1.0** — pulled from scope 2026-07-08 (see PRD §3.3), version TBD. Removed from this spine 2026-07-10 for the same reason: it was still described here as live scope, which no longer matches the PRD. **2026-07-11 update: the prototype (`p-recap` in `V1.1.0/页面/preview-v1.1.0-new-pages.html`, including the 12-theme skin work) has been deleted outright, not archived** — the preview file should only reflect V1.1.0's actual scope, not double as a reference library for deferred features. If this is rescheduled, redesign it fresh (or pull from git history) rather than expecting a reusable prototype to still be sitting in that file.

## Foundation

Single-surface mobile, iOS + Android, no tablet/desktop. Built in **Flutter** (one codebase, no platform-specific UI forks except the Apple Sign-In visibility rule below) — favor Flutter's standard widget/animation primitives over bespoke rendering wherever the spec allows, to keep implementation fast (see `DESIGN.md` Brand & Style for the one exception, the splash animation). Bottom tab bar (Feed / Paspor / Konsultasi / Profil / Create) for the five core destinations; every V1.1.0 addition is either a sheet, a full-screen flow reached via `data-notab` (tab bar hidden), or a state layered onto an existing screen — none of them add a sixth tab. Dark mode is **specified but not yet implemented in any shipped version** — colors are finalized (see `DESIGN.md` Colors), behavior described here (vet-professional surfaces always locked light regardless of the toggle) is the target once it's built, tracked in `待讨论事项.md`. Indonesian (Bahasa Indonesia) is the only shipped UI language.

**Vet-facing surface.** Veterinarian accounts run through a parallel host shell (`VetWorkbenchShell`), not the pet-owner tab bar above — its own bottom nav has 5 tabs: **Antrian** (接单队列), **Aktif** (进行中会话), **Riwayat** (历史记录), **Pendapatan** (收入, FR-53D), **Saya** (profile — out of this delta's scope, unchanged/unbuilt). Always renders in the fixed light `{colors.vet-header}` palette per `DESIGN.md`, never following the pet owner's dark-mode preference. Prior to this update, **Aktif had no destination at all** — the nav button existed and pointed nowhere; it's now defined below (IA, State Patterns).

## Information Architecture

| Surface | Reached from | Purpose |
| --- | --- | --- |
| AI 解锁支付弹层 | AI 问诊结果页, after free quota exhausted | FR-43A — choose QRIS/DANA or PawCoin to unlock full AI detail |
| 兽医咨询确认页 | Konsultasi hub → "兽医咨询" | FR-43D — submits the request unpaid straight into the match queue (免费入队); the payment sheet only appears later, after a vet accepts (see 待支付 in State Patterns) |
| 订单页 (Pesanan Saya) | Profil → 订单记录 entry | FR-54 — payment-method-agnostic transaction ledger covering **4 order types**, not just vet consultations: 兽医咨询 (FR-54A, 6-state model) / PawCoin 充值 (FR-54B) / AI 问诊解锁 (FR-54C) / 身份证高清图 (FR-54D). Type filter tabs (全部/咨询/充值/高清图) at the top; each type keeps its own independent status vocabulary — a 充值 card is never "待接单," an AI 解锁 card is never "退款处理中" |
| 退款方式选择 | 订单页 → 兽医咨询 order in **退款处理中·待选方式** sub-stage, reached only after a CS ticket (FR-52) is approved | FR-43D/50C — choose real-money refund (manual review) or PawCoin credit (instant + premium). **No self-service "申请退款" entry exists anywhere in the app** — every real-money refund starts as a 联系客服 ticket, not an in-app button |
| p-vet-active (Aktif tab) | Vet workbench bottom nav → "Aktif" | FR-53A/FR-53C — this vet's currently in-session consultations (payment succeeded, chat is live); tapping a row resumes the chat. **This surface didn't exist before this update** — the nav button previously had no destination. Built at `V1.1.0/页面/preview-v1.1.0-new-pages.html#p-vet-active` |
| PawCoin 余额页 | Profil → "PawCoin" entry; also the "余额不足" deep-link from any paywall | FR-50 — balance, top-up entry, get/spend ledgers |
| 充值档位选择页 | PawCoin 余额页 → "充值"; or inline from a paywall's "去充值" link | FR-50A — 4 fixed tiers (Rp10,000/25,000/50,000/100,000), no custom amount |
| 健康记录列表/录入 | Paspor → 健康记录 entry | FR-45 — text-only structured log (vaccine, deworming, etc.), no photo attachment in V1.1.0 |
| 新手任务清单 | Profil or a first-two-weeks home banner | FR-47 — 6-task checklist, S-tier celebration reused from V1.0.0 milestones |
| 宠物身份证付费解锁 | Paspor → 身份证 card → "下载高清图" | FR-49D — free low-res preview, paid unlock for watermark-free download |
| Apple 登录 | Login / login-gate / soft-login-card, iOS only | FR-44 — peer-level with Google, shown first on iOS, hidden entirely on Android |
| 客服反馈/工单 | Profil → 帮助与反馈 | FR-52 — replaces V1.0.0's simple feedback form with a tracked ticket + CSAT loop |

→ Composition reference: `V1.0.0/页面/preview-core-pages.html` (54-screen baseline IA), `V1.0.0/页面/preview-new-splash-auth-0623.html` (Apple Sign-In, login-gate), `V1.1.0/页面/preview-v1.1.0-new-pages.html` (vet workbench, order center, PawCoin/refund screens — authoritative source for the vet-side and order-state rows above), [`mockups/preview-extraction.md`](mockups/preview-extraction.md) (distilled component/interaction patterns behind the rows below). Spine wins on conflict.

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
| Refund choice sheet | 订单详情 (退款处理中·待选方式), reachable only after a CS ticket (FR-52) is approved — **never a self-service entry from an in-progress or completed order** | Two options always shown together, never one without the other: "退回真钱" (manual review, 3 business days SLA, user must type in their own payout account) vs "转为 PawCoin" (instant, includes a premium %). Once chosen, the choice is locked for that request — no switching mid-review. **The payout-account field validates format before submission is allowed** (channel-appropriate pattern check, e.g. phone-number-length for e-wallets), and requires an explicit confirm-before-submit step showing the typed account back to the user — this is real money leaving a manual-review queue with no self-service correction path afterward, so catching typos before submission is the only safety net. PawCoin-paid orders never reach this sheet — they auto-refund instantly with no choice to make. **The premium/bonus percentage applies only to the "转为 PawCoin" conversion path shown in this sheet (real money → PawCoin) — it never applies to a PawCoin-original order's auto-refund, which is always equal-amount, no bonus.** These are two different money paths that happen to both end in a PawCoin balance; don't let one component's bonus logic leak onto the other |
| Order status banner | Order detail (待接单/待支付/退款处理中) | Three tonal variants, one always visible at the top of the card, never a dismissible toast: 待接单 states plainly "no charge yet, cancel any time, nothing to refund"; 待支付 adds the live 1.5-minute countdown; 退款处理中·审核中 reads as a passive wait ("CS hasn't decided yet," no action available); 退款处理中·待选方式 is the one banner with a CTA ("choose your refund method"). Replaces the old prepay-model's single-purpose "已暂停 banner" entirely — that state no longer exists in V1.1.0 |
| Vet active-session row | `p-vet-active` | Same shell rhythm as the vet queue card (avatar chip, patient name/species, elapsed time) but exactly one action — "Lanjutkan Chat" — since resuming an already-paid session isn't a new commitment the way accepting a case is. A session appears here the instant the pet owner's payment clears (mirrors 待支付 → 进行中 firing on the owner's side) and disappears the instant the session ends (moves to Riwayat) |
| Health record row | 健康记录列表 | Text-only fields (type, date, note) — no photo attachment field in V1.1.0. Rabies-vaccine entries get a one-time contextual tip about annual boosters/inter-province travel documentation, shown inline at the entry-confirm step, not as a popup |
| Starter task item | 新手任务清单 | Each of the 6 tasks completes independently; completion triggers the same S-tier celebration animation reused from V1.0.0 milestones (half-screen sheet, 1–2s, badge reveal) — no bespoke animation work for this feature |
| Pet ID card paywall | 身份证 card detail | Free state always shows a usable (if lower-res/watermarked) preview — paying never unlocks content that was previously completely invisible, only removes the watermark/raises resolution |
| Account-deactivation two-step sheet | Settings → 注销账号 | Step 1's consequences list is **two explicitly separate groups, never blended into one paragraph**: (1) **deleted entirely and unrecoverable** — account, pet profile, health records, and the pet ID card's public H5 link (invalidated immediately); (2) **retained but anonymized** — posts/comments stay visible in Feed and other users' threads, with the avatar replaced by a default placeholder and nickname replaced with "已注销用户." Paid-benefit forfeiture (PawCoin balance included) is stated as its own line, not folded into either group. Step 2: type the literal confirmation word to enable the final destructive button. This is the one sanctioned two-deep sheet stack in the system — reuse this exact pattern for any future irreversible, high-consequence action; don't invent a new one |
| Apple Sign-In button | Login / login-gate / soft-login-card | iOS only, rendered above Google, identical height/radius/weight to the Google button — never visually subordinate. Hidden entirely (not disabled) on Android |

## State Patterns

| State | Surface | Treatment |
| --- | --- | --- |
| Free quota exhausted | AI 问诊结果 | Result still shows in full for green/yellow tiers below the fold; detail is blurred/truncated with the paywall sheet as the unlock path. Red-tier safety alert is **never** gated — full red detail always shows free, regardless of quota |
| PawCoin balance insufficient | Any paywall sheet | PawCoin option stays visible but shows current balance + shortfall, with a "去充值" link that deep-links into the top-up flow and returns to the exact same paywall step on completion — never restarts the user's in-progress action |
| 待接单 (queued, unpaid) | Order detail — 兽医咨询 | Request sits unpaid in the vet match queue (FR-43D, 2026-07-06 model). Both the 1-minute no-vet-online timeout and a user-initiated cancel remove the request outright — **no order record is created or kept**, since no charge ever occurred; user returns straight to Konsultasi to retry. There is no "已取消" state to display — this replaces the deprecated prepay/已暂停 model entirely, which no longer exists in V1.1.0 |
| 待支付 (vet matched, 1.5-min window) | Order detail — 兽医咨询 | A vet accepted; the payment sheet is live for 1.5 minutes (synced with the vet's `p-vet-queue-pay` waiting sub-state). Payment success → 进行中. Timeout or user-cancel → the match is simply voided, **order rolls back to 待接单** and auto-rebroadcasts to another online vet — still no charge, so still no refund path involved |
| 进行中 → 已完成 | Order detail — 兽医咨询 | Normal session completion; "去评价" CTA appears once, replaced by the submitted rating |
| 退款处理中 · 审核中 | Order detail — 兽医咨询 | Only reachable from 已完成 via a CS ticket (FR-52) — **there is no self-service "申请退款" entry anywhere in the app**. Status reads "CS 尚未批准," no action available, links out to "我的反馈" to track the ticket |
| 退款处理中 · 待选方式 | Order detail — 兽医咨询 | Appears only after CS approves the ticket; PawCoin-paid orders skip this sub-stage entirely (auto-refund, no choice needed); QRIS/DANA-paid orders show "选择退款方式" → Refund choice sheet |
| 已退款 (terminal) | Order detail — 兽医咨询 | Shows the chosen method, channel, fee-adjusted amount (non-BCA channels show the Rp2,500 deduction), and settlement time |
| CS 驳回退款申请 (terminal) | Order detail — 兽医咨询 | **Didn't previously exist** — the order had nowhere to land after a rejection and would show "退款处理中" forever, silently lying to the user. Decision: rolls back to **已完成**, carrying a small "退款未通过" tag alongside the normal 已完成 display (not a new 7th top-level status) — this is what FR-52/AB-5B's "退款申请未通过" notification now points to. User can still open a fresh 联系客服 ticket from here, but there's no automatic second self-service attempt |
| PawCoin 充值订单卡 | Order detail — FR-54B (independent status vocabulary, never reuses the 兽医咨询 states above) | Two states only: 已到账 (amount + credited coin count) / 支付失败 (no coin count shown, "支付未成功，未扣款" copy) |
| AI 解锁订单卡 | Order detail — FR-54C | Single fixed state, 已解锁 — no other status exists for this card type. **A PawCoin-paid unlock that fails to generate creates no order record at all** — the refund shows only in the PawCoin ledger, never as a card here |
| 身份证高清图订单卡 | Order detail — FR-54D | Single fixed state, 已购买 (one-time unlock, permanently re-downloadable). The "重新下载" action has one failure sub-state: if the linked pet profile has since been deleted (V1.0.0 FR-39A), the button greys out with "宠物档案已删除，无法重新下载" instead of navigating anywhere |
| p-vet-active, empty | Vet workbench → Aktif | No sessions currently in progress — plain "belum ada sesi aktif" caption, matching this spine's friendly-empty tone, not an error state |
| p-vet-active, populated | Vet workbench → Aktif | One row per session where the pet owner's payment has cleared and the chat is live (this is the vet-side mirror of the 进行中 order state). A session enters the moment 待支付 → 进行中 fires on the owner's side and leaves the moment the session ends (moves to Riwayat) |
| Empty health record list | 健康记录列表 | Friendly empty state inviting the first entry — this is a content gap, not an error, so it uses the warm/social voice register, not the procedural one |
| New user, starter tasks in progress | Home banner / Profil | Progress shown as "N/6 selesai"; banner persists through the first two weeks regardless of completion, then disappears whether or not all 6 are done (no guilt-tripping incomplete users) |
| Account deactivation in progress | Settings | Once Step 2's confirmation word is typed correctly and submitted, no further confirmation — the action is immediate and irreversible per the copy shown in Step 1 |
| Empty order list | 订单页 | New user with zero transactions: friendly empty state inviting first use of a paid feature, same warm/social register as the health-record empty state — this is a content gap, not an error. Built 2026-07-11 (previously only described in this spine, never in the prototype) |
| ID card not yet generated | 身份证详情页 | Old (V1.0.0-era) pet profiles that predate the flow-number system show a guide state — "kartu identitas belum dibuat" + an "Ajukan Sekarang" button — instead of jumping straight to a card, since they don't have a number yet. Tapping the button triggers number assignment (FR-49A) and the page switches to the normal card view permanently; this state never reappears for that profile afterward |
| Share link → deleted pet profile | 身份证分享落地页 | If the shared pet profile has since been deleted (FR-49A — the number was released back to the pool), the link shows a dedicated "profil hewan ini sudah dihapus" state, never a generic error page or blank screen — this applies regardless of whether the visitor has the app installed |
| Recharge payment failure/pending | 充值档位选择页 | Follows the shared FR-43F rule: failed/cancelled payment rolls back to the tier-selection step with balance unchanged, no PawCoin granted, no order record created for the failed attempt — identical rollback behavior to any other FR-43 payment surface, not a PawCoin-specific exception |
| Recharge unavailable (float-threshold pause) | 充值档位选择页 | When platform-wide PawCoin float balance trips the regulatory monitoring threshold (see FR-50A) and operations pauses top-ups, the 充值 entry shows a distinct "暂不可充值" state with plain copy explaining it's temporary — **never the generic payment-failure error**, since this is a deliberate operational pause, not something the user or a payment gateway did wrong |

## Interaction Primitives

- Tap to act everywhere; no swipe gestures anywhere in the prototype baseline — don't introduce swipe-to-dismiss or swipe-to-refund for V1.1.0 surfaces without a corresponding Component Pattern entry.
- Long-press is reserved system-wide for the feed content-report menu (500ms hold) — do not repurpose long-press for any V1.1.0 surface (e.g., don't add long-press-to-delete on PawCoin ledger rows or health records).
- Bottom sheets open **and** close with a slide animation (`{components.sheet}` in `DESIGN.md`) — this applies to every new V1.1.0 sheet (paywall, refund choice, recharge tier picker uses a full page not a sheet, deactivation steps).
- **System back button, full-screen money flows (`data-notab`)** — was undefined until 2026-07-11; three surfaces now have explicit semantics because "just pop the route" is wrong for at least two of them: 等待接单页 (nothing charged yet → back = immediate cancel, no confirmation needed); 限时支付页 (a vet already accepted this case → back = confirm-before-abandon, "放弃这次接单？兽医已经在等你付款了," confirming voids the match same as the in-page cancel button); 填收款账户页 (user may have a half-typed payout account → back = confirm-before-leave only if the form has content, and the draft is preserved either way, never silently cleared).
- Countdown-gated acknowledgment (disabled button + visible timer, auto-enables) is reserved for the red AI-result safety alert. Do not reuse this pattern for payment confirmations or PawCoin spend — those use a normal enabled button, since artificially slowing down a paid transaction serves no safety purpose.
- Type-to-confirm (must type an exact word to enable the destructive button) is reserved for the single highest-consequence action in the app, account deactivation. Do not extend it to PawCoin refund requests or order cancellations — those use the standard two-button neutral/danger sheet.
- **Banned:** swipe gestures, long-press outside the feed-report menu, a third tier of confirmation friction beyond type-to-confirm, custom one-off animations for any single V1.1.0 feature (reuse the existing celebration/sheet/spinner primitives instead).

## Accessibility Floor

Behavioral. Visual contrast lives in `DESIGN.md`.

- Tap targets ≥ 44pt/48dp on every new interactive element (paywall option cards, recharge tier cards, refund choice buttons, health-record row, starter-task checkbox), and on every icon-only control named in this spine (PawCoin balance page icon buttons, order-detail status icons). **PawCoin ledger rows are explicitly non-interactive** (no tap affordance, no detail view — see Component Patterns) and are exempt from this minimum.
- Every icon-only control (the PawCoin balance page's icon buttons, the order-detail status icons) carries an accessible label — icons are never the only signal of meaning, especially for the 退款处理中/已退款 states where misreading the icon could make a user think money is lost.
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

### Flow 2 — 兽医咨询免费入队 + 接单后限时支付 (Budi, it's 11pm, his dog has been favoring a paw for two days)

1. Budi opens Konsultasi, picks 兽医咨询 directly (skips AI — he wants a person).
2. Confirmation page shows the Rp50,000 price and states plainly that **no charge happens yet** — the request goes straight into the match queue unpaid.
3. He submits — order status shows 待接单: no payment method chosen, no money moved.
4. **A vet online at that hour (Dewi) accepts the case** — on her side, it moves from her Antrian queue into a "已接单，等待用户支付" waiting sub-state with a 1.5-minute countdown synced to Budi's payment window (`p-vet-queue-pay`); Budi's order flips to 待支付.
5. Budi has 1.5 minutes to pick QRIS/DANA or PawCoin. He pays via PawCoin (balance from a prior top-up) — confirms instantly.
6. **Climax:** the moment payment clears, the session opens on both sides at once — Budi's order flips to 进行中, and on Dewi's side the case vanishes from her queue and reappears in her **Aktif tab** (`p-vet-active`) as a live session she can resume any time. Neither side ever sees a "paid but nothing happened" gap — the two flips are the same event.

Failure path: if Budi lets the 1.5-minute window lapse (or backs out of paying), the match is simply voided — no charge ever occurred, so there's nothing to refund. His request auto-rebroadcasts to another online vet; Dewi's queue entry disappears with a 3-second "用户未及时支付，接单已作废" toast (FR-53B) — she doesn't do anything.

Contrast (the one scenario that produces a real refund): if Budi's session had already started and then genuinely needed a refund (say the vet had to disconnect mid-consult), that's the only path with actual money to return — and it isn't self-service. He'd file a ticket via 联系客服 (FR-52); only after a human agent approves it does "选择退款方式" appear on his order (PawCoin auto-refunds instantly; QRIS/DANA lets him choose cash-out or PawCoin-with-premium). If CS instead rejects the request, the order simply reverts to 已完成 with a small "退款未通过" tag — it never gets stuck showing "处理中" forever.

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

### Flow 5 — reserved

Was 月度回顾打开 (原 FR-46 系列). Pulled from V1.1.0 scope 2026-07-08 (PRD §3.3) — this flow slot is left empty rather than renumbering Flows 6–8, matching the PRD's own "FR 编号保留不复用" convention for this feature. Prototype kept at `p-recap`; re-populate this slot when the feature is rescheduled.

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
