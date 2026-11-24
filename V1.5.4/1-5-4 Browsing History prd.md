# 1-5-4 Browsing History prd

---
title: "Browsing History"
status: final
created: 2026-11-19
updated: 2026-11-23
---

# PRD: TailTopia Pet App — Browsing History (V1.5.4)

## 0. About this document

- **What this is:** a new **Riwayat** (history) page, opened from the AKTIVITAS card on the Saya page. It lists the posts the user opened or liked and the Toko products they opened in the last 14 days, so they can get back to them.
- **Who it is for:** product (Albar, Hex), Dai's backend and app developers, design, QA.
- **Release:** V1.5.4 (date not set).
- **Source:** Roadmap V1.5.4 "历史浏览记录" (added 2026-11-12) and the brief for 1.5.4.
- **Code baseline:** `petgo-platform` `origin/stag` `f0d02163b` (V1.5.0; merged to `main` 2026-11-19). V1.5.2 is not developed yet, so the V1.5.2 changes this PRD relies on are taken from the V1.5.2 PRDs (listed in §4).
- **Merge order (1.5.4, Hex 2026-11-20):** all three 1.5.4 PRDs (KTP share link, mention nickname, browsing history) build on 1.5.2 and merge after it. Shared code: the one push/notification destination function that 1.5.2 FR-244 creates. The mention PRD adds the comment-ID case (FR-270) and merges first; the KTP PRD adds the card-link route (FR-263) and rebases on it. Browsing history doesn't touch that function: it adds a cell to the Saya page's AKTIVITAS card, a new Riwayat page, and recording inside the server's post detail, post like and product detail APIs. It doesn't change the app's post detail page, so it can merge any time after 1.5.2.
- **Numbering:** **FR-274 to FR-281**, **AC1 to AC31**. V1.5.2 uses FR-225 to FR-259; the KTP share link PRD uses FR-260 to FR-267 and the mention PRD FR-268 to FR-273, so this PRD starts at FR-274 (OQ-2).
- **Markers:** decisions are Albar's (2026-11-19, from the coaching session) and Hex's (2026-11-20 and 2026-11-23, logged in `V1.5.4/.decision-log.md`). `[DEV]` = dev to confirm.

## 1. Why

People open or like posts and look at products without saving them. Later they want them back and can't find them: the feed has moved on, and nothing records what they saw.

A "recently viewed" list is a basic expectation, especially for shopping. It gives every half-remembered post or product a second chance to turn into a save, a follow or a purchase.

**Goal:** a user can find a post they opened or liked, or a product they opened, in the last 14 days in a few taps, even if they never saved it.

## 2. User journeys

**UJ-1. Rina finds the post she read.**
Rina, 24, lives in Depok with two cats.

1. On Monday night she opens a post about a DIY cat scratcher from the Sosial feed, reads it and moves on.
2. On Wednesday she wants to build one. She goes to **Saya → Riwayat → Postingan**, and under "Senin, 16 Nov" she sees the post.
3. She opens it and saves it this time.

**UJ-2. The scratcher is sold out, then back.**

1. On Monday Rina also opened a ready-made scratcher in Toko.
2. On Wednesday she finds it under **Produk**, marked "Stok habis" (sold out).
3. On Friday she checks **Produk** again. It's back in stock, so she buys it.

## 3. Glossary

- **History entry:** one item in a user's history: what it is, and the last time they opened it (or, for a post, liked it). One item appears **once**; opening or liking it again moves it to the top.
- **Pill:** one of the two groups on the Riwayat page: **Postingan** (posts) and **Produk** (products). This follows the pills already used in Disimpan.

## 4. What exists today

From code (`origin/stag` `f0d02163b`):

- **No history of opened posts or products exists.**
  - The server counts post views per viewer when the detail page opens (`content_post_views`). That record isn't meant to be listed per user and is kept after account deletion, so it isn't reused here.
- **The Saya page**, top to bottom: profile card → four stats → Edit Profil → Hewanku → **AKTIVITAS card** → posts area (**Postinganku | Disimpan 🔒**).
- **The AKTIVITAS card** is one card with up to three cells in a row: **Pesanan Saya** (orders) · **Koin & Jatah** (coins and credits) · **Paket Hemat** (value pack, only while on sale).
- **The Sosial feed** is a two-column masonry of `MasonryCard`.
- **Disimpan (saved)** is the pattern to follow for storage and loading: it's stored on the server, loads in pages, has pills and the privacy line "Hanya kamu yang bisa melihat".

From V1.5.2 PRDs (not developed yet):

- **Toko "seen" record** (V1.5.2 shop PRD, FR-226): the server records which products were *sent* to a user, to rotate the Toko feed. It means "delivered in a list", not "opened", and is never shown to the user. It is **not** reused here.
- **Product card** (FR-229 and the card rules in that PRD): one component, `ShopProductCard`, with a 1:1 image and a 2-line title; it shows "Stok habis", and the list API returns a sold-out flag.
- **Likes on Diary cards** (V1.5.2 gift-thanks / Diary PRD, FR-238).
- **Private posts** (same PRD, FR-241): the post detail API checks visibility, and a private post can only be seen by others through the author's single-post share link.

## 5. Features

### FR-274: What gets recorded

**Logged-in users only.** Guest browsing is not recorded and is not merged in after login.

| Pill | Recorded when |
|---|---|
| **Postingan** | (a) another user's post detail page opens, from anywhere in the app (feed, profile, Diary, search results, notifications, push, banners, a share link opened in the app, Riwayat itself); or (b) the user likes another user's post, from anywhere (feed card heart, double-tap, Diary card, post detail) |
| **Produk** | the Toko product detail page opens, from anywhere in the app (Toko, search, banners, posts, Riwayat itself) |

- **Recorded by the server, not reported by the app.** When the post detail, post like or product detail API succeeds for a logged-in user, the server writes the entry. The app sends nothing extra.
- **Unliking doesn't remove the entry.** Liking a comment doesn't count.
- **Never recorded:**
  - guests, and H5 web pages;
  - the user's own posts, opened or liked;
  - **private posts**, including one opened or liked through a single-post share link;
  - posts or products that only appear in a list (feed cards, grids, search results, Toko cards), however long the user stays on them, unless the user likes the post;
  - API calls that are not the user opening the detail page, for example the check before opening a notification, or the add-to-cart sheet loading the product (see Appendix B);
  - user profiles, pet pages, topics and places;
  - banners and pop-ups themselves. A post or product opened from a banner is recorded like any other open.
- **One entry per item.** Opening or liking it again updates the time and moves it to the top under today.
- **Time of an entry:** the server's time of the open or like.
- Recording never slows a page or a like down. If saving fails, the user sees no error.

**AC1** Opening another user's post adds it to Postingan under today.
**AC2** Scrolling past a post in the Sosial feed, or stopping on it without opening or liking it, adds nothing.
**AC3** Liking a post in the Sosial feed (heart or double-tap) without opening it adds it to Postingan; unliking it afterwards leaves the entry.
**AC4** Opening a post from a profile grid, Diary or search results adds that post.
**AC5** Opening a product detail, including from a banner, adds it to Produk. Toko list cards and the add-to-cart sheet do not.
**AC6** The user's own posts never appear, even after the user likes one.
**AC7** A guest's browsing records nothing: after logging in, none of the posts or products opened as a guest are in history.
**AC8** Opening the same post on Monday and liking it on Wednesday leaves one entry, shown under Wednesday's header.
**AC9** Opening or liking another user's private post through its share link adds nothing.
**AC10** Opening a post from a notification adds it once; the check the notification centre makes before opening does not add it by itself.

### FR-275: Entry on the Saya page

- A new cell **"Riwayat"** in the AKTIVITAS card, right after **Pesanan Saya**. The card becomes: **Pesanan Saya · Riwayat · Koin & Jatah · (Paket Hemat)**. Paket Hemat stays last, so the first three cells never move when it hides.
- Same layout as the other cells: icon, name, one line of sub-text. Sub-text: "14 hari terakhir" (last 14 days).
- Guests: tapping it goes through login first, then opens Riwayat.
- With Paket Hemat on sale the row has four cells, about 80 dp each. Design checks that long English sub-text wraps cleanly (OQ-3).

**AC11** The AKTIVITAS card shows Pesanan Saya · Riwayat · Koin & Jatah, plus Paket Hemat at the end while it's on sale.
**AC12** A guest who taps Riwayat is asked to log in; after login, Riwayat opens.

### FR-276: The Riwayat page

- A separate page with a back button and the title "Riwayat".
- **Pills:** **Postingan** (default) · **Produk**.
- **Privacy line under the pills:** "Hanya kamu yang bisa melihat riwayatmu".
- **Order:** newest first, grouped under day headers: "Hari ini", "Kemarin", then dated headers such as "Senin, 16 Nov". The year is added only if it isn't the current year.
  - **Days follow WIB (Jakarta time) for every user**, whatever their phone's time zone (Hex, 2026-11-23).
  - **One header per day.** When a day's items span two loads, the next load continues under the same header.
- **Layout: two-column masonry (waterfall) in both pills.** Each day header spans the full width; under it, that day's items flow into two columns.
  - **Postingan:** the same `MasonryCard` as the Sosial feed. Tap opens the post. Liking from here is recorded like any other like (FR-274).
  - **Produk:** `ShopProductCard`, as in Toko, including the "Stok habis" label (V1.5.2 FR-229). Its 1:1 image and 2-line title make the cards the same height, so this pill looks like an even grid. Tap opens the product.
- **Loading:** 20 items at a time, more on scroll. The server returns only items that the user can still open (FR-279) and that were opened or liked within the last 14 days, so each load holds up to 20 visible items.
- **Refresh:** the list loads when the page opens and on pull-to-refresh.
  - Coming back from a post or product opened here keeps the list and scroll position as they were, even though that item has moved to the top on the server. The new order shows the next time the page opens or on pull-to-refresh.
  - The same holds for a like made on the page: the card's heart updates, its place doesn't.
- **Empty state (per pill), shown when the pill has no visible items:** "Belum ada riwayat" / "Yang kamu lihat akan muncul di sini."

**AC13** Riwayat opens on Postingan; the pills switch between Postingan and Produk.
**AC14** Items from today, yesterday and earlier appear under "Hari ini", "Kemarin" and a dated header, by WIB; a phone set to WITA shows the same headers as one set to WIB.
**AC15** When one day's items span two loads, its header appears once.
**AC16** A pill with no entries, or with only hidden entries (FR-279), shows the empty state and no "Hapus semua".
**AC17** Scrolling to the end loads the next 20.
**AC18** Opening the third item and coming back leaves it third, at the same scroll position; after pull-to-refresh it is at the top under "Hari ini".

### FR-277: How long and how many

- The list hides entries last opened or liked more than **14 days** ago (14 × 24 hours before the list loads), filtering them out when it loads. A nightly job then deletes them.
- Each user keeps at most **300 entries per pill**. Beyond that, the oldest entries in that pill are removed.

**AC19** An entry last opened 15 days ago doesn't appear, even before the nightly job has run.
**AC20** The 301st Postingan entry removes the oldest Postingan entry; Produk is not affected.

### FR-278: Removing history

- **Remove one:** long-press an item → **"Hapus dari riwayat"** → the item disappears at once and the toast "Dihapus dari riwayat" appears.
  - **Posts:** in the feed, long-press and the card's "⋯" both open the report flow. On Riwayat, both open one menu instead: **"Hapus dari riwayat"** and **"Laporkan"** (report, the existing flow). A post the user reports is then hidden (FR-279).
  - **Products:** `ShopProductCard` has no long-press today; on Riwayat, long-press opens a menu with only "Hapus dari riwayat".
- **Clear a pill:** a **"Hapus semua"** action on the right of the pill row (shown when the pill has visible items) clears **only the current pill**, including any hidden entries in it. It asks for confirmation first:
  - **Title:** "Hapus semua riwayat {pill}?"
  - **Body:** "Riwayat {pill} akan dihapus dan tidak bisa dikembalikan."
  - **Buttons:** **Hapus** / **Batal**.
- Removing doesn't block future recording: opening or liking the item again adds it back.
- There is no "pause history" switch.

**AC21** Long-press (or "⋯" on a post) → "Hapus dari riwayat" removes the item; it stays removed after reopening the page. On a post the same menu also offers "Laporkan".
**AC22** "Hapus semua" on Produk → Hapus empties Produk only; Postingan is unchanged.
**AC23** "Batal" changes nothing.
**AC24** After removing a post, opening it again adds it back.

### FR-279: Items that are gone

History is passive: the user never chose to keep these items, so anything they can no longer open is **hidden**, not shown as a dead row. Disimpan, by contrast, shows "Konten tidak tersedia lagi".

| Situation | In history |
|---|---|
| Post deleted, under review, or its author's account deleted or banned | Hidden |
| Post made private by its author after the user opened or liked it | Hidden |
| Post reported by the user | Hidden |
| A block between the user and the author, in either direction | Hidden |
| Product delisted | Hidden |
| Product sold out | **Shown**, with "Stok habis" |

- Availability is checked whenever the list loads, so it always follows the current state. When the cause goes away (block lifted, post approved or made public again, product relisted), the entry shows again if it is still within 14 days.
- Hidden entries still count toward the 300 limit until they age out. They are never shown, so a pill with only hidden entries shows the empty state and no "Hapus semua".

**AC25** After the author deletes a post or makes it private, it no longer appears and no placeholder is shown.
**AC26** After the user blocks someone, that person's posts disappear from history; after unblocking, they come back (within 14 days).
**AC27** If someone blocks the user, their posts disappear from the user's history.
**AC28** A delisted product disappears; a sold-out product stays with "Stok habis".

### FR-280: Storage, accounts and privacy

- **Stored on the server**, so history follows the account across phones and reinstalls. One row per user and item; opening or liking it again only updates the time.
- **Who can see it:** only the user. No API returns another user's history, and the admin console does not show it.
- **Logout or account switch:** the next account never sees the previous account's history. Entries are written by the server under the logged-in account, so nothing can cross accounts; the app only has to clear its cached list.
- **Account deletion:** all of the user's history is deleted.
- **Not used for anything else in 1.5.4:** no recommendations, ranking, view counts or "seen" badges (Albar, 2026-11-19).
- **Cost estimate** (dev to confirm). Only detail opens and post likes are recorded. With October DAU of about 500 to 1,100:
  - roughly 10k to 40k writes a day, well under 1 per second;
  - at most 600 rows per user (300 per pill), and only for users active in the last 14 days: tens of MB in practice;
  - one list query per page load and one nightly cleanup;
  - no new infrastructure.

**AC29** History made on phone A appears on phone B after logging in with the same account; after logging out and in as account B, only B's history is shown.
**AC30** After account deletion, the user's history is gone from the database, and no request made with another user's login can read it.

### FR-281: Tracking

All events go to our own server. For each event, register it in the event catalog, add the app constant, and make sure the comparison test passes. Nothing depends on PostHog. History recording itself is stored as server data, not sent as one event per open or like.

| Event | When | Properties |
|---|---|---|
| `browse_history_entry_tapped` | The Riwayat cell in AKTIVITAS tapped | `is_guest` |
| `browse_history_viewed` | Riwayat page opened, or pill switched. Not again when coming back from a post or product opened from Riwayat | `pill` (post / product), `is_empty` |
| `browse_history_item_opened` | An entry tapped | `pill`, `position` (from 1), `days_ago` (0–14) |
| `browse_history_item_removed` | "Hapus dari riwayat" | `pill` |
| `browse_history_cleared` | "Hapus semua" confirmed | `pill`, `item_count` (visible items cleared) |

**AC31** Each event fires once, at the moment listed, with the listed properties. Staging builds report to the staging data store and debug builds report nothing, as for all events today.

## 6. Non-goals

- History of user profiles, pet pages, topics, places or searches.
- Recording posts or products the user only scrolled past or stopped on without opening (or, for posts, liking).
- A pause / turn-off switch.
- Using history for recommendations, ranking or view counts.
- Showing other people what you viewed, or "seen" badges in the feed.
- Recording guests, or syncing guest history into an account.

## 7. Success

Success means shipping in 1.5.4, with AC1 to AC31 verified by QA. No metric target (Albar, 2026-11-19). The FR-281 events are kept so usage can be analysed later.

## 8. Open questions

| # | Question | Owner | Needed by |
|---|---|---|---|
| OQ-1 | Confirm the server-side approach and cost (FR-280), and the `[DEV]` points in Appendix B | Dev → Albar | Before development starts |
| OQ-2 | FR numbers re-checked 2026-11-20: V1.5.2 uses FR-225 to FR-259; KTP share link FR-260 to FR-267; mention FR-268 to FR-273; this PRD FR-274 to FR-281 (was FR-240 to FR-247). Next free number: FR-282. Re-check before merging to `PetGo` | Albar | Before merging to `PetGo` |
| OQ-3 | Riwayat cell icon and the four-cell AKTIVITAS layout | Design | UI mockup |
| OQ-4 | Approve the copy added on 2026-11-20 (Appendix A, rows marked ★): the AKTIVITAS cell and the page title | Albar | Before the UI mockup |

## Appendix A. Copy

Approved by Albar on 2026-11-19, except the rows marked ★ (added 2026-11-20, OQ-4).

| Place | Bahasa Indonesia | English |
|---|---|---|
| AKTIVITAS cell ★ | Riwayat / 14 hari terakhir | History / Last 14 days |
| Page title ★ | Riwayat | History |
| Pills | Postingan · Produk | Posts · Products |
| Privacy line | Hanya kamu yang bisa melihat riwayatmu | Only you can see your history |
| Day headers | Hari ini · Kemarin · Senin, 16 Nov | Today · Yesterday · Mon, 16 Nov |
| Empty | Belum ada riwayat / Yang kamu lihat akan muncul di sini. | No history yet / What you view will show up here. |
| Remove one | Hapus dari riwayat · toast: Dihapus dari riwayat | Remove from history · toast: Removed from history |
| Item menu (post) | Hapus dari riwayat · Laporkan (existing report label) | Remove from history · Report |
| Clear pill | Hapus semua → Hapus semua riwayat {pill}? / Riwayat {pill} akan dihapus dan tidak bisa dikembalikan. / Hapus · Batal | Clear all → Clear all {pill} history? / Your {pill} history will be deleted. This can't be undone. / Clear · Cancel |
| Sold out (existing, V1.5.2) | Stok habis | Out of stock |

## Appendix B. Notes for developers

Paths are at `origin/stag` `f0d02163b`.

- **Pattern to copy for storage and paging:** Disimpan.
  - App: `features/collect/` (`collect_repository.dart`, `collection_list_controller.dart`).
  - Backend: `collect/service/MyCollectionQuery.java` (keyset paging, batched, no N+1) and `collect/service/CollectVisibility.java` (both-direction block check, reuse for FR-279).
- **Entry:** `features/me/presentation/me_page.dart` `_ActivitySection` (~L506): add an `_ActivityCell` after `meOrders`.
- **Layout:**
  - Postingan: `shared/widgets/masonry_card.dart` (`MasonryCard`), as used by `FeedMasonryView` in `features/content/presentation/feed_view.dart`, with full-width day headers between sections.
  - Produk: `ShopProductCard` (`features/shop/presentation/widgets/shop_product_card.dart`). It opens the product with `?from={entrySource}`; give Riwayat its own value (e.g. `HISTORY`) so purchases from history can be told apart.
  - Coming back from a detail page must not re-fetch the list (FR-276 Refresh).
  - `MasonryCard` takes `onLongPress` and `onMore`; the feed pages (`home_page.dart`, `following_tab_view.dart`, `topic_page.dart`) pass `openReport` to both. Riwayat passes the FR-278 menu to both instead.
- **Recording points (server):**
  - **Post open:** `content/web/ContentDetailController.java` `detail` (L46-58) already records a view only on a successful, non-author open, and skips it when `countView=false` (the notification-centre check). Write the history entry on the same path, and skip private posts (V1.5.2 FR-241). `[DEV]` Confirm no other app path calls the post detail API without the user opening the post (e.g. prefetch).
  - **Post like:** `content/web/LikeController.java` `POST /api/v1/content-posts/{id}/like`: write the entry on success; skip the author and private posts. `DELETE` (unlike) leaves it.
  - **Product open:** `shop/web/ShopProductController.java` `detail` (`GET /api/v1/shop/products/{token}`) is open to guests and doesn't read the viewer today. Read the optional viewer the same way `shippingEstimate` does (role=USER only). `[DEV]` The add-to-cart sheet (`sku_picker_sheet.dart`) also loads this API through `shopProductDetailProvider`; add a flag like `countView` so only `product_detail_page_v3.dart` records.
- **Storage suggestion:** a new table `browse_history(user_id, kind, target_id, last_viewed_at)`, unique `(user_id, kind, target_id)`, index `(user_id, kind, last_viewed_at DESC, id DESC)`, upsert on open or like, written asynchronously. Don't reuse `content_post_views`: it has no viewer index, it's kept after account deletion, and it covers posts only. Don't reuse the V1.5.2 Toko "seen" record either (§4).
- **Day headers:** group by `last_viewed_at` converted to WIB (UTC+7) on the server or in the app, never by the phone's time zone.
- **Gone states:**
  - posts: `ContentDetailService.requireVisiblePost` (plus the V1.5.2 visibility check);
  - products: `is_active` / 410 `product-delisted`; sold-out flag from the V1.5.2 list API.
- **Account change:** register the history list provider in `resetUserScopedCaches` (`app.dart` ~L389-470). Delete rows on account deletion, like `CollectDeletionService`.
- **Events:** `petgo-backend/src/main/resources/analytics/event-catalog.yaml`, `core/analytics/event_names.dart`.

## Change log

| Date | Who | Change |
|---|---|---|
| 2026-11-19 | Albar | First draft: FR-240 to FR-247 (now FR-274 to FR-281), AC1 to AC30. Decisions from the coaching session on 2026-11-19. |
| 2026-11-19 | Albar | Review pass: ACs rewritten and renumbered AC1 to AC33; date and UJ-2 fixed. |
| 2026-11-19 | Albar | Search results count only when a post is opened. Storage question goes to dev after Hex's review. |
| 2026-11-20 | Hex | Renumbered FR-240–247 → FR-274–281 (1.5.2, KTP share link and mention PRDs took the earlier numbers; OQ-2 corrected); frontmatter fixed. No rule changes. |
| 2026-11-20 | Hex | Merge order with the other 1.5.4 PRDs added to §0. No rule changes. |
| 2026-11-20 | Hex | Review: only detail opens are recorded, by the server; Profil pill removed (posts and products only); 14 days (14 × 24 hours) and 300 per pill; entry moved to a cell in the AKTIVITAS card that opens a separate Riwayat page; private posts hidden and never recorded; recent-search section removed; aligned with V1.5.2 PRDs (Stok habis, `ShopProductCard`, private posts, Toko "seen" record); Riwayat entry source for product opens. |
| 2026-11-23 | Hex | Liking a post also records it (server-side, unlike keeps it); two-column masonry in both pills (`MasonryCard` / `ShopProductCard`); list keeps its order when coming back from an item, updates on reopen or pull-to-refresh; one header per day across loads; days by WIB for every user; posts and products opened from banners are recorded; empty-state body back to the approved "Yang kamu lihat…". Now AC1 to AC31 (AC31 = events). Final check: on Riwayat, a post's long-press and "⋯" open one menu (Hapus dari riwayat · Laporkan) instead of the feed's report flow. |
| 2026-11-23 | Hex | Final: PRD signed off by Hex (status: final). OQ-1 (dev), OQ-3 (design) and OQ-4 (Albar, copy) stay open and are handled before development / the UI mockup. |
