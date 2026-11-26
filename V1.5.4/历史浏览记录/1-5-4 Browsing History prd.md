---
title: "Browsing History"
status: final
created: 2026-11-19
updated: 2026-11-24
---

# PRD: TailTopia Pet App — Browsing History (V1.5.4)

## 0. About this document

- **What this is:** a new **Riwayat** (history) page, opened from the AKTIVITAS card on the Saya page. It lists the posts the user opened or liked and the Toko products they opened in the last 14 days, so they can get back to them.
- **Who it is for:** product (Albar, Hex), Dai's backend and app developers, design, QA.
- **Release:** V1.5.4 (date not set).
- **Source:** Roadmap V1.5.4 "历史浏览记录" (added 2026-11-12) and the brief for 1.5.4.
- **Code baseline:** `petgo-platform` `origin/stag` `f0d02163b` (V1.5.0; merged to `main` 2026-11-19). V1.5.2 is not developed yet, so the V1.5.2 changes this PRD relies on are taken from the V1.5.2 PRDs (listed in §4).
- **Merge order (1.5.4, Hex 2026-11-20):** all three 1.5.4 PRDs (KTP share link, mention nickname, browsing history) build on 1.5.2 and merge after it. Shared code: the one push/notification destination function that 1.5.2 FR-244 creates. The mention PRD adds the comment-ID case (FR-270) and merges first; the KTP PRD adds the card-link route (FR-263) and rebases on it. Browsing history doesn't touch that function: it adds a cell to the Saya page's AKTIVITAS card, a new Riwayat page, and recording inside the server's post detail, post like and product detail APIs. It doesn't change the app's post detail page, so it can merge any time after 1.5.2.
- **Numbering:** **FR-274 to FR-281**, **AC1 to AC31**. V1.5.2 uses FR-226 to FR-259; the KTP share link PRD uses FR-260 to FR-267 and the mention PRD FR-268 to FR-273, so this PRD starts at FR-274 (OQ-2).
- **UI design:** `V1.5.4/历史浏览记录/ui-1-5-4-browsing-history-integrated-v1.html` (28 screens; **final 2026-11-24**, reviewed by Albar 2026-11-23, confirmed by Hex 2026-11-24). One file per screen in `V1.5.4/历史浏览记录/拆页-App/` (start at `00-目录.html`); developer notes are in the integrated deck's header.
- **Markers:** decisions are Albar's (2026-11-19, from the coaching session) and Hex's (2026-11-20 and 2026-11-23, logged in `V1.5.4/.decision-log.md`). `[DEV]` = dev to confirm.

## 1. Why

People open or like posts and look at products without saving them. Later they want them back and can't find them: the feed has moved on, and nothing records what they saw.

A "recently viewed" list is a basic expectation, especially for shopping. It gives every half-remembered post or product a second chance to turn into a save, a follow or a purchase.

**Goal:** a user can find a post they opened or liked, or a product they opened, in the last 14 days in a few taps, even if they never saved it.

## 2. User journeys

**UJ-1. Rina finds the post she read.**
Rina, 24, lives in Depok with two cats.

1. On Monday night she opens a post about a DIY cat scratcher from the Sosial feed, reads it and moves on.
2. On Wednesday she wants to build one. She goes to **Saya → Riwayat → Postingan**, and finds the post a little way down the list.
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
- **The Sosial feed** is a single column of full-width `MasonryCard`s (since V1.1.6 FR-93; images bleed to the screen edges). Despite its name, `MasonryCard` is not a two-column card and isn't reused on Riwayat.
- **Profile post grids** (Saya and other users' profiles) use `PostGridTile`: a square two-column tile with a type badge, but no text, author or like.
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
- **One entry per item.** Opening or liking it again updates the time and moves it to the top of the list.
- **Time of an entry:** the server's time of the open or like.
- Recording never slows a page or a like down. If saving fails, the user sees no error.

**AC1** Opening another user's post adds it to the top of Postingan.
**AC2** Scrolling past a post in the Sosial feed, or stopping on it without opening or liking it, adds nothing.
**AC3** Liking a post in the Sosial feed (heart or double-tap) without opening it adds it to Postingan; unliking it afterwards leaves the entry.
**AC4** Opening a post from a profile grid, Diary or search results adds that post.
**AC5** Opening a product detail, including from a banner, adds it to Produk. Toko list cards and the add-to-cart sheet do not.
**AC6** The user's own posts never appear, even after the user likes one.
**AC7** A guest's browsing records nothing: after logging in, none of the posts or products opened as a guest are in history.
**AC8** Opening the same post on Monday and liking it on Wednesday leaves one entry, placed by Wednesday's like.
**AC9** Opening or liking another user's private post through its share link adds nothing.
**AC10** Opening a post from a notification adds it once; the check the notification centre makes before opening does not add it by itself.

### FR-275: Entry on the Saya page

- A new cell **"Riwayat"** in the AKTIVITAS card, right after the orders cell. The card becomes: **Pesanan · Riwayat · Koin · (Paket Hemat)**. Paket Hemat stays last, so the first three cells never move when it hides.
- **Shorter titles on this card** (Hex, 2026-11-24): the orders cell title "Pesanan Saya" becomes **"Pesanan"** and the coin cell title "Koin & Jatah" becomes **"Koin"**, with three or four cells alike. Only this card changes: use new copy keys, since `orderMyTitle` and `meCoinJatah` are used elsewhere (the orders page and the Koin & Jatah page keep their titles). Sub-texts stay as they are.
- Same layout as the other cells: icon, name, one line of sub-text. Sub-text: "14 hari" (14 days). Icon: Material Rounded `history`.
- **Guests never see this cell.** In the app a guest can't open the Saya page: tapping the Saya tab opens the existing login dialog ("Fitur ini perlu akun", `login_hard_dialog`). No extra login step is needed here. After login the user lands on Saya, not Riwayat.
- **Always one row** (Albar, 2026-11-23). With Paket Hemat on sale the row has four cells, about 80 dp each, at the same text size as three cells (title 13, sub-text 11). **With four cells the cell content is top-aligned** (Hex, 2026-11-24), so the four icons sit at the same height and the titles start on the same line. "Paket Hemat" and the longer sub-texts may wrap to two lines instead of being cut off; "17 jatah" is kept together with a non-breaking space (UI mockup A2).
- **Same card height with three or four cells** (Albar, 2026-11-24). The card's minimum height goes from 86 to 112 dp, the four-cell height once text wraps. With three cells the cell content is centred vertically (UI mockup A1). This way nothing below the card shifts when Paket Hemat comes and goes. The card can still grow for large system text, as today.

**AC11** The AKTIVITAS card shows Pesanan · Riwayat · Koin in one row, plus Paket Hemat at the end while it's on sale. With four cells, the icons are at the same height, titles start on the same line, and no title or sub-text is cut off. The card is the same height with three or four cells.
**AC12** A guest can't reach the Riwayat cell: tapping the Saya tab opens the existing login dialog. After logging in, the user lands on Saya and the Riwayat cell is there.

### FR-276: The Riwayat page

- A separate page with a back button and the title "Riwayat".
- **Pills:** **Postingan** (default) · **Produk**.
- **Privacy line under the pills:** "Hanya kamu yang bisa melihat riwayatmu".
- **Order:** newest first (by the last open or like), as one continuous list. **No day headers or dates** (Albar, 2026-11-23): grouping by day left uneven gaps in the two-column layout.
- **Layout: two-column masonry (waterfall) in both pills.** Items flow continuously into two columns, each new item going into the shorter column; the next load continues the same list. When an item is removed (removal, report), the items after it re-flow by the same rule, so some may switch columns (UI mockups D2, D7).
  - **Postingan:** a **new two-column post tile** (no existing component fits: `MasonryCard` is full-width, and `PostGridTile` has no text, author or like). Top to bottom:
    - **Cover:** the post's first image at its original aspect ratio, kept within the feed's 0.75 to 1.78 range (V1.1.6 FR-71). Posts with no stored image size (published before V1.1.6) use 1:1.
    - **Text:** up to 2 lines of the post text, cut off with "…".
    - **Footer:** author avatar and name (one line, cut off with "…") on the left; like button (heart and count) on the right.
    - **"⋯"** on the tile. It and long-press both open the Riwayat menu (FR-278).
    - **No image:** a text block replaces the cover: the post text on the type's cover colour, up to 6 lines (UI mockup B1). The 2-line text under it is left out, so the text isn't shown twice.
    - **No text** (26% of public posts): cover and footer only. No empty space is left for the text.
    - **Neither:** the type's cover colour and emoji, as in `PostGridTile`.
    - **Style:** follows `PostGridTile`: the same corner radius and type badge (top-left, same colours per type).
    - Tapping the tile opens the post. The heart likes in place, without opening it, and tapping it again unlikes (UI mockup B7, B8). Liking from here is recorded like any other like (FR-274); unliking keeps the post in Riwayat.
  - **Produk:** `ShopProductCard`, as in Toko, including the "Stok habis" label (V1.5.2 FR-229). Its 1:1 image and 2-line title make the cards the same height, so this pill looks like an even grid. Tap opens the product. **No "+" add-to-cart button on Riwayat** (Albar, 2026-11-23): the cart lives in Toko, so here a card only opens the product.
- **Loading:** 20 items at a time, more on scroll. The server returns only items that the user can still open (FR-279) and that were opened or liked within the last 14 days, so each load holds up to 20 visible items.
- **Refresh:** the list loads when the page opens and on pull-to-refresh.
  - Coming back from a post or product opened here keeps the list and scroll position as they were, even though that item has moved to the top on the server. The new order shows the next time the page opens or on pull-to-refresh.
  - The same holds for a like made on the page: the card's heart updates, its place doesn't.
- **Empty state (per pill), shown when the pill has no visible items:** "Belum ada riwayat" / "Yang kamu lihat akan muncul di sini."

**AC13** Riwayat opens on Postingan; the pills switch between Postingan and Produk. Product cards on Riwayat show no "+" button.
**AC14** Items appear newest first in one continuous list, with no day headers or dates.
**AC15** The next load continues the same list, with no gap, header or repeated item.
**AC16** A pill with no entries, or with only hidden entries (FR-279), shows the empty state and no "Hapus semua".
**AC17** Scrolling to the end loads the next 20.
**AC18** Opening the third item and coming back leaves it third, at the same scroll position; after pull-to-refresh it is at the top. Liking a post on Riwayat turns its heart red and adds 1 without moving the card; tapping again unlikes it, and the post stays in the list.

### FR-277: How long and how many

- The list hides entries last opened or liked more than **14 days** ago (14 × 24 hours before the list loads), filtering them out when it loads. A nightly job then deletes them.
- Each user keeps at most **300 entries per pill**. Beyond that, the oldest entries in that pill are removed.

**AC19** An entry last opened 15 days ago doesn't appear, even before the nightly job has run.
**AC20** The 301st Postingan entry removes the oldest Postingan entry; Produk is not affected.

### FR-278: Removing history

- **Remove one:** long-press an item → **"Hapus dari riwayat"** → the item disappears at once and the toast "Dihapus dari riwayat" appears.
  - **Posts:** in the feed, long-press and the card's "⋯" both open the report flow. On Riwayat, both open one menu instead: **"Hapus dari riwayat"** and **"Laporkan"** (report, the existing flow). A post the user reports is then hidden (FR-279). As in the feed, once the report's success state is closed the post leaves the list at once and the existing message "Kamu tidak akan melihat konten ini lagi" shows (UI mockup D7).
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
| OQ-2 | FR numbers re-checked 2026-11-23 against `PetGo` `main` `991e901` (all branches): V1.5.2 uses FR-226 to FR-259 (FR-225 is the last V1.5.0 number), and no doc uses FR-260 or higher. KTP share link FR-260 to FR-267; mention FR-268 to FR-273; this PRD FR-274 to FR-281 (was FR-240 to FR-247). Next free number: FR-282. ⚠️ The Roadmap's 1.5.2 note (2026-11-20) still says "next free FR-260" and leaves two 1.5.2 items undecided (monthly level shop coupon, vet page redesign); if either gets FRs, they must start at FR-282. Re-check before merging to `PetGo` | Albar | Before merging to `PetGo` |
| ~~OQ-3~~ | ~~Riwayat cell icon and the four-cell AKTIVITAS layout~~ **Closed 2026-11-23 (Albar, UI mockup): icon `history`; always one row, titles and sub-text may wrap to two lines with four cells; same card height with three or four cells (FR-275).** | Design | Done |
| ~~OQ-4~~ | ~~Approve the copy added on 2026-11-20 (AKTIVITAS cell and page title)~~ **Closed 2026-11-23: approved by Albar.** | Albar | Done |

## Appendix A. Copy

All copy approved by Albar (2026-11-19; the AKTIVITAS cell and page title on 2026-11-23); the shortened AKTIVITAS copy ("Pesanan", "Koin", "14 hari") approved by Hex on 2026-11-24.

| Place | Bahasa Indonesia | English |
|---|---|---|
| AKTIVITAS cell | Riwayat / 14 hari | History / 14 days |
| AKTIVITAS orders title (new key, this card only; Hex 2026-11-24) | Pesanan | Orders |
| AKTIVITAS coin title (new key, this card only; Hex 2026-11-24) | Koin | Coins |
| Page title | Riwayat | History |
| Pills | Postingan · Produk | Posts · Products |
| Privacy line | Hanya kamu yang bisa melihat riwayatmu | Only you can see your history |
| Empty | Belum ada riwayat / Yang kamu lihat akan muncul di sini. | No history yet / What you view will show up here. |
| Remove one | Hapus dari riwayat · toast: Dihapus dari riwayat | Remove from history · toast: Removed from history |
| Item menu (post) | Hapus dari riwayat · Laporkan (existing report label) | Remove from history · Report |
| Clear pill (in the app's bottom confirm sheet, `showConfirmSheet`, danger style) | Hapus semua → Hapus semua riwayat {pill}? / Riwayat {pill} akan dihapus dan tidak bisa dikembalikan. / Hapus · Batal | Clear all → Clear all {pill} history? / Your {pill} history will be deleted. This can't be undone. / Clear · Cancel |
| Sold out (existing, V1.5.2) | Stok habis | Out of stock |
| After reporting a post (existing `reportHiddenToast`, as in the feed) | Kamu tidak akan melihat konten ini lagi | You won't see this content anymore |
| Load failed (existing, as in Disimpan) | Gagal memuat / Periksa koneksi lalu coba lagi. / Coba lagi | Couldn't load / Check your connection and try again. / Try again |
| Remove or clear failed (existing `contentDeleteFailed`; toast at the top, as in Disimpan; the list doesn't change) | Gagal menghapus, silakan coba lagi | Could not delete, please try again |

## Appendix B. Notes for developers

Paths are at `origin/stag` `f0d02163b`.

- **Pattern to copy for storage and paging:** Disimpan.
  - App: `features/collect/` (`collect_repository.dart`, `collection_list_controller.dart`).
  - Backend: `collect/service/MyCollectionQuery.java` (keyset paging, batched, no N+1) and `collect/service/CollectVisibility.java` (both-direction block check, reuse for FR-279).
- **Entry:** `features/me/presentation/me_page.dart` `_ActivitySection` (~L506): add an `_ActivityCell` after `meOrders`.
- **Layout:**
  - Postingan: a new tile (FR-276), laid out in two masonry columns as one continuous list (no day headers). Don't use `shared/widgets/masonry_card.dart` (`MasonryCard`): since V1.1.6 FR-93 it is the single-column full-width feed card. Reuse the parts:
    - `PostGridTile.badgeStyle` (`shared/widgets/post_grid_tile.dart`) for the badge, with radius 11 as in that tile; `PostCoverPlaceholder` (`post_cover.dart`) for the type colours.
    - `clampFeedRatio` and `kFeedPlaceholderRatio` (`features/content/domain/feed_image_layout.dart`) with `FeedItem.imageSizes` for the cover ratio.
    - `LetterAvatar` for the author.
    - `LikeButton` (`features/content/presentation/like_button.dart`) with its own `likersSource` (e.g. `history`).
    - The feed's preview-text helper (`shared/utils/preview_text.dart`) for the text, so mentions and markup show as in the feed.
  - Produk: `ShopProductCard` (`features/shop/presentation/widgets/shop_product_card.dart`). It opens the product with `?from={entrySource}`; give Riwayat its own value (e.g. `HISTORY`) so purchases from history can be told apart. On Riwayat the card's "+" is hidden; the card needs an option for that.
  - Coming back from a detail page must not re-fetch the list (FR-276 Refresh).
  - In the feed, `MasonryCard`'s `onLongPress` and `onMore` both get `openReport` (`home_page.dart`, `following_tab_view.dart`, `topic_page.dart`). On Riwayat, the new tile's long-press and "⋯" both open the FR-278 menu instead.
- **Recording points (server):**
  - **Post open:** `content/web/ContentDetailController.java` `detail` (L46-58) already records a view only on a successful, non-author open, and skips it when `countView=false` (the notification-centre check). Write the history entry on the same path, and skip private posts (V1.5.2 FR-241). `[DEV]` Confirm no other app path calls the post detail API without the user opening the post (e.g. prefetch).
  - **Post like:** `content/web/LikeController.java` `POST /api/v1/content-posts/{id}/like`: write the entry on success; skip the author and private posts. `DELETE` (unlike) leaves it.
  - **Product open:** `shop/web/ShopProductController.java` `detail` (`GET /api/v1/shop/products/{token}`) is open to guests and doesn't read the viewer today. Read the optional viewer the same way `shippingEstimate` does (role=USER only). `[DEV]` The add-to-cart sheet (`sku_picker_sheet.dart`) also loads this API through `shopProductDetailProvider`; add a flag like `countView` so only `product_detail_page_v3.dart` records.
- **Storage suggestion:** a new table `browse_history(user_id, kind, target_id, last_viewed_at)`, unique `(user_id, kind, target_id)`, index `(user_id, kind, last_viewed_at DESC, id DESC)`, upsert on open or like, written asynchronously. Don't reuse `content_post_views`: it has no viewer index, it's kept after account deletion, and it covers posts only. Don't reuse the V1.5.2 Toko "seen" record either (§4).
- **Gone states:**
  - posts: `ContentDetailService.requireVisiblePost` (plus the V1.5.2 visibility check);
  - products: `is_active` / 410 `product-delisted`; sold-out flag from the V1.5.2 list API.
- **Account change:** register the history list provider in `resetUserScopedCaches` (`app.dart` ~L389-470). Delete rows on account deletion, like `CollectDeletionService`.
- **Events:** `petgo-backend/src/main/resources/analytics/event-catalog.yaml`, `core/analytics/event_names.dart`.
- **Copy keys:**
  - Reuse: `profilePostsTitle` (Postingan pill), `commentActionReport`, `commonCancel`, `collectLoadFailedTitle` / `collectLoadFailedHint` / `commonRetry`, `contentDeleteFailed`.
  - New: the **"Produk" pill** (no existing key for this use); the AKTIVITAS orders and coin titles **"Pesanan"** / **"Koin"** (don't change `orderMyTitle` / `meCoinJatah`, which other pages use); plus the other new copy in Appendix A.

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
| 2026-11-23 | Albar | OQ-4 closed: AKTIVITAS cell "Riwayat / 14 hari terakhir" and page title "Riwayat" approved; all copy now approved. |
| 2026-11-23 | Albar | Fix: `MasonryCard` is the single-column full-width feed card (V1.1.6 FR-93), not a two-column card, so Postingan can't reuse it. FR-276 now specs a new two-column post tile: cover at its original ratio (feed range 0.75 to 1.78, 1:1 if size unknown), 2-line text, author avatar and name, like button, "⋯"; text block for posts with no image; cover only for posts with no text; style follows `PostGridTile`. §4 and Appendix B updated. Two columns in both pills, the like rule and the FR-278 menu are unchanged. |
| 2026-11-23 | Albar | UI design reviewed by Albar, awaiting Hex's confirmation (§0 link). From the mockup:<br>- **FR-275 / AC12:** guests can't open the Saya page, so they never see the Riwayat cell (existing login dialog).<br>- **FR-275 / AC11:** AKTIVITAS is always one row; with four cells, titles and sub-text may wrap to two lines.<br>- **OQ-3 closed:** icon `history`.<br>- **FR-276:** the text block shows up to 6 lines.<br>- **Appendix A:** failure states reuse existing copy, and the clear confirmation uses the bottom confirm sheet.<br>- **Appendix B:** copy keys, including a new key for the "Produk" pill.<br>No other rule changes. Hex signed off the PRD earlier the same day. |
| 2026-11-23 | Albar | **FR-276 / AC13 / Appendix B:** product cards on Riwayat have no "+" add-to-cart button (the cart lives in Toko). **FR-276 / AC18:** liking and unliking on Riwayat are stated explicitly (mockup B7, B8; the deck now has 21 screens). Like/unlike stays because Hex's revision already has likes on Riwayat; unlike was implied by the reused like button. Both decided by Albar. |
| 2026-11-23 | Albar | Every case the mockup had covered with "same as" now has its own screen (28 in total). **FR-278 / Appendix A:** after a report, the post leaves the list at once with the feed's existing message "Kamu tidak akan melihat konten ini lagi" (mockup D7). No other rule changes. |
| 2026-11-23 | Albar | **Day headers removed** (FR-276, AC14, AC15; Appendix A and B): grouping by day left uneven gaps in the two-column layout, so both pills are now one continuous list, newest first, with no dates. This replaces Hex's "days by WIB" and "one header per day" rules. Wording that referred to headers (UJ-1, FR-274, AC1, AC8, AC18) was updated to match. FR-281's `days_ago` is unchanged. |
| 2026-11-24 | Albar | **FR-275 / AC11 / OQ-3:** the AKTIVITAS card is the same height with three or four cells (minimum height 86 → 112 dp; three cells centred vertically), so nothing shifts when Paket Hemat comes and goes. **FR-276:** after a removal or report, the items after it re-flow into the shorter column, so some may switch columns (mockups D2, D7). |
| 2026-11-24 | Hex | **FR-275 / AC11 / Appendix A and B:** AKTIVITAS titles shortened to "Pesanan" and "Koin" (new keys, this card only) and the Riwayat sub-text to "14 hari"; with four cells the content is top-aligned at full text size (13 / 11) instead of shrinking to 12 / 10.5, so the icons line up. Measured: about 76 dp of text per cell; "Paket Hemat" (85) and the longer sub-texts still wrap to two lines. Copy approved by Hex the same day. |
| 2026-11-24 | Hex | UI design final ("文案没问题，定稿这份"); split into `拆页-App/` (28 screens) with developer notes in the deck header; §0 link now points to this repo. |
