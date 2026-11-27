---
title: "Pet ID Card Share Links"
status: final
created: 2026-11-19
updated: 2026-11-24
---

# PRD: TailTopia Pet App — Pet ID Card Share Links (V1.5.4)

## 0. About this document

- **What this is:** pet ID cards (KTP, Paspor, SIM, KITAS and the student cards) are shared **as a link instead of an image**.

    - If the recipient has the app, the link opens that card in the app.

    - If they don't, a light web page shows a watermarked card and a download button. After installing, the first open goes to card creation.

    - The link points to the card and its pet's internal ID, never to the number printed on the card.

- **Also in scope: 4 new card styles.** A new-look KTP, SIM, Paspor and KITAS are added as 4 new styles next to the existing 8, so there are **12 styles** after 1.5.4.
- **Who it is for:** product (Albar, Hex), Dai's backend and app developers, design, QA.

- **Release:** V1.5.4 (date not set).

- **Source specs:** V1.1.0 PRD FR-49A (serial numbers can be reused, so links bind to the internal ID) and FR-49C (link sharing as a growth channel, 2026-07-07). Where they differ, this PRD wins. In particular, recipients can **no longer** edit or buy HD for someone else's card (FR-263).

- **Code baseline:** `petgo-platform` `origin/main` `ca55416d9` (V1.5.0, live), checked 2026-11-20. 1.5.2 isn't developed yet; its changes that touch this PRD come from the 1.5.2 PRDs (§4).

- **Merge order (1.5.4, Hex 2026-11-20):** all three 1.5.4 PRDs (KTP share link, mention nickname, browsing history) build on 1.5.2 and merge after it. Shared code: the one push/notification destination function that 1.5.2 FR-244 creates. The mention PRD adds the comment-ID case (FR-270) and merges first; the KTP PRD adds the card-link route (FR-263) and rebases on it. Browsing history doesn't touch that function: it adds a cell to the Saya page's AKTIVITAS card, a new Riwayat page, and recording inside the server's post detail, post like and product detail APIs. It doesn't change the app's post detail page, so it can merge any time after 1.5.2.

- **Numbering:** **FR-260 to FR-267**, **AC1 to AC48**. V1.5.2 uses FR-226 to FR-259; this PRD starts at FR-260, followed by the mention PRD (FR-268 to FR-273) and the browsing-history PRD (FR-274 to FR-281). Next free number: FR-282 (OQ-3).

- **Markers:** decisions are Albar's from 2026-11-19 (log in `.memlog.md`) unless marked (Hex, date). `[DESIGN]` = left to the designer's final exploration.

- **UI design:** `V1.5.4/KTP分享链接/ui-1-5-4-ktp-share-link-integrated-v1.html` (31 screens; steps 1–4 by Albar, landing pages redesigned by Hex; **final 2026-11-24**). One file per screen in `V1.5.4/KTP分享链接/拆页-App/` (start at `00-目录.html`); developer notes in the deck header. Its design decisions replace the `[DESIGN]` markers in the FRs; the full list is in the change log (2026-11-24, Albar).

## 1. Why

The ID card is one of the most shared things in TailTopia, but today it leaves the app as a picture. A picture brings nobody back: the recipient can't tap it, may not notice it came from TailTopia, and can't make their own.

A link turns every share into an acquisition channel:

- a friend who has the app lands on the card;

- a friend who doesn't sees it on a web page, taps download, and lands on card creation after installing;

- both are one tap away from making a card for their own pet.

V1.1.0 specified this in July (FR-49C). It was never built.

**Goal:** card shares bring new users in and send existing users back to the app. **Success:** measure the funnel (shares → link opens → store taps → sign-ups); targets are set after 2 weeks live (§7).

## 2. User journeys

**UJ-1. Dimas shares Mochi's KTP.**
Dimas, 26, lives in Bekasi with his cat Mochi. Last week he made Mochi a card in the new KTP style.

1. He goes to Diary, taps the **Kartu Identitas** tile (the Diary header gets four tiles in 1.5.2) → Kartuku and opens Mochi's KTP.

2. He taps **Bagikan**, picks WhatsApp and sends it to his group "Anak Kos".

3. The chat shows a link with Mochi's watermarked card as the preview, and the caption *"Kenalan yuk sama Mochi! 🐾 Ini kartu identitasnya di TailTopia: …"*.

4. If this is his first share for Mochi, he gets the share reward (once per pet, as today).

**UJ-2. Ayu doesn't have the app.**

1. Ayu taps the link in WhatsApp. Her browser opens a light page with Mochi's watermarked card, "Kartu Identitas Mochi" and **Buat kartu untuk hewanmu**.

2. She taps the button, goes to the Play Store and installs TailTopia.

3. On first open she signs up and creates her dog's profile in the sign-up onboarding; then card creation opens.

4. She makes a card for her dog.

**UJ-3. Raka already has the app.**

1. Raka taps the same link. TailTopia opens directly on Mochi's card, with no web page in between.

2. He taps **Lihat profil Mochi** and lands on Mochi's pet page.

## 3. Glossary

- **Card:** an ID card the owner created under Kartu Identitas. There are 8 styles today: KTP, Paspor, SIM, KITAS, and student cards in 4 colours. 1.5.4 adds 4 (FR-261), making 12.

    - A card is a **snapshot**: it keeps the name, breed, birthday and photo entered at creation, and pet profile edits don't change it.

    - Creating a card is free; the HD unlock is paid per card. The price is the admin setting `id_hd_download_price`, currently Rp1,000.

- **New styles:** the 4 styles added in 1.5.4: new-look KTP, SIM, Paspor and KITAS (FR-261). Each is a style in its own right, like each student colour.

- **Pet profile ID:** the internal key of a pet profile. It is never reused.

- **Card number** and **serial:** the card number is the number printed on the card (e.g. `TT230326020110`; Paspor shows a passport number). It is built partly from the pet's **serial**, the platform-wide number each pet profile gets (V1.1.0 FR-49A). When a pet is deleted, its serial goes back to the pool and can be given to a new pet. Both are display only, so **neither ever identifies a link**.

- **Card link:** `https://s.tailtopia.id/k/{token}`. The path is a suggestion; dev decides. The token is random and unguessable and maps on the server to one card; the card points to its pet profile ID (FR-260).

- **Landing page:** the web page at the card link, shown when the app doesn't open.

- **Visitor card page:** the new in-app page that shows someone else's card from a link.

- **Deferred deep link:** after someone taps a link, installs, and opens the app for the first time, the app opens a page chosen for that link. For card links this is card creation (FR-265).

## 4. What exists today (code, `origin/main` `ca55416d9`, V1.5.0)

- **Cards aren't tied to a pet.** In the creation form the user picks one of their pets, but that only **pre-fills** the fields (name, breed, birthday, photo), and everything stays editable. The pet is not stored with the card. This was a deliberate design rule (V1.4.0, "卡不挂宠物"). An account can have several cards for the same pet.

    - **Neither the backend nor the app requires a pet.** The create request has no pet field and `IdCardService` has no pet check (`CreateIdCardRequest` comment: "卡信息与档案解耦"); this holds for `POST /me/id-cards/v2` and for the old `POST /me/id-cards` kept for apps 1.3.3 and older. In the app, `_guardKtpEntry` only blocks when the current pet is read-only and the account has no active pet; **an account with no pet at all goes straight to the form**.

- **Styles:** 8, defined by card type + student colour (`IdCardType` KTP / PASSPORT / KITAS / SIM / STUDENT; `StudentVariant` × 4). HD credits are per style (`CreditType` `KTP_HD:*`, 8 values plus `ANY`). The value pack grants one of each through `CreditType.ktpTemplates()`, which lists **every** per-style credit, so new styles join the value pack automatically unless excluded.

- **Sharing:**

    - **What is sent:** a PNG image only, with no text and no link.

    - **Unpaid cards:** the shared image is watermarked and cut to 1/8 resolution (change of 2026-11-13).

    - **Paid cards:** the image is shared clean.

    - **After the first share** for a pet, the owner gets the once-per-pet share reward.

- **Card backs and the QR code were removed** on 2026-07-17. All cards are front-only.

- **Deep links:**

    - **What exists:** only the custom scheme `tailtopia://`.

    - **What's missing:** no App Links (Android) or Universal Links (iOS), so tapping an https link never opens the app directly, and no deferred deep link.

    - **AppsFlyer:** installed, but its deep-link feature is off.

- **Pages to reuse:**

    - **Pet card page `/p/{cardToken}`** on `s.tailtopia.id`: served by the backend, unguessable token, "try the app, otherwise go to the store" button, our own tracking, and one 404 page for unknown and deleted links.

    - **Card routes:** everything under `/profile` (including the card pages) requires login.

- **Changes coming in 1.5.2** (not developed yet; from the 1.5.2 PRDs):

    - **Card entry:** the Diary header becomes four tiles; **Kartu Identitas** opens the card page directly, and the "ID card moved" coach mark (`ktpMovedCoachmark`) is retired.

    - **Other people's pet page** (`VisitorArchiveView`, where "Lihat profil {petName}" lands) is redesigned, and private posts no longer appear there.

    - **Push destinations** move into one shared function (replacing `DeepLinkRoutes.pushPayloadToLocation` and the notification centre's `_onTap`). The card-link route must be added to that same routing, not next to it.

    - **Admin config permissions** are split; `id_hd_download_price` is still on the 运营配置 page. No change needed here.

- **Found during the UI design** (`petgo-platform` `f0d02163b`, 2026-11-24):

    - **The style list's "new" marker was removed on 2026-11-12** (commit `a59b662d6`). It is not an existing marker any more; FR-261 brings it back. Its copy `insightNewBadge` ("new") is still in the string files.

    - **The pet card page `card.html` has no desktop layout and no store buttons**: on a computer it shows the phone page and its one button.

    - **iPads are treated as computers.** Safari on iPadOS 13 and later sends a Mac user agent, so `card.html` sends iPads to its desktop branch. The existing `/p` pet card page has the same problem.

    - **The app has no tablet layout:** the iOS app is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`, so iPads run it in compatibility mode) and the Android app is locked to portrait.

    - **The share reward is credited to the Diary's current pet,** not to the card's pet. From 1.5.4 it goes to the card's pet (FR-262).

## 5. Features

### FR-260: Each card belongs to a pet

- **New cards:** the pet chosen in the creation form is stored with the card (its pet profile ID). Pre-filling and editing work as today.

    - **The backend requires the pet profile ID** on `POST /me/id-cards/v2` and checks that the pet belongs to the account and is active; otherwise it rejects the request. Without this check, a modified app could bind a card to someone else's pet (its "Lihat profil" would open that pet) or claim share rewards on other people's pets. The old endpoint stays as it is for apps 1.3.3 and older; cards made there have no pet and are handled like old cards below.

    - **Card creation requires at least one active pet (new in 1.5.4).** Today an account with no pet can create cards (§4). From 1.5.4, tapping a style on an account with no active pet shows the **no-pet sheet** (Appendix A) with a button to pet creation; after creating the pet, the user returns to the style list. The existing read-only sheet still applies when the account has only read-only pets.

        - **Sheet layout (UI design, 2026-11-24):** the existing confirm sheet (`showConfirmSheet`) with the Appendix A copy, "Buat profil hewan" as the main button and the existing **"Nanti saja"** (`pushSoftGuideLater`) as the second button. "Buat profil hewan" opens pet creation (`/profile/create`, with `?add=1` when the account already has a pet).

    - So every new card has a pet. A brand-new user who taps "Buat kartu untuk hewanmu" goes: sign up → create pet profile (1.5.0 sign-up onboarding) → card creation (FR-265).

- **Existing cards** are bound to a pet the first time the owner shares one. The backend checks the bind request the same way (the pet belongs to the card owner and is active):

    - **The card's name matches exactly one of the account's pets** (same name, ignoring upper/lower case and spaces at the ends): bound to that pet silently (Albar, 2026-11-19).

    - **Otherwise** (no match, or several pets with that name): a one-time sheet asks **"Kartu ini untuk hewan yang mana?"**.

        - It lists the account's pets, plus **"Bukan salah satu dari ini"** as the last row; nothing is preselected. Choosing a pet saves the binding.

        - Choosing "Bukan salah satu dari ini" means the card can't be shared as a link: the **not-linked toast** appears (Appendix A). The sheet asks again on the next share.

    - **No active pet on the account** (its pets were deleted, or the card was made before any pet existed): the card can't be shared as a link. The **not-linked toast** appears; saving still works.

- **The card's pet is deleted later** (new or bound card): links shared before show "not available" (FR-266). On Bagikan:

    - **Card not HD-unlocked, and the account has another active pet:** the Ganti hewan pet list opens. Choosing a pet binds the card to it and the share continues; closing the list creates no link.

    - **HD-unlocked card, or no other active pet:** the **deleted-pet toast** **"Profil hewannya sudah dihapus, jadi kartu ini tidak bisa dibagikan sebagai tautan."** appears and no link is created. Paid cards survive pet deletion and can still be saved.

- Binding never changes what the card shows.

- **Changing the pet (Hex, 2026-11-20):** until the card is HD-unlocked (paid, or with a free credit), the owner can change its pet from the card detail page with **Ganti hewan**, picking from the same pet list as the picker (without "Bukan salah satu dari ini"). The backend checks the new pet the same way. The card's link stays the same and follows the new pet from then on ("Lihat profil", the not-available state). **After HD unlock the pet can't be changed**, and Ganti hewan is gone.

- **Pet row on the card detail page (UI design, 2026-11-24):**

    - **Where:** a pet row between the AppBar and the card, reusing the creation form's pet row (`_KtpPetRow`): pet photo (32), "Untuk {petName}" and **"Ganti hewan ›"** on the right. Tapping it opens the Ganti hewan list.

    - **HD-unlocked card:** the same row shows only "Untuk {petName}", with no Ganti hewan, and can't be tapped.

    - **The card's pet was deleted:** the row shows the placeholder photo and **"Hewan sudah dihapus"** (Appendix A). Ganti hewan stays while the card isn't HD-unlocked.

    - **Old cards not yet bound to a pet:** no pet row.

    - **The Ganti hewan list** is the existing pet picker sheet (`showPetPickerSheet`) titled "Ganti hewan", with the current pet preselected. When Bagikan opens it after the pet was deleted, the deleted pet isn't listed, nothing is preselected and "Pakai" stays disabled until a pet is chosen.

**AC1** A card created in 1.5.4 has the pet chosen in the form stored with it.
**AC2** An account with no active pet can't reach the card form without creating a pet first, and a create request without a valid pet is rejected by the backend.
**AC3** A create or bind request with a pet profile ID from another account, or of a deleted pet, is rejected by the backend.
**AC4** An old card named "Mochi" on an account with one pet named "Mochi" is bound on its first share, with no question.
**AC5** An old card named "Mochi" on an account whose only pet is "Luna" asks which pet; "Bukan salah satu dari ini" shows the not-linked toast and creates no link.
**AC6** On an account with two pets, a card matching neither name asks once; after a pet is chosen, the next share doesn't ask.
**AC7** An old card on an account with no pets shows the not-linked toast and creates no link.
**AC8** After a card's pet is deleted, the card's existing link shows "not available". On an HD-unlocked card, Bagikan shows the deleted-pet toast and creates no link.
**AC9** After the pet of a card that isn't HD-unlocked is deleted, Bagikan opens the pet list when the account has another active pet; after a pet is chosen, the share continues with the same link.
**AC10** On a card that isn't HD-unlocked, Ganti hewan changes its pet; the card's existing link then leads to the new pet's profile.
**AC11** An HD-unlocked card has no Ganti hewan, and a change request for it is rejected by the backend.

### FR-261: Four new card styles

- **4 new styles:** a new-look KTP, SIM, Paspor and KITAS. They are **added next to** the existing 8 styles, not replacing them, so there are **12 styles** after 1.5.4. Student cards get no new colour (Albar named only these four types, 2026-11-19).

- **Names of the 4 new styles (Albar, 2026-11-24):** each new style shows its own name in the style list, Kartuku rows, the HD paywall header and admin style labels. The existing 4 keep their names.

    |Type|Existing style (ID)|New style (ID / EN)|
    |---|---|---|
    |KTP|KTP|**KTP Semanggi** / Clover ID|
    |SIM|SIM|**SIM Jalan-Jalan** / Road Trip License|
    |Paspor|Paspor|**Paspor Liburan** / Holiday Passport|
    |KITAS|Kartu Izin Tinggal|**Izin Betah Tinggal** / Homebody Permit|
- **Each new style is a style like any other:** its own thumbnail in the style list, its own card type in the data (dev names it), its own HD credit type and its own `card_style` value in tracking. A card's style is fixed at creation; for the other look, the user creates another card.

- **Existing cards** keep their style.

- **Same rules as the existing styles:** creating is free; HD unlock is per card at the admin price (see Glossary); PawCoin and QRIS work as today; admin views that list styles (user purchases, entitlement history, style labels) include the 4 new ones. **This includes the style picker when admin grants free credits to a user** (user drawer → free credits → grant): it lists all 12 styles (Hex, 2026-11-26). Today the list is built from every KTP `CreditType` except "any style" (`AdminUserEntitlementsService.GRANTABLE`), so once the 4 new credit types exist they appear without extra work; don't hard-code 8.

- **Value pack (Hex, 2026-11-20):** stays "1 HD unlock for each of the original 8 styles". The code must exclude the 4 new styles from the value-pack grant (`ktpTemplates()` lists every style today). "Any style" credits from activities (`KTP_HD_ANY`) work on all 12.

- **Artwork approved, build it as designed (2026-11-20).** The styles are shown below.

    - **Fields:** each new style shows the same fields as the existing style of the same type, so the creation form doesn't change.

    - **The mockups are for design only.** Names, dates and numbers on them are sample data. Every card shows the user's own data, and the card number keeps today's format (e.g. `TT230326020110`) in every style, not the 16-digit number in the KTP mockup.

    - **Build files:** backgrounds, logos, signs and decorations are in `V1.5.4/KTP分享链接/图片和附件/Card Design Asset Batch3/` (`KTP`, `Passport`, `SIM`, `Permit` = KITAS; one folder per type). This folder is **not in the git repo** (attachments are kept out); Hex sends it to dev separately (Hex, 2026-11-24).

|Type|Existing style|New style|
|---|---|---|
|**KTP**|![ktp.webp](图片和附件/ktp.webp)|![Mockup.png](图片和附件/Mockup%203.png)|
|**SIM**|![sim.webp](图片和附件/sim.webp)|![Mockup.png](图片和附件/Mockup%202.png)|
|**Paspor**|![passport.webp](图片和附件/passport.webp)|![Mockup.png](图片和附件/Mockup%201.png)|
|**KITAS**|![kitas.webp](图片和附件/kitas.webp)|![Mockup.png](图片和附件/Mockup.png)|

New fonts to bundle in the app: Coiny, Cherry Bomb One, DynaPuff, Lilita One and Modak (all Google Fonts). Rubik is already in use.

- **Place in the style list (UI design, 2026-11-24):** in the "Kartu Identitas" group each row shows an existing style on the left and its new style on the right, in this order: KTP | KTP Semanggi, Paspor | Paspor Liburan, SIM | SIM Jalan-Jalan, Kartu Izin Tinggal | Izin Betah Tinggal. SIM now comes before KITAS; this is display order only, and the card type values and stored data don't change. The student group is unchanged.

- **"new" marker:** the 4 new styles show the "new" marker that was removed from the list on 2026-11-12 (§4). Bring it back with its old look and copy (`insightNewBadge`, "new"; as before commit `a59b662d6`). It shows for **30 days after the release date**, then disappears (Hex, 2026-11-24; OQ-2 closed).

- **Kartuku:** each row shows the style name and "No. {number}" on separate lines, so the card number is never cut. No new copy.

- The rule that cards must not look like a real government ID (no Garuda, no "REPUBLIK INDONESIA") also applies to the new styles.

**AC12** The style list shows 12 styles: the existing 8 and the 4 new ones, named KTP Semanggi, SIM Jalan-Jalan, Paspor Liburan and Izin Betah Tinggal (EN: Clover ID, Road Trip License, Holiday Passport, Homebody Permit).
**AC13** A created card has no control to change its style.
**AC14** The same pet can have a KTP and a new-look KTP, as two cards.
**AC15** The HD unlock price and payment options are the same for the new styles.
**AC16** Cards created before 1.5.4 keep their style.
**AC17** An HD unlock of a new-style card is recorded under its own style in the admin user purchases view.
**AC18** A value pack bought after 1.5.4 grants 8 HD unlocks, one for each original style, and none for the 4 new styles.
**AC49** In admin, granting free credits to a user offers all 12 styles; a credit granted for a new style shows in the app and can unlock an HD card of that style.

### FR-262: Sharing a card as a link

- **Bagikan** now sends a **link with a caption** through the system share sheet. This button no longer shares an image. Saving to the gallery stays as today. The paid HD export ("save / share the HD image") is unchanged, because that clean image is what the owner paid for (Albar, 2026-11-19).

- **Caption (ID / EN):**

    - *"Kenalan yuk sama {petName}! 🐾 Ini kartu identitasnya di TailTopia: {url}"*

    - *"Meet {petName}! 🐾 Here's their ID card on TailTopia: {url}"*

    - `{petName}` = the name on the card.

- **One link per card:** created on the first share and reused afterwards, so the same card always gives the same URL. Two cards give two links.

- **What the link may contain:** a random token only. It never contains the card number, the serial, the card ID or the pet profile ID.

- **Preview image:** when the link is created, a preview of the card is stored for the landing page and the chat preview. It is about **600 px wide with the diagonal TailTopia watermark**: readable, but not usable as a clean card. It is watermarked **even if the card is HD-unlocked**.

- **The preview must not be an arbitrary image from the app.** If the app renders and uploads it, a modified app could put any picture on our domain and in chat previews. Dev chooses one (OQ-1): the server renders the preview from the card's stored data, or the server checks the uploaded image (size and the same moderation as post photos) before serving it.

- **The preview image** is served only while the card can be shown. When the card, its pet or the owner's account is gone, the image stops being served as well.

- **Share reward:** granted once per pet, with the same rules and amount as today, and the **same trigger as today's image share**: after the system share sheet reports the share as done. It is credited to **the card's pet** (Hex, 2026-11-24; OQ-4 closed); today's code credits the Diary's current pet and must change.

- **While the link is being created,** Bagikan shows its existing busy state (spinner, disabled) until the share sheet closes.

- **Toasts on the card pages** are the existing snackbar (`idCardSnackBar`). The link-failed copy replaces today's `idCardShareError`, and the new caption replaces today's `idCardShareCaption`.

- **The link is created before the share sheet opens.** If creating the link or its preview fails (offline, timeout):

    - the toast **"Gagal membuat tautan. Coba lagi, ya."** / "Couldn't create the link. Please try again." appears (Albar, 2026-11-19);

    - nothing is shared and no reward is given;

    - the next tap tries again.

**AC19** Bagikan opens the system share sheet with the caption and a `https://s.tailtopia.id/k/…` link.
**AC20** Sharing the same card twice gives the same link; another card of the same pet gives a different link.
**AC21** The link contains none of: card number, serial, card ID, pet profile ID.
**AC22** The first link share for a pet grants the share reward; later ones don't.
**AC23** The preview of an HD-unlocked card is still watermarked.
**AC24** With no network, Bagikan shows "Gagal membuat tautan. Coba lagi, ya.", opens no share sheet and gives no reward. With the network back, the next tap works.
**AC25** After the pet is deleted, the preview image URL no longer returns the image.
**AC26** A modified app can't make the landing page or chat preview show any image other than the card's preview.

### FR-263: Opening the link with the app installed

- Tapping the link opens the app directly: Android App Links and iOS Universal Links for the card-link path on `s.tailtopia.id`. **Only the card link** gets this; the existing `/p`, `/c`, `/m` and place links stay as they are.

- **Fallback:** if the app doesn't open (e.g. some in-app browsers), the landing page's "Buka di aplikasi" tries the app through the custom scheme, as the pet card page does.

- **Destination:**

    - **Owner:** opens their own card's detail page, the same page as from Kartuku.

    - **Everyone else:** opens the **visitor card page**.

- **Visitor card page:**

    - **Card:** the shared card in its style, watermarked, read-only.

    - **Line under the card:** "Kartu milik **{petName}**".

    - **Buttons:**

        - **"Buat kartu untuk hewanmu"** opens the card creation start.

        - **"Lihat profil {petName}"** opens the pet's page (the other-pet Diary page as redesigned in 1.5.2). Here `{petName}` is the **current name of the card's pet**, not the name on the card: they differ after Ganti hewan or a pet rename (Hex, 2026-11-23). Everywhere else, `{petName}` is the name on the card.

    - **Not available:** no editing, no HD purchase, no sharing.

    - **Look (UI design, 2026-11-24; no new artwork):** like the card detail page: white AppBar, light violet page (#F8F2FF), the watermarked card (not blurred) lifted by a soft shadow, "Kartu milik **{petName}**" under it, the existing disclaimer, then the two buttons stacked at the bottom ("Buat kartu untuk hewanmu" filled, "Lihat profil {petName}" outlined).

    - **Other states, same background and AppBar:** loading; "not available" (FR-266); and **failed to load**, which uses the existing error block with retry ("Gagal memuat kartu. Coba lagi." and a "Coba lagi" button, existing copy).

- **Guests can view the page.** Both buttons ask for login or sign-up first, then continue to where the user was going.

- **Older app versions (before 1.5.4)** don't claim the card link, so it opens the landing page. The custom-scheme link behind "Buka di aplikasi" must use **a new host**, not `card`: old apps send `tailtopia://card/…` to the pet card page. With a new host, today's code behaves safely: on Android the old app doesn't register the host, so the page falls through to the Play Store, where the user can update; on iOS the old app opens and starts normally (`deepLinkToLocation` returns nothing for an unknown host).

**AC27** With the app installed (Android and iOS), tapping the link in WhatsApp opens the visitor card page without a browser step.
**AC28** The owner tapping their own link opens their own card.
**AC29** A guest sees the visitor card page; tapping a button asks for login, and after login they continue to the creation start or the pet page.
**AC30** The visitor card page has no edit, HD or share controls.
**AC31** Pet card, post, milestone and place links behave exactly as before.
**AC32** After a card showing "Mochi" is moved to Luna with Ganti hewan, its visitor page still shows the Mochi card and "Kartu milik Mochi", and the button reads "Lihat profil Luna" and opens Luna's page.
**AC33** On 1.5.0 and 1.5.2, "Buka di aplikasi" opens the Play Store (Android) or the app's normal first screen (iOS), never a pet card page or an error.

### FR-264: Landing page (app not installed)

- A light page on `s.tailtopia.id`, built like the existing pet card page. Indonesian only, no third-party scripts, not indexed by search engines.

- **Content, top to bottom:**

    1. TailTopia logo

    2. the watermarked card preview (FR-262)

    3. **"Kartu Identitas {petName}"**

    4. "Dibuat di TailTopia, aplikasi untuk pemilik hewan"

    5. **"Pilih dari 12 gaya kartu, gratis"** with a horizontal strip of card-style thumbnails (the existing style images; the strip is cut off at the right edge to show there are more) (Hex, 2026-11-24)

    6. the disclaimer, same copy as the card detail page: "Hanya Untuk Hiburan · Kartu ini bukan dokumen resmi dan tidak memiliki kekuatan hukum. Dibuat oleh TailTopia semata untuk hiburan." (Hex, 2026-11-24)

    7. Button **"Buat kartu untuk hewanmu"**, with "Unduh TailTopia gratis" under it

    8. "Sudah punya aplikasinya? **Buka di aplikasi**"

- **The button goes to:** the Play Store on Android, the App Store on iOS, and both store buttons on desktop. The store link carries whatever the deferred deep link (FR-265) needs to recognise an install that came from a card link; dev decides what.

- **Look (UI design, 2026-11-24; no new artwork):** the pet card page's scrapbook look (`card.html`): paper background, tape on the card, the handwritten "Kartu Identitas" label, the pet name with the gold underline, the logo at the top left and in the footer; the handwritten label sits just above the title and the card keeps one tape. **The button is solid violet (#845EC9) with white text** (Hex, 2026-11-24; the light pill read as disabled on the paper background), in a bar pinned to the bottom; the not-available page (FR-266) and the desktop store buttons use the same style. "Buka di aplikasi" is 12 px bold violet and underlined.

- **Desktop:** the same centred column, with two light pill store buttons (App Store and Google Play) in place of the one button. "Buka di aplikasi" is shown on desktop too.

- **iPad detection:** Safari on iPadOS 13 and later sends a Mac user agent (§4). Treat a user agent containing "Macintosh" together with `navigator.maxTouchPoints > 1` as iOS, so iPads get the App Store button and the app attempt instead of the desktop page; `ua_platform` is logged as `ios`. The existing `/p` pet card page has the same problem; fixing it there is optional.

- **Tablets:** the page works as on phones: the same column (440 wide), one store button for the platform (iPad → App Store, Android tablet → Play Store) and "Buka di aplikasi". The 1.5.4 app has no tablet layout (§4), so a tablet that opens the app gets the phone layout.

- **Chat preview tags:**

    - title **"Kartu Identitas {petName} 🐾"**;

    - description **"Lihat kartu identitas {petName} dan buat kartu untuk hewanmu sendiri di TailTopia."**;

    - image = the preview.

- ⚠️ In code, the pet card page's default iOS store link is the Play Store URL. Dev must check that production uses the App Store link; the card link must use it too.

**AC34** Android without the app: the link opens the landing page; the button opens TailTopia in the Play Store.
**AC35** iOS without the app: the button opens TailTopia in the App Store. This includes Safari on an iPad, which must not get the desktop page.
**AC36** Desktop shows both store buttons and "Buka di aplikasi".
**AC37** Pasting the link in WhatsApp shows the card preview, title and description.
**AC38** The page has no third-party scripts and is marked not to be indexed.

### FR-265: First open after install lands on card creation (deferred deep link)

- **Goal:** someone who taps the landing-page button, installs and opens the app **for the first time** lands on **card creation**, not on the shared card (Albar, 2026-11-19). Card creation needs a login and a pet:

    - **New user:** signs up and goes through the 1.5.0 sign-up onboarding (nickname → pet status → pet profile) as usual. Card creation opens when onboarding ends, on top of the screen onboarding would have shown (the profile-created celebration page, or home); back returns to that screen. If they skipped creating a pet, card creation shows the no-pet sheet (FR-260).

    - **Existing user** (reinstall): card creation opens after login, on top of home.

- The link only has to tell the app that the install came from a card link. It doesn't need to identify which card.

- It happens only on that first open, and only once. Later opens never jump to card creation. If no card link can be matched, the app starts normally and shows nothing about it.

- **Approach: dev decides** (OQ-1). Known options:

    - **Android:** the Play Install Referrer is exact and free.

    - **iOS:** no free exact method exists. Options are AppsFlyer OneLink (the SDK is already in the app, but its deep-link feature is off and AppsFlyer is disabled on stag) or Branch. Firebase Dynamic Links was shut down in 2025.

- **Attribution:** sign-ups that start from a card link get the entry source **`id_card_link`**, the same mechanism as sign-ups from the pet card page.

**AC39** On a platform covered by the chosen approach, link → install → first open asks for login or sign-up, runs the sign-up onboarding for a new user, and then shows card creation; reopening the app doesn't show it again.
**AC40** Installing without a link and opening shows the normal first screen.
**AC41** A user who signs up from the visitor card page, or on the first open after a card-link install, is attributed to `id_card_link`.

### FR-266: When the card can't be shown

- **One friendly "not available" state**, the same on the web and in the app, for every case:

    - pet deleted;

    - owner's account deleted or banned;

    - card no longer exists;

    - unknown link;

    - a logged-in viewer with a block in either direction with the owner.

- It doesn't reveal which case applies. This overrides V1.1.0 FR-49A, which asked for a separate "pet profile deleted" message: one shared state keeps people from probing which pets or accounts exist. The copy doesn't hint at a reason either.

- **Copy:** **"Kartu ini sudah tidak tersedia"** / "Kamu tetap bisa membuat kartu untuk hewanmu sendiri." / button **"Buat kartu untuk hewanmu"**.

- **Web look (UI design, 2026-11-24):** keep the existing `card_gone.html` page (empty photo corners with tape marks, title, light pill button) and change only its copy. No line hinting at a reason. In the app, the state uses the visitor page's background and AppBar (FR-263).

- Because the link goes through the pet profile ID, a link to a deleted pet keeps showing this state **even after its card number is given to a new pet**.

- **No way to turn a link off in 1.5.4.** Links are random, unguessable and not indexed, and unknown links are rate-limited like the other share pages.

**AC42** After the pet is deleted, its card links show "not available" on the web and in the app.
**AC43** After that pet's serial is reused by a new pet, the old link still shows "not available", never the new pet.
**AC44** A made-up link shows the same "not available" state.
**AC45** A logged-in user blocked by the owner (or who blocked the owner) sees "not available" in the app.

### FR-267: Tracking

All events go to our own server: register them in the event catalog, add the app constant, pass the comparison test. Nothing depends on PostHog. Web events are reported by the backend, like the pet card page's.

|Event|Source|When|Properties|
|---|---|---|---|
|`id_card_visitor_viewed`|App|Visitor card page shown|`page_state` (full / gone), `is_guest`|
|`id_card_visitor_cta_tapped`|App|A button on the visitor page|`cta` (create_own / view_pet), `is_guest`|
|`id_card_deferred_link_resolved`|App|First open matched a card link and opened card creation|`platform`|
|`id_card_link_opened`|Web|Landing page served to a person. Requests from chat-preview bots (WhatsApp, Facebook, Telegram, X and similar link-preview user agents) are not counted.|`page_state`, `ua_platform`, `referrer_host`|
|`id_card_link_cta_tapped`|Web|Landing button tapped|`page_state`, `ua_platform`, `cta` (create / open_app)|
|`id_card_link_cta_outcome`|Web|What happened after the button (best effort)|`outcome` (app_opened / store_redirect / desktop_fallback)|

- `id_card_link_opened` counts every serve, including repeat opens by the same person, so SM-2 and SM-3 are per open, not per person.

- **Sign-up entry source:** new value `id_card_link`.

- **Style values:** each new style gets its own `card_type` value (sent by `id_card_created`, `id_card_style_tapped`, `id_card_share_tapped`, `ktp_unlock_succeeded` and others) and a new `card_style` value, 8 to 11 (sent by `id_card_share_tapped`).

- **Link shares use the existing events:** `id_card_share_tapped` and `id_card_share_sent` stay on Bagikan and now describe link shares. `id_card_share_sent` gets the new property `card_style`. The HD export share sends no event, as today.

**AC46** Each event in the table fires once at its moment with the listed properties. Staging builds report to the staging data store and debug builds report nothing, as for all events today.
**AC47** Pasting a card link into WhatsApp (chat preview only, no tap) adds no `id_card_link_opened`.
**AC48** A sign-up from a card link carries entry source `id_card_link`.

## 6. Non-goals

- Turning off or resetting a link.

- App Links / Universal Links for the other share pages.

- Card backs or a QR code on the card.

- Recipients editing, buying HD for, or resharing someone else's card.

- Changing a card's style after creation.

- Changing a card's pet after HD unlock.

- New student-card colours.

- Changing the HD price.

## 7. Success metrics

Source: our own server data, production only, days in WIB, internal accounts excluded. Measure for 2 weeks, then set targets.

|#|Metric|Definition|
|---|---|---|
|SM-1|Link shares|`id_card_share_sent` per week (from 1.5.4; earlier weeks counted image shares)|
|SM-2|Reach|`id_card_link_opened` (page_state full) + `id_card_visitor_viewed` per link share (opens, not people)|
|SM-3|Landing conversion|`id_card_link_cta_tapped` (cta create) ÷ `id_card_link_opened` (full)|
|SM-4|New users|Sign-ups with entry source `id_card_link` per week; of those, the share who create their own card within 7 days|
|SM-5|Deferred hit rate|`id_card_deferred_link_resolved` ÷ `id_card_link_cta_outcome` (outcome = store_redirect), by platform|
|SM-6|New style uptake|Share of new cards created in the 4 new styles (`id_card_created.card_type` = one of the 4 new card types)|
|Counter|HD revenue|KTP HD unlocks per week must not drop after the image share is removed (`ktp_unlock_succeeded`)|

## 8. Open questions

|#|Question|Owner|Needed by|
|---|---|---|---|
|OQ-1|Deferred deep link: the destination is decided (card creation, FR-265); **dev decides the approach** per platform (Install Referrer, AppsFlyer OneLink, Branch or other). Also: confirm production uses the App Store link (FR-264); choose how the preview is protected (server render or server check, FR-262)|Dev|Before development starts|
|~~OQ-2~~|~~How long the "new" marker shows~~ **Closed 2026-11-24 (Hex): 30 days after the release date** (FR-261).|Hex|Done|
|~~OQ-4~~|~~Which pet earns the share reward~~ **Closed 2026-11-24 (Hex): the card's pet** (FR-262), not the Diary's current pet.|Hex|Done|
|OQ-3|FR numbers re-checked 2026-11-23 against `PetGo` `main` `991e901` (all branches): V1.5.2 uses FR-226 to FR-259 (FR-225 is the last V1.5.0 number), and no doc uses FR-260 or higher. ⚠️ The Roadmap's 1.5.2 note (2026-11-20) still says "next free FR-260" and leaves two 1.5.2 items undecided (monthly level shop coupon, vet page redesign); if either gets FRs, they must start at FR-282. This PRD moved from FR-232–239 to **FR-260 to FR-267**. The mention PRD is now **FR-268 to FR-273** (was FR-226 to FR-231) and the browsing-history PRD **FR-274 to FR-281** (was FR-240 to FR-247), renumbered 2026-11-20; next free number FR-282. Re-check before merging to `PetGo`|Albar|Before merging to `PetGo`|

## Appendix A. Copy (all approved by Albar: 2026-11-19, the four rows Hex added on 2026-11-23, and the two rows from 2026-11-24)

|Place|Bahasa Indonesia|English|
|---|---|---|
|Share caption|Kenalan yuk sama {petName}! 🐾 Ini kartu identitasnya di TailTopia: {url}|Meet {petName}! 🐾 Here's their ID card on TailTopia: {url}|
|Pet picker (old cards)|Kartu ini untuk hewan yang mana?|Which pet is this card for?|
|Pet picker: none option|Bukan salah satu dari ini|None of these|
|Change pet|Ganti hewan|Change pet|
|Link failed toast|Gagal membuat tautan. Coba lagi, ya.|Couldn't create the link. Please try again.|
|No-pet sheet|Buat profil hewan dulu, yuk / Kartu identitas dibuat untuk hewan yang sudah punya profil. / Buat profil hewan|Create a pet profile first / ID cards are made for a pet with a profile. / Create pet profile|
|Deleted-pet toast|Profil hewannya sudah dihapus, jadi kartu ini tidak bisa dibagikan sebagai tautan.|This pet's profile was deleted, so the card can't be shared as a link.|
|Not-linked toast|Kartu ini belum terhubung ke profil hewan, jadi belum bisa dibagikan sebagai tautan.|This card isn't linked to a pet profile, so it can't be shared as a link yet.|
|Visitor page line|Kartu milik **{petName}**|**{petName}**'s card|
|Visitor page buttons|Buat kartu untuk hewanmu · Lihat profil {petName} (current name of the card's pet)|Make a card for your pet · View {petName}'s profile|
|Landing page|Kartu Identitas {petName} / Dibuat di TailTopia, aplikasi untuk pemilik hewan / **Pilih dari 12 gaya kartu, gratis** (new, approved by Hex 2026-11-24) / disclaimer as the card detail page / Buat kartu untuk hewanmu / Unduh TailTopia gratis / Sudah punya aplikasinya? Buka di aplikasi|(web is ID only)|
|Chat preview|Kartu Identitas {petName} 🐾 / Lihat kartu identitas {petName} dan buat kartu untuk hewanmu sendiri di TailTopia.|(web is ID only)|
|Not available|Kartu ini sudah tidak tersedia / Kamu tetap bisa membuat kartu untuk hewanmu sendiri. / Buat kartu untuk hewanmu|This card is no longer available / You can still make a card for your own pet. / Make a card for your pet|
|New style names (Albar, 2026-11-24)|KTP Semanggi / SIM Jalan-Jalan / Paspor Liburan / Izin Betah Tinggal|Clover ID / Road Trip License / Holiday Passport / Homebody Permit|
|Pet row, pet deleted (Albar, 2026-11-24)|Hewan sudah dihapus|Pet is already deleted|

Existing copy reused, not new: "new" marker (`insightNewBadge`), "Nanti saja" (`pushSoftGuideLater`), visitor page load error "Gagal memuat kartu. Coba lagi." with "Coba lagi".

## Appendix B. Notes for developers

Paths are at `origin/main` `ca55416d9` (V1.5.0).

- **Cards:**

    - entity `profile/domain/IdCard.java` (no pet column); service `IdCardService` (no pet check);

    - create request `profile/dto/CreateIdCardRequest.java` (no pet ID; `POST /me/id-cards/v2`; old `POST /me/id-cards` for apps 1.3.3 and older);

    - styles: app `features/profile/domain/id_card_style.dart`; backend `IdCardType`, `StudentVariant`; HD credits `entitlement/domain/CreditType.java` (`ktpTemplates()` feeds the value pack);
    - card widgets in `presentation/id_card/`;

    - creation entry `id_card_page.dart` `_onStyleTap` / `_guardKtpEntry` (lets an account with no pet through).

- **Share:**

    - `id_card_detail_page.dart`: Bagikan `_onFreeShare` 253-291 (share events), `_capture` 350, HD export `_exportHd` 378 → `_shareImageBytes` 432;

    - `shared/card_render/card_export.dart` (`Share.shareXFiles`, no text today);

    - watermark `id_card_watermark.dart`, low-res cover `id_card_low_res_cover.dart`;

    - reward `POST /me/id-cards/{cardId}/share-rewards?petId=` (`ProfileApiController.java:318`).

- **Pet card page to copy:**

    - `profile/web/CardPageController.java:93` and template `templates/card.html:363-452` (custom scheme → `market://` → store);

    - tracking `CardTrackController.java:72`, `CardPageAnalytics.java`;

    - public paths in `shared/security/SecurityConfig.java:179-217`;

    - `s.tailtopia.id` → backend through Cloudflare Tunnel.

- **Deep links:**

    - `app_links` only; mapping in `deepLinkToLocation` (`app.dart:83-140`; host `card` → `/pet/{token}`, unknown hosts → nothing);

    - Android `AndroidManifest.xml:91-139` (custom scheme only, no `autoVerify`);

    - iOS `Info.plist:94-122` and `Runner.entitlements` (no Associated Domains);

    - `assetlinks.json` / `apple-app-site-association` to be served on `s.tailtopia.id`;

    - `deeplink_manifest_test` catches a missing host;

    - the visitor route must sit outside `/profile` (login wall, `app_router.dart` 185-195);

    - 1.5.2 moves push / notification destinations into one function; add the card route there.

- **UI pieces to reuse** (from the UI design, `f0d02163b`):

    - pet row: `_KtpPetRow` from the creation form; picker `showPetPickerSheet`; no-pet sheet `showConfirmSheet`; toasts `idCardSnackBar`;

    - "new" marker: `_cell` in `id_card_style_grid.dart` as it was before commit `a59b662d6` (top −5, right 8, #E5604D, radius 8, padding 7/2, white 10 px w600);

    - Kartuku row: `_cardTile` text column (name and number on separate lines);

    - web: `card.html` and `card_gone.html` styles; add the iPad check (FR-264) next to the existing user-agent check.

- **AppsFlyer:** `core/analytics/appsflyer_client.dart:23-27, 72` (deep-link callback off; disabled-on-stag flag marked "勿合回 main").

- **Store link:** `application.yml:177-203`. `CARD_IOS_URL` defaults to the Play URL (comment: "V1 仅 Android 上架"); check production.

- **Sign-up attribution:** reuse the pet card entry mechanism (`LoginGuideController.markPetCardEntry`, `app_router.dart:1362-1368`).

- **Events:** `petgo-backend/src/main/resources/analytics/event-catalog.yaml`, `core/analytics/event_names.dart`. The catalog types `card_style` as string but the app sends an int (`analyticsCardStyle`); align when adding values 8 to 11.

## Change log

|Date|Who|Change|
|---|---|---|
|2026-11-19|Albar|First draft: FR-232 to FR-239 (now FR-260 to FR-267), AC1 to AC33. Decisions from the coaching session on 2026-11-19.|
|2026-11-19|Albar|Review pass: old cards bind silently only on an exact name match, otherwise a picker with 'Bukan salah satu dari ini'; pet deleted later; link-failure toast; reward trigger; preview stops when the card is gone; Play link carries the token; chat-preview bots not counted; FR-49A override stated; student cards get no new design. ACs renumbered AC1 to AC39.|
|2026-11-19|Albar|Pet-picker none option approved as "Bukan salah satu dari ini"; all copy approved. OQ-1 (dev) after Hex's review; OQ-2 when design is done.|
|2026-11-19|Albar|Deferred deep link now lands on card creation (after login or sign-up), not on the shared card; dev decides the approach (OQ-1 stays open, owner Dev). `id_card_visitor_viewed` drops `from`.|
|2026-11-20|Albar|New-design artwork received (Card Design Asset Batch3); FR-261 points to it, lists new fonts, keeps the TT card-number format. OQ-2 narrowed to default design, picker and artwork checks.|
|2026-11-20|Albar|Artwork confirmed approved as designed; artwork checks dropped. OQ-2 is now only the default design and picker presentation.|
|2026-11-20|Albar|Card designs embedded in FR-261 (current vs new for each type, with fonts), so this PRD is the only document. Mockup data is sample only; the card number keeps the TT format.|
|2026-11-20|Hex|Review: renumbered FR-232–239 → FR-260–267 (1.5.2 took those numbers; OQ-3 corrected); code facts re-checked on `origin/main` `ca55416d9`, 1.5.2 changes added to §4 from its PRDs; backend must require and check the pet on create and bind; new no-pet sheet (no pet can create cards today); old-card toast split into not-linked / deleted-pet; bindings can't be changed; **new designs are 4 new styles (12 in total)**, value pack open (OQ-4); preview must not be an arbitrary app upload; card scheme link uses a new host so old apps fail safe; deferred link runs after the 1.5.0 sign-up onboarding; "not available" copy no longer hints at a reason; link shares reuse `id_card_share_*`; frontmatter and bold fixed. ACs renumbered AC1 to AC43. ⚠️ New copy needs Albar's approval.|
|2026-11-20|Hex|OQ-3: the other two 1.5.4 PRDs renumbered (mention FR-268–273, browsing history FR-274–281). No rule changes.|
|2026-11-20|Hex|Merge order with the other 1.5.4 PRDs added to §0. No rule changes.|
|2026-11-20|Hex|Value pack stays 8 original styles (new 4 excluded; OQ-4 closed); a card's pet can be changed with Ganti hewan until HD unlock; numbering line updated (next free FR-282). ACs renumbered AC1 to AC46.|
|2026-11-23|Hex|Final check: SM-6 and style tracking use `card_type` (`id_card_created` has no `card_style`); AC31 covers 1.5.2; preview failure wording; markers and glossary aligned with Ganti hewan. No rule changes.|
|2026-11-23|Hex|"Lihat profil" uses the current name of the card's pet; after the pet is deleted, Bagikan on a card that isn't HD-unlocked opens the pet list instead of the toast. ACs renumbered AC1 to AC48.|
|2026-11-23|Hex|**PRD final.** Next: Albar runs the UI flow on this PRD (settles OQ-2 and the ⚠️ copy); OQ-1 stays with dev.|
|2026-11-23|Albar|Approved the 4 new copy rows (Ganti hewan, no-pet sheet, not-linked toast, new "not available" line); all copy approved. Merge-order text aligned with the final browsing-history PRD (server-side recording, app post detail page untouched). FR-265 points to the no-pet sheet. OQ-2 now settled in Albar's UI flow. Formatting only: export backslashes and stray title line removed.|
|2026-11-24|Albar|Names for the 4 new styles (FR-261, AC12, Appendix A): KTP Semanggi, SIM Jalan-Jalan, Paspor Liburan, Izin Betah Tinggal (EN Clover ID, Road Trip License, Holiday Passport, Homebody Permit). A style is picked from its own tile before the create page opens; there is no design switch on the create page or the card. Needs Hex's confirmation.|
|2026-11-24|Albar|UI design decisions written in (design deck in §0); the `[DESIGN]` markers are replaced. FR-260: no-pet sheet layout, pet row with Ganti hewan on the card detail page, "Hewan sudah dihapus" (new copy row), picker details. FR-261: old-and-new rows in the style list (SIM before KITAS), "new" marker brought back, Kartuku number on its own line. FR-262: snackbar, busy state, which pet earns the reward is open (new OQ-4). FR-263: visitor page look and failed-to-load state. FR-264: scrapbook landing look, desktop store buttons, iPad detection, tablets. FR-266: web keeps `card_gone.html`. §4 code facts from `f0d02163b`. OQ-2 narrowed to how long the "new" marker shows. AC35 and AC36 reworded (iPad, store buttons); no ACs added or renumbered. Student card names unchanged. Needs Hex's confirmation.|
|2026-11-24|Hex|Landing page redesign (UI F2, F3, F5, F6): style-thumbnail strip with "Pilih dari 12 gaya kartu, gratis", disclaimer added, solid violet button (also F4 and desktop store buttons), decoration trimmed. FR-264 content list and look updated; one new string in Appendix A.|
|2026-11-24|Hex|OQ-2 closed: "new" marker shows 30 days after release. OQ-4 closed: share reward goes to the card's pet. Landing-page string "Pilih dari 12 gaya kartu, gratis" approved.|
|2026-11-24|Hex|UI final ("可以，定稿"), 31 screens split into `拆页-App/`; §0 link points to this repo.|
|2026-11-24|Hex|Artwork for the 4 new styles: `V1.5.4/KTP分享链接/图片和附件/Card Design Asset Batch3/` (FR-261 build files).|
|2026-11-26|Hex|Admin free-credit grant (user drawer) must list all 12 styles; added to FR-261 rules and AC49.|
