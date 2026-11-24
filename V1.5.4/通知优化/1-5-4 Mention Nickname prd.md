---
title: "Notification Optimization (@Mention Nickname, Follow Updates, Less Noise)"
status: final
created: 2026-11-19
updated: 2026-11-24
---

# PRD: TailTopia Pet App — Notification Optimization (V1.5.4)

> Started as "@Mention Notifications with Nickname" (Part 1). Hex widened it on 2026-11-24 to cover follow updates (Part 2) and notification noise across the app (Part 3). Folder renamed `V1.5.4/提及带昵称/` → `V1.5.4/通知优化/`; file names unchanged.

## 0. About this document

- **What this is:** the fix for @mention notifications. Today both the push and the notification center say that *someone* mentioned you. After this change they say *who*: the push reads "Budi menyebutmu 📣", and the notification-center row reads "**Budi** menyebutmu di komentar". A comment mention also opens the exact comment.

- **Part 2, follow-update notifications (Hex, 2026-11-24):** when someone you follow posts several times in a row, or posts and then deletes, you get a push and a notification-center row for each post today, and the rows for deleted posts stay. Part 2 (FR-321 to FR-325) sends follow-update pushes 10 minutes late, merges one author's unread updates into one row, and hides updates whose posts are gone. FR-325 also drops the notification center's day group headers.

- **Part 3, less noise (Hex, 2026-11-24):** users feel the app sends too many notifications. Part 3 (FR-326 to FR-334) merges comment, follower and gift notifications like likes already are, sends one notification per event, and adds app-wide limits: at most 8 interaction/promo pushes per user per day, no such pushes from 00:00 to 07:00 WIB, and at most 2 ops pushes per user per day.

- **Who it is for:** product (Albar, Hex), Dai's backend and app developers, QA.

- **Release:** V1.5.4, as one release for backend and app (Albar, 2026-11-19). No early backend hotfix.

- **Source spec:** V1.3.0 PRD FR-119, "@ 通知文案" (signed off 2026-09-01). This PRD **replaces** that copy table. Where they differ, this PRD wins.

- **Code baseline:** `petgo-platform` `origin/main` `ca55416d9` (V1.5.0, live), checked 2026-11-20. `dev_1.5.2` doesn't exist yet; the 1.5.2 changes that touch this PRD come from the 1.5.2 PRDs (§4, FR-270). Re-check against `dev_1.5.2` once it exists.

- **Depends on:** V1.5.2 PRD "头像框与推送直达" **FR-244** (push opens the target page directly; push and notification center share one destination rule). 1.5.4 builds on it and merges after it.

- **Merge order (1.5.4, Hex 2026-11-20):** all three 1.5.4 PRDs (KTP share link, mention nickname, browsing history) build on 1.5.2 and merge after it. Shared code: the one push/notification destination function that 1.5.2 FR-244 creates. The mention PRD adds the comment-ID case (FR-270) and merges first; the KTP PRD adds the card-link route (FR-263) and rebases on it. Browsing history doesn't touch that function: it adds a cell to the Saya page's AKTIVITAS card, a new Riwayat page, and recording inside the server's post detail, post like and product detail APIs. It doesn't change the app's post detail page, so it can merge any time after 1.5.2.

- **Numbering:** **FR-268 to FR-273** and, for Part 2, **FR-321 to FR-325** and, for Part 3, **FR-326 to FR-334** (FR-282 to FR-320 are taken by the 1.5.4 search and Tailsonality PRDs and the website PRD); **AC1 to AC22** and **AC23 to AC40** and **AC41 to AC64**. V1.5.2 uses FR-226 to FR-259 and the KTP share link PRD uses FR-260 to FR-267, so this PRD starts at FR-268. The browsing-history PRD follows at FR-274 (OQ-1).

- **Decisions:** every rule here was decided by Albar on 2026-11-19 (log in `.memlog.md`), unless marked Hex 2026-11-20. Copy is approved.

- **UI design:** `V1.5.4/通知优化/ui-1-5-4-mention-nickname-integrated-v1.html`. Part 1 by Albar (2026-11-24; code checked at `f0d02163b`); Part 2 and Part 3 lanes added by Hex on 2026-11-24. **Final 2026-11-24**, 22 screens; one file per screen in `V1.5.4/通知优化/拆页-App/` (start at `00-目录.html`); developer notes in the deck header. Its decisions are written into FR-269, FR-270, §5 and the appendices below.

## 1. Why

A notification that says "someone mentioned you" gives the reader no reason to tap: they can't tell whether it is a friend, a stranger or spam. Naming the person is what makes a mention worth opening.

V1.3.0 specified nickname copy for both the push and the notification center. It never reached production. This PRD brings the code in line with that spec and makes mentions a little richer: the push and the row name the person, and comment mentions open the exact comment.

**Goal:** mention notifications name the mentioner everywhere and open where the mention is. **Success = shipped and verified by QA.** There is no metric target (Albar, 2026-11-19).

## 2. What is wrong today

We checked the code on `origin/main` `ca55416d9` and confirmed the wrong copy.

|Where|V1.3.0 spec|What users get today|
|---|---|---|
|Push title|Ada yang menyebutmu 📣|**Kamu disebut**|
|Push body, post|{nickname} menyebutmu di sebuah postingan. Ketuk untuk lihat!|**Seseorang** menyebutmu di sebuah postingan|
|Push body, comment|{nickname} menyebutmu di komentar. Ketuk untuk lihat!|**Seseorang** menyebutmu di sebuah komentar|
|Notification center|{nickname} menyebutmu di sebuah postingan / di komentar|"Ada yang menyebutmu" + "Seseorang menyebutmu di sebuah postingan / komentar"|

Root causes:

1. **Push.** The backend copy is a fixed sentence with no placeholder for a name. The mention listener sends it without arguments. The listener has the mentioner's user ID but never looks up the nickname.

2. **Notification center.** Likes, comments and follows store *who* acted, and the list returns their nickname. Mentions were never added to that group, so the app has no name to show and falls back to its own fixed strings.

3. **Where the requirement was lost.** The V1.3.0 implementation story for mention notifications required separate post and comment wording but dropped the nickname that the signed-off spec required.

4. **Not the 1.4.2 "nickname variable" work.** That work (AB-37) only puts the *recipient's* own nickname into ops campaign pushes. It never touched mentions.

5. **Not fixable in admin.** The copy lives in code (backend message files and app string files), not in an editable template. This needs a backend change and an app release.

Also found:

- The mention notification does not store the comment ID (the mention event has it, but it is dropped when the notification is written). So a comment mention can only open the post's comment section, not the comment. Today the push also lands in the notification center first; 1.5.2 FR-244 changes that (§4).

- If the mentioner's account was deleted or banned before the notification was sent (e.g. a post held for review and approved later), the notification still goes out.

- The push is already in the recipient's account language (the backend renders it with the recipient's locale). The V1.3.0 rule "push is always Indonesian" was never what the code did, so nothing changes there.

## 3. Glossary

- **Mentioner:** the user who wrote the @mention.

- **Recipient:** the user who was mentioned.

- **Post mention / comment mention:** a mention inside a post's text, or inside a comment or reply.

- **Nickname:** the mentioner's user nickname (用户昵称), the same name that like and comment notifications show. Not a pet name.

- **Account language:** the language the recipient chose in the app (ID or EN). Every push and every interaction row already uses it.

## 4. Features

### FR-268: Push copy with the mentioner's nickname

||Bahasa Indonesia|English|
|---|---|---|
|Title (both)|{nickname} menyebutmu 📣|{nickname} mentioned you 📣|
|Body, post mention|Di sebuah postingan. Ketuk untuk lihat!|In a post. Tap to view!|
|Body, comment mention|Di komentar. Ketuk untuk lihat!|In a comment. Tap to view!|

- The title carries the name. This deliberately differs from the V1.3.0 generic title "Ada yang menyebutmu 📣" (Albar, 2026-11-19).

- **Language:** the recipient's account language, like every other push (already true today).

- **Nickname at send time:** the push uses the mentioner's nickname when the push is sent. A later rename doesn't change a push already delivered.

- We don't truncate the nickname. The phone truncates long titles.

- **Unchanged:**

    - the block and hide checks;

    - at most 5 mentions per post or comment;

    - no mention notification for someone who already gets the comment/reply notification for the same comment;

    - the "Sebutan (@)" push setting;

    - one notification per post or comment, never merged.

**AC1** Budi mentions Sari in a post. Sari (ID) gets a push with title "Budi menyebutmu 📣" and body "Di sebuah postingan. Ketuk untuk lihat!".
**AC2** The same in a comment gives the body "Di komentar. Ketuk untuk lihat!".
**AC3** A recipient whose account language is EN gets "Budi mentioned you 📣" / "In a post. Tap to view!".
**AC4** Budi renames himself to "Budi Kucing" after the push was sent. The delivered push still says "Budi"; the notification-center row shows "Budi Kucing" (FR-269).
**AC5** With "Sebutan (@)" switched off, no push arrives, but the notification-center row is still created.

### FR-269: Notification-center row with nickname

- Mentions join likes, comments and follows: the backend stores the mentioner (and, for a comment mention, the comment ID) with the notification, and the server builds the row in the recipient's account language (Albar, 2026-11-19).

- **This overrides V1.3.0 FR-119.** There, the app drew rows in the device language, and the backend sent only the notification type.

- **The row is one line:** who mentioned you, and where. Nickname in bold. No second line: the text the recipient was mentioned in is not shown (Hex, 2026-11-20).

||Bahasa Indonesia|English|
|---|---|---|
|Post mention|**{nickname}** menyebutmu di sebuah postingan|**{nickname}** mentioned you in a post|
|Comment mention|**{nickname}** menyebutmu di komentar|**{nickname}** mentioned you in a comment|

- **Replies count as comments:** a mention in a reply, or in a reply to a reply, uses the comment wording. There is no separate reply wording, in the row or in the push.

- **Nickname:** the mentioner's **current** nickname, looked up each time the list loads (same as like and comment rows).

- **Look and tap:** the row looks like a post-like row. The left icon stays the current @ icon (notification rows have no avatar). The whole row is one tap target and opens the mention (FR-270); the bold nickname is not a separate link to the mentioner's profile (Hex, 2026-11-20).

- **Unread icon block (UI design, Albar 2026-11-24):** on unread rows, the icon block of **every notification type** (not only mentions) becomes white with a 1 px `lineViolet` (#DCD2F7) border, so it stands out on the tinted unread row. Read rows are unchanged. This is a change to the shared row (`_NotificationTile`), so QA checks all types.

- **Old apps (before 1.5.4):**

    - They don't read the new row data, so they keep showing their generic copy, even for new mentions.

    - They must still open the right post. The notification keeps today's link format (`POST:{postId}` / `COMMENT:{postId}`), so a tap in an old app opens the post as before. The comment ID for FR-270 goes in a separate field; the link format does not change.

**AC6** In 1.5.4, a new post mention shows one line: "**Budi** menyebutmu di sebuah postingan", with the @ icon on the left.
**AC7** A comment mention, and a mention in a reply, shows "**Budi** menyebutmu di komentar".
**AC8** An EN account sees the EN wording.
**AC9** In an app version older than 1.5.4, the new row still renders (generic copy), without errors, and tapping it opens the right post (post mention), or the post's comment section or that comment (comment mention; a 1.5.2 app may already use the comment ID through FR-244's shared rule, which is fine).
**AC10** After the backend is deployed, a recipient on an app older than 1.5.4 receives the new push copy (FR-268). Push copy comes from the backend.

### FR-270: Comment mentions open the exact comment

- **Builds on 1.5.2 FR-244** (Hex, 2026-11-20). 1.5.2 makes a mention push open the post directly instead of the notification center, and gives push and notification center one shared destination rule. 1.5.4 doesn't build its own routing; it adds the comment ID to that rule.

- **What 1.5.4 adds:** the mention notification stores the comment ID (FR-269) and sends it with the push, like comment-like notifications do. With it, a comment or reply mention opens the post and scrolls to and highlights that comment, from both the push and the row.

- **Comment highlight (UI design, Albar 2026-11-24):** the highlight behind the landed comment grows outward by 6 px on each side (−6 side margin + 6 padding, so the comment's content doesn't move) and its corner radius goes from 8 to 16. Its colour and timing stay as today. The highlight is a shared widget (`_AnchorHighlight`), so the comment-like landing changes the same way.

- **The comment is deleted but the post exists:** open the post at its comment section (Albar, 2026-11-19), with no highlight and no message.

    - ⚠️ **Code fact:** today the `focus=comments` scroll runs when the page mounts, before the comments have loaded. On a short post the page can't scroll yet, so it stays at the top with "KOMENTAR (n)" in the lower half. When the comment fetch fails and `focus=comments` is set, scroll to "KOMENTAR (n)" again after the comments load. Old mention rows (FR-272) benefit too.

- **The post is deleted:** the existing behavior from 1.5.2 FR-244: the post page's "content no longer exists" state (from the push), and the existing toast without opening (from the row).

    - ⚠️ **Code fact:** today mention rows don't check whether the post still exists before opening (`CONTENT_MENTIONED` isn't in the notification centre's `_postGone` list, and its `POST:123` link isn't parsed there), so they open the "content no longer exists" page instead of showing the toast. The shared destination function must check mentions too, so that the row shows the toast (AC15).

- Post mentions open the post, as in 1.5.2 FR-244.

- **Mentions from before 1.5.4** have no comment ID, so they open the comment section (FR-272).

- **Split with 1.5.2** (Hex, 2026-11-20): 1.5.2 doesn't store the comment ID for mentions, so in 1.5.2 a comment mention opens the post's comment section. Storing the comment ID and landing on the exact comment are done here, in 1.5.4. The 1.5.2 PRD is not changed (its FR-244 table already describes the end state).

**AC11** Tapping a comment-mention push opens the post scrolled to that comment, highlighted.
**AC12** The same from the notification-center row.
**AC13** A mention in a reply to a reply also lands on that reply.
**AC14** After the comment is deleted, tapping opens the post's comment section.
**AC15** After the post is deleted, tapping behaves as 1.5.2 FR-244 defines for a deleted post.

### FR-271: When the mentioner or the content is gone

|Situation|Behavior|
|---|---|
|Mentioner's account deleted or banned **before** the notification is sent (e.g. post held for review, approved later)|No notification, no push|
|Mentioner's account deleted or banned **after** it was sent|Row is hidden and no longer counts as unread (same as likes and comments)|
|Mentioner's ban is lifted later|The row shows again; if it was never read, it counts as unread again (same as likes and comments: the check runs each time the list loads)|
|Recipient blocks or hides the mentioner after it was sent|Row is hidden and no longer counts as unread (same as likes and comments)|
|Post or comment deleted, taken down, back under review or otherwise no longer visible after it was sent|Row stays unchanged (mentions are not recalled, V1.3.0). Tapping follows FR-270 for a deleted comment or post; in the other cases (under review, private, recipient blocked the post author) the post page shows its existing "not available" state, as 1.5.2 FR-244 defines. No new state.|
|Recipient is an official account|Row is created and the push is sent, **as today** (Hex, 2026-11-20). The mention push keeps its current rule: skip virtual accounts only. This differs from likes and comments, which skip official accounts too.|
|Recipient is a virtual account|Row is created, no push (unchanged)|

- The push is sent only after the post or comment is saved. A failed save sends nothing.

**AC16** A post with a mention is held for review; the mentioner deletes their account; the post is approved. The recipient gets nothing.
**AC17** After the recipient got a mention, the mentioner's account is banned. The row disappears and the unread count drops by one. After the ban is lifted, the row is back. The same row also disappears if the recipient blocks the mentioner.
**AC18** After the post is deleted or taken down by ops, the row stays as it was.
**AC19** An official account that is mentioned gets the row and the push, as today. A virtual account gets the row only.

### FR-272: Old mention notifications

- Mentions sent before 1.5.4 have no record of the mentioner. They keep the old generic copy ("Ada yang menyebutmu" / "Seseorang menyebutmu…", meaning "someone mentioned you"). No backfill (Albar, 2026-11-19).

- Old rows keep opening as today: post, or comment section.

**AC20** After the release, a mention row from before the release still shows the old copy and opens as before.

### FR-273: Tracking

- **No new events** (Albar, 2026-11-19). Other interaction pushes (likes, comments, follows) only track opens, and mentions follow the same rule.

- **Existing events that cover mentions:**

    - `push_opened` with `push_type = CONTENT_MENTIONED` (push tapped);

    - `app_notification_item_tapped` with `notif_type = CONTENT_MENTIONED` (row tapped); `actor_count` is now filled for mention rows.

- Everything goes to our own server (V1.5.0 self-built pipeline). Nothing depends on PostHog.

**AC21** Tapping a mention push records `push_opened` with `push_type = CONTENT_MENTIONED`.
**AC22** Tapping a mention row records `app_notification_item_tapped` with `notif_type = CONTENT_MENTIONED` and `actor_count = 1`.

## Part 2. Follow-update notifications (Hex, 2026-11-24)

Two notification types are covered, both under the push setting "Yang kamu ikuti" (Following, category `PET_DIARY`):

- **Followed-user post** (`USER_POST_PUBLISHED`): someone you follow published a public post.
- **Followed-pet Diary** (`PET_DIARY_POSTED`, V1.4.2 "追更宠物"): a pet you follow got a new public Diary post.

**What happens today** (`origin/main` `ca55416d9`, same on `dev_1.5.2`):

- The push and the notification-center row are written **right after** the post is published (or right after it passes review).
- **Push limits already in place:** for the same follower and author, at most 1 push per WIB day (`AUTHOR_DUP`); across both types, at most 3 follow-update pushes per follower per WIB day (`CAP_REACHED`, config `FOLLOW_UPDATE_PUSH_DAILY_CAP`). These stay as they are.
- **Notification center:** a followed-user post writes **one row per post, never merged**, and adds 1 to the unread badge each time, even when the push was skipped. A followed-pet Diary writes at most one row per pet per WIB day.
- **Deleted or removed posts:** nothing happens. The push can't be recalled, and the row stays. Tapping it shows the toast "Konten ini sudah tidak ada" (This content no longer exists).
- **Example (Hex, 2026-11-24):** an author Hex follows published 6 posts within 5 minutes and then deleted all 6. Hex was notified 6 times and the 6 notifications stayed. Hex confirmed these were 6 notification-center rows, not pushes (OQ-3): the push limits worked, the rows didn't merge or disappear.

### FR-321: Follow-update push sent 10 minutes late

- Both types are decided **10 minutes after the post is published** (or passes review), not at once.
- **At that moment**, posts that are no longer visible to the follower are dropped: deleted, removed by moderation, made private, or not visible because of a block (the same check as the post detail page, V1.5.2 FR-241). If nothing is left, nothing is sent and **no row is written** (FR-322).
- **One author, one push:** the window starts at the author's first post and ends 10 minutes later. Posts the same author publishes inside the window go into the same push. Later posts start a new window.
- The existing limits (1 per author per WIB day, 3 per follower per WIB day) are checked when the push is sent, not when the post is published. If the window crosses midnight WIB, the day of the send time counts.
- **Copy:** one visible post → today's copy (Appendix A). Two or more → the "many" copy with the count of posts still visible.
- **Tap:** opens the **newest** post that was still visible when the push was sent (Hex, 2026-11-24). If it has been deleted since, the post page shows its existing gone state (V1.5.2 FR-244).
- The followed-pet Diary push follows the same 10-minute rule. Its one-push-per-pet-per-day rule is unchanged, so it never shows a count.

**AC23** An author posts at 10:00. The follower gets the push at about 10:10, not at 10:00.
**AC24** An author posts at 10:00 and deletes it at 10:05. The follower gets no push and no notification-center row.
**AC25** An author posts 3 times between 10:00 and 10:06 and deletes one. The follower gets one push at about 10:10 saying 2 new posts; tapping it opens the newest of the two.
**AC26** The 1-per-author and 3-per-day limits still hold: a 4th author's update on the same day writes a row but sends no push.
**AC27** A followed pet gets a Diary post at 10:00 that is deleted at 10:03: no push and no row.

### FR-322: One author's unread updates merge into one row

- **Followed-user posts:** while the follower hasn't read the row, each new update from the same author is added to that row instead of creating a new one (Hex, 2026-11-24). This is the same "merge while unread" rule as likes today (`aggregate_key`, V1.4.0).
    - The row's time moves to the newest post, and it moves to the top of the list.
    - The unread badge counts the row once; adding a post to an unread row doesn't add to the badge.
    - Once the row has been read (tapped, or "mark all read"), the author's next update starts a new row.
- **The row is written at the same moment as the push decision (FR-321)**, 10 minutes after the post, so a post deleted within 10 minutes never appears.
- **Copy:** one visible post → today's copy; two or more → "many" copy with the count of visible posts (Appendix A). The row has no second line, as today.
- **Tap:** opens the **newest visible** post in the row (Hex, 2026-11-24), checked when tapped. The row is marked read.
- **Followed-pet Diary:** keeps one row per pet per WIB day. If more Diary posts come for that pet on the same day, the row points to the newest visible one. No count.

**AC28** An author posts 3 times in an afternoon, more than 10 minutes apart, and the follower doesn't open the notification center. The follower sees one row "{author} sudah posting 3 postingan baru", and the badge went up by 1, not 3.
**AC29** The follower reads that row; the author posts again. A new row appears for the new post; the read row stays as it was.
**AC30** Tapping a merged row opens the newest visible post and marks the row read.
**AC31** Updates from two different authors are never merged.

### FR-323: Updates for gone posts disappear

- A follow-update row only counts posts that are **still visible to the follower when the list is loaded**.
    - If some are gone, the count goes down (3 → 2) and the copy follows (2 → 1 uses the one-post copy).
    - If all are gone, **the row isn't shown** and doesn't count toward the unread badge.
    - "Gone" uses the same check as FR-321.
- This applies to rows written before 1.5.4 too: an old row whose post is gone is hidden. (Old rows are never merged; they stay one row per post.)
- A push already sent can't be recalled. Tapping a push whose post is gone shows the post page's gone state (V1.5.2 FR-244).
- Hidden rows aren't deleted; if a post comes back (for example, an appeal reverses a takedown), its row shows again.

**AC32** A row for 1 post; the author deletes the post. On the next load the row is gone and the badge goes down if it was unread.
**AC33** A merged row for 3 posts; the author deletes 1. On the next load the row says 2 posts.
**AC34** A row written before 1.5.4 for a post that was later deleted no longer shows after the update.
**AC35** A pushed post that is deleted afterwards: tapping the push shows the gone state, not an error.

### FR-324: Tracking

- **Push outcome log** (`user_post_notify_log.push_outcome`, kept 30 days): add `GONE` (all posts in the window were gone at send time) and `MERGED` (the post went into another post's push). Existing outcomes stay.
- No new client events. `push_opened` and `app_notification_item_tapped` already carry the type; `actor_count` stays 1 for these rows.

**AC36** A post deleted within 10 minutes is logged as `GONE` for each follower.
**AC37** The second and third posts of one window are logged as `MERGED`.
**AC38** `push_opened` with `push_type = USER_POST_PUBLISHED` still fires on tap.

### FR-325: Notification center without day group headers (Hex, 2026-11-24)

- Remove the group headers ("Hari ini", "Kemarin", "7 hari terakhir", "30 hari terakhir", "Sebelumnya"; today / yesterday / last 7 days / last 30 days / earlier). The notification center becomes **one continuous list, newest first**. Each row keeps its own time, as today: "Baru saja", "{n} menit lalu", "{n} jam lalu" within the day, then the date and time ("22 Nov, 20:15").
- Why: the headers break the list into short pieces and add nothing that the row time doesn't already show.
- Only the notification center changes. The growth-points history page (`exp_ledger_page.dart`) reuses the same grouping and copy; it keeps its headers.
- Paging, unread styling, "mark all read" and the order are unchanged.

**AC39** The notification center shows no group headers; rows run newest first in one list, each with its time.
**AC40** The growth-points history page still shows its day headers.

## Part 3. Less notification noise (Hex, 2026-11-24)

**What happens today** (`origin/dev_1.5.2`, which contains `main`; full survey 2026-11-24):

- **No app-wide limit:** there is no per-user daily cap across types and no quiet hours. Each type has its own rules, and they add up.
- **Every event pushes, and the center writes one row per event,** for:
    - comments and replies (`CONTENT_COMMENTED`);
    - new followers (`USER_FOLLOWED`, `PET_FOLLOWED`; only the same follower within 24 h is deduped);
    - @ mentions;
    - gifts (the center row merges per pet, but every gift pushes);
    - level-ups and L-level milestones;
    - ops campaigns (no limit per user across campaigns).
- **Already merged:** likes on a post or comment (center row merged while unread; push debounced 10 minutes per post/comment) and place comments.
- **One event, two notifications:**
    - a comment that @-mentions the post author (or the parent-comment author) sends both "commented" and "mentioned" (from reading `MentionNotifyListener.java:89-91`);
    - a resolved support ticket sends `TICKET_RESOLVED` and `CSAT_SURVEY` (`SupportTicketService.java:209,212`).
- **Fixed-time pushes:** 10:00 WIB health reminders and coupon expiry, 11:00 pet birthday (per pet), 19:00 anniversary / milestone prompt / new-user sequence. Health reminders and birthdays count per pet.
- **System auto-comments and auto-likes** (10:30 and 16:30 WIB on new posts) notify the post author like real ones.
- **Muting a category in push settings stops only the push;** the center row and badge stay. `ORDER_ACCOUNT` can't be muted.

**Push groups used below:**

- **Capped:** push-settings categories `LIKE`, `COMMENT`, `MENTION`, `FOLLOWER`, `GIFT`, `PET_DIARY` (follow updates), `ACHIEVEMENT`, `PROMO` (ops campaigns, coupons, new-user sequence).
- **Not capped:** `ORDER_ACCOUNT` (orders, refunds, account, moderation, pet slot / avatar frame expiry), vet consult pushes (Tencent IM messages and consult status), and `PET_REMINDER` (health reminders, birthday, anniversary, milestone prompt; Hex 2026-11-24: not capped).

### FR-326: Comments merge per post

- **Center:** while unread, comments on the same post merge into one row (`aggregate_key` `COMMENT:POST:{postId}`), and replies to the same comment of yours merge into one row (`COMMENT:REPLY:{commentId}`), like likes today.
    - Title: one person → today's copy; two or more people → "many" copy (Appendix A). A person who comments twice counts once The name shown is the **newest** commenter, as for merged likes (`InteractionCopyRenderer` uses `latestNickname`).
    - Second line: the newest comment's text, as today's single row shows its comment.
    - Time and position follow the newest comment; the badge counts the row once.
    - Once read, the next comment starts a new row.
- **Push:** debounced **10 minutes per post** (per comment for replies), like likes: the first comment in the window pushes, later ones in the window don't.
- **Tap:** opens the post at the comment section with the **newest** comment highlighted (FR-270's highlight).
- Comments that are deleted are no longer counted (same as FR-323 for posts); a row with none left isn't shown.

**AC41** Three people comment on one post within an hour while the author hasn't opened the center: one row "{newest} dan 2 lainnya mengomentari postinganmu" showing the newest comment, badge +1.
**AC42** Five comments within 10 minutes send one push.
**AC43** After the author reads the row, a new comment makes a new row.

### FR-327: New followers merge

- **Center:** while unread, new followers merge into one row (`FOLLOW:USER:{recipientId}`); new followers of the same pet merge into one row per pet (`FOLLOW:PET:{petId}`).
    - One person → today's row with the "Ikuti Balik" (follow back) button. Two or more → "many" copy, **no follow-back button**; tapping opens the user's follower list (`/users/{me}/follows?tab=followers`).
    - Pet followers, two or more → "many" copy; tapping opens the **newest follower's profile** (Hex, 2026-11-24; the app has no pet-followers list, and a single pet-follow row already opens the follower's profile).
- **Push:** debounced 10 minutes per recipient (per pet for pet follows).
- The existing 24 h dedup of the same follower stays.

**AC44** Four people follow a user within an hour: one row "{newest} dan 3 lainnya mulai mengikutimu" with no button; tapping opens the follower list.
**AC45** One follower: the row and "Ikuti Balik" button are as today.

### FR-328: Gift push debounced

- The center already merges gifts per pet (`GIFT:PET:{petId}`). Add a **10-minute push debounce per pet**, like likes. The center row is unchanged.

**AC46** Five gifts to one pet within 10 minutes send one push; the center shows one merged row.

### FR-329: One event, one notification

- **Comment that mentions someone:** if a person would get both "commented" (FR-326) and "mentioned" for the **same comment**, they get **only the mention** (push and row). Other recipients of the comment are unchanged.
- **Support ticket resolved:** `TICKET_RESOLVED` and `CSAT_SURVEY` become **one** push and one row (Appendix A); tapping opens the ticket with the rating.

**AC47** Budi comments "@Rina …" on Rina's post: Rina gets one mention notification, not a comment notification as well.
**AC48** A resolved ticket gives the user one push and one row.

### FR-330: At most 8 capped pushes per user per day

- Each user gets at most **8 pushes per WIB day** from the capped groups. Pushes beyond 8 are not sent; the center row is written as usual.
- Type-specific limits still apply first (follow updates 3/day, ops 2/day in FR-332, debounces).
- Not-capped groups are never blocked and don't count toward the 8.
- First come, first served within the day; nothing is re-sent later.

**AC49** A user who has had 8 capped pushes today gets no 9th; the center shows the row.
**AC50** An order-shipped push still arrives after the 8th capped push and doesn't count.

### FR-331: Quiet hours 00:00–07:00 WIB

- From **00:00 to 07:00 WIB**, capped-group pushes are **held**, not sent. The center rows are written at once, as usual.
- At **07:00**, if a user has held pushes:
    - one held push → send it as it is;
    - two or more → send **one summary push** "Ada {n} notifikasi baru untukmu 🐾" (Appendix A); tapping opens the notification center.
    - Held pushes whose content is gone by 07:00 are dropped (same check as FR-323) and not counted.
- The 07:00 push counts as 1 toward that day's cap (FR-330).
- Not-capped groups are sent at once at any hour. Today's fixed-time pushes (10:00, 11:00, 19:00) are outside the window.
- Times are WIB for everyone, like the other scheduled pushes.

**AC51** A comment at 01:00 doesn't push; at 07:00 the user gets it.
**AC52** Three likes, a comment and a follow between 00:00 and 07:00: one summary push at 07:00 "Ada 5 notifikasi baru untukmu 🐾"; tapping opens the center.
**AC53** An order-shipped event at 02:00 pushes at 02:00.

### FR-332: At most 2 ops pushes per user per day

- Ops campaign pushes (`OPS_ANNOUNCEMENT`): at most **2 per user per WIB day**, no weekly limit. A user over the limit gets no push for that campaign; the center row is written as usual.
- They also count toward the 8 in FR-330, and are held in quiet hours (FR-331).
- The campaign's send result records users skipped by the limit (`OPS_CAP`) so ops can see how many weren't pushed.

**AC54** A third campaign on the same day writes a center row but sends no push to a user who already got 2.
**AC55** The campaign's send log shows how many users were skipped by the limit.

### FR-333: System auto-comments and auto-likes follow the same rules

- They keep notifying the post author (Hex, 2026-11-24), but now go through FR-326 merging, the like debounce, FR-330 cap and FR-331 quiet hours like any other comment or like. No special handling.

**AC56** An auto-comment and a real comment on the same unread post merge into one row.

### FR-334: Tracking and switches

- **Push outcome log for all types:** today only follow updates log an outcome. Add one log (or extend the existing one) recording, per recipient and notification: `PUSHED`, `DEBOUNCED`, `DAILY_CAP` (FR-330), `QUIET_HELD` / `QUIET_SUMMARY` (FR-331), `OPS_CAP` (FR-332), `MERGED_INTO_MENTION` (FR-329), `MUTED`, `FAILED`. Keep 30 days.
- **Config switches** (env, like `FOLLOW_UPDATE_PUSH_DAILY_CAP`): daily cap (default 8), quiet start / end (00:00 / 07:00), ops daily cap (default 2), comment / follower / gift debounce (10 min), each with an on/off switch so a rule can be turned off without a release.
- No new client events; `push_opened` already carries `push_type` (the summary push uses `push_type = QUIET_SUMMARY`).

**AC57** Each outcome above appears in the log for the matching case.
**AC58** Setting the daily cap to 0 or the switch off turns FR-330 off.
**AC59** Tapping the 07:00 summary push records `push_opened` with `push_type = QUIET_SUMMARY`.
**AC60** Pushes per user per day (p50, p95, max) can be read from the log.
**AC61** Old apps (below 1.5.4) get the same server-side limits (they are server rules).
**AC62** Merged comment and follower rows show on old apps as a single row with the server-rendered title.
**AC63** The comment-merge and follower-merge rows hide when all their items are gone.
**AC64** Muting a category still stops only the push, as today.

## 5. Non-goals

- Who can be mentioned, the 5-mention limit, and the @ picker are all unchanged.

- No merging of mentions ("Budi dan 2 lainnya…", meaning "Budi and 2 others…").

- No backfill of old rows.

- No push "sent" counting, for mentions or any other interaction push. If wanted, that would be its own ticket covering all interaction pushes.

- No change to the "Sebutan (@)" setting copy.

- No avatar on the row and no tap-the-name-to-open-profile.

- A notification small icon for Android pushes. The app has no `ic_stat_*` / `default_notification_icon`, so Android shows the launcher icon; this is a separate ticket.

- The contrast of the grey time text on unread rows (#9690A6); it goes to the design system.

- **Part 3:** no change to which categories users can mute, or to muting stopping only the push. No per-user custom quiet hours (fixed WIB window). No new push category. Level-up / milestone push + celebration popup stay as they are.

- **Part 2:** no change to the daily push limits, the "Yang kamu ikuti" setting, or other push types (likes, comments, gifts). No push recall and no OS-level notification grouping (Tencent push sends no collapse key today). No merged row for followed-pet Diaries.

## 6. Success

Shipped in 1.5.4 and AC1 to AC40 verified by QA on stag and production. No metric target. For Part 3, compare pushes per user per day (p50 / p95 from FR-334) and the push opt-out rate for the 2 weeks before and after release. For Part 2, compare follow-update push opens per push (`push_opened` / `PUSHED` count) for the 2 weeks before and after release.

## 7. Open questions

|#|Question|Owner|Needed by|
|---|---|---|---|
|OQ-1|FR numbers re-checked 2026-11-23 against `PetGo` `main` `991e901` (all branches): V1.5.2 uses FR-226 to FR-259 (FR-225 is the last V1.5.0 number), and no doc uses FR-260 or higher. ⚠️ The Roadmap's 1.5.2 note (2026-11-20) still says "next free FR-260" and leaves two 1.5.2 items undecided (monthly level shop coupon, vet page redesign); if either gets FRs, they must start at FR-282. KTP share link FR-260 to FR-267; this PRD FR-268 to FR-273 (was FR-226 to FR-231); browsing history FR-274 to FR-281. Next free number: FR-282. Re-check before merging to `PetGo`|Albar|Before merging to `PetGo`|
|~~OQ-3~~|~~Hex's example: pushes or notification-center rows?~~ **Closed 2026-11-24 (Hex): they were 6 notification-center rows, not pushes.** The push limits worked; the rows are what FR-322 and FR-323 fix.|Hex|Done|
|~~OQ-4~~|~~Part 2 and Part 3 copy to be approved~~ **Closed 2026-11-24: approved by Hex after a native-speaker check (follow-update "many" copy reworded).**|Hex|Done|
|~~OQ-5~~|~~`PET_REMINDER` inside or outside the cap~~ **Closed 2026-11-24 (Hex): pet reminders stay outside the 8/day cap and quiet hours.**|Hex|Done|
|OQ-6|Old apps (below 1.5.4) show a follow-back button on every new-follower row, for the one person in `actorUserId` (`notification_center_page.dart` `_followBack`, main :1320). On a merged row that would read "Nadia dan 3 lainnya mulai mengikutimu [Ikuti Balik]" and follow back only Nadia. Proposed: for merged rows (2+ people) the server leaves out `actorUserId` / `actorToken`, so the old app hides the button by itself. Dev to confirm what tapping such a row does on an old app (should open the follower list or nothing, not crash).|Dev|Before dev starts|

## Appendix A. Copy

All copy below is approved (Albar, 2026-11-19; Part 2 and Part 3 copy by Hex, 2026-11-24, after a native-speaker check).

|Place|Bahasa Indonesia|English|
|---|---|---|
|Push title|{nickname} menyebutmu 📣|{nickname} mentioned you 📣|
|Push body, post|Di sebuah postingan. Ketuk untuk lihat!|In a post. Tap to view!|
|Push body, comment|Di komentar. Ketuk untuk lihat!|In a comment. Tap to view!|
|Row title, post|**{nickname}** menyebutmu di sebuah postingan|**{nickname}** mentioned you in a post|
|Row title, comment|**{nickname}** menyebutmu di komentar|**{nickname}** mentioned you in a comment|
|Follow-update, one post (existing, unchanged)|{0} baru posting nih, intip yuk 👀 / Diary post: {0} baru update Diary {1}, kepoin yuk 👀|{0} just posted something new, take a peek 👀 / {0} just updated {1}'s Diary, take a peek 👀|
|Follow-update, 2+ posts (new, push title and row; Part 2, approved 2026-11-24)|{0} sudah posting {1} postingan baru, intip yuk 👀|{0} has posted {1} new posts, take a peek 👀|
|Comments, 2+ people (new, Part 3)|{0} dan {1} lainnya mengomentari postinganmu|{0} and {1} others commented on your post|
|Replies, 2+ people (new, Part 3)|{0} dan {1} lainnya membalas komentarmu|{0} and {1} others replied to your comment|
|New followers, 2+ (new, Part 3)|{0} dan {1} lainnya mulai mengikutimu|{0} and {1} others started following you|
|Pet followers, 2+ (new, Part 3)|{0} dan {1} lainnya mulai mengikuti {2}|{0} and {1} others started following {2}|
|Ticket resolved + rating (new, Part 3, replaces two notifications)|Tiketmu sudah selesai. Gimana pelayanan kami? Kasih nilai yuk ⭐|Your ticket is resolved. How did we do? Rate us ⭐|
|07:00 summary push (new, Part 3)|Ada {n} notifikasi baru untukmu 🐾|You have {n} new notifications 🐾|
|Followed-pet Diary (existing, unchanged)|{0} punya cerita baru|{0} has a new story|
|Row, old fallback (unchanged)|Ada yang menyebutmu / Seseorang menyebutmu di sebuah postingan / Seseorang menyebutmu di sebuah komentar|Someone mentioned you / Someone mentioned you in a post / Someone mentioned you in a comment|

## Appendix B. Notes for developers

Paths are at `origin/main` `ca55416d9` (checked 2026-11-20). 1.5.2 will change the routing files listed under "Deep link"; re-check those against `dev_1.5.2`.

- **Push today:**

    - `notify/service/MentionNotifyListener.java:128-129` calls `sendWithCopy(..., args = null, ...)`;

    - `sendWithCopy` skips virtual accounts but not official accounts, and doesn't store the actor or the comment ID;

    - `ContentMentionedEvent` already carries `commentId` (null = post mention);

    - copy keys `notify.CONTENT_MENTIONED.{POST,COMMENT}.{title,body}` are in `i18n/messages_id.properties:3542-3545`, `messages_en.properties:3619-3622`, `messages.properties:3613-3616` and `messages_zh_CN.properties:3631-3634`.

- **Pattern to reuse:** `NotificationService`:

    - `INTERACTION_TYPES` (:55-58);

    - `sendInteraction` (:242-280) stores the actor (`aggregates.addActor`) and the comment ID;

    - `pushInteraction` (:592-620) pushes after commit and skips official and virtual accounts. ⚠️ For mentions, **don't copy the official-account skip**: keep today's rule (skip virtual only, FR-271).

- Suggested: a dedicated `sendMention(...)` along these lines, with `aggregateKey = null` (never merged). Keep the `pushToUser` / `pushAllowed` pair (`PushExitStructureTest`).

- **Copy rendering:**

    - `InteractionCopyRenderer.title` (:132-173) needs a `CONTENT_MENTIONED` case (today `default` throws);

    - `fallbackTitle` needs one too;

    - add templates `notify.tpl.mentioned.post` / `.comment` (row) and the new push title/body keys in all four message files.

- **Mentioner gone:** `InteractionCopyRenderer.resolve` / `AccountQueryService.findActorViews` return no `ActorView` for deleted or banned accounts, so use that to skip. The list already hides rows whose actor is filtered and recomputes unread the same way (`NotificationCenterService`, T-36), which also covers unban and recipient blocks.

- **List:**

    - `NotificationCenterService.render` (:420-445) builds the title and actor once the type is an interaction type, but it only shows text for comment rows (looked up live). Mention rows show **no body text** (FR-269): don't add `CONTENT_MENTIONED` to the comment-text lookup;

    - old rows with no actor stay on the `plain` path (FR-272).

- **App:**

    - add `'CONTENT_MENTIONED'` to `serverCopyTypes` (`features/notify/domain/notification_item.dart:29-41`);

    - fallback strings stay in `app_id.arb:2376-2378` / `app_en.arb:3656-3661`;

    - row page: `notification_center_page.dart` (:1114, :1181-1183, `_serverTitle` :1289+);

    - unread icon block (FR-269): `_NotificationTile`, white fill + 1 px `AppColors.lineViolet` border on unread rows, all types;

    - comment highlight (FR-270): `_AnchorHighlight` on the post detail page, outset 6 (−6 horizontal margin + 6 padding), radius 8 → 16; after a failed anchor fetch with `focus=comments`, run `ensureVisible` on "KOMENTAR (n)" again once the comments have loaded;

    - post detail: the bottom-bar like count, comment like counts and "KOMENTAR (n)" use tabular figures (`FontFeature.tabularFigures()`) so the numbers don't shift as they change.

- **Deep link:** today `core/router/deep_link_routes.dart:215-221` (`COMMENT:` → `?focus=comments`); comment-likes pass `commentId` at :230-232 → `/content/{postId}?focus=comments&commentId={id}`. 1.5.2 FR-244 replaces `pushPayloadToLocation` and `_onTap` with one shared destination function; add the mention `commentId` case there, and include mentions in its deleted-post check (today `_postGone` skips `CONTENT_MENTIONED`, FR-270).

- **Part 2 (follow-update), code at `origin/main` `ca55416d9`:**

    - Listeners: `notify/service/UserPostNotifyListener.java` (`@Async` after commit, :77-116) and `notify/service/PetDiaryNotifyListener.java` (:84-126), both triggered by `ContentPublishedEvent` from `ContentService` (:647 publish, :384 review approved, :784 scheduled). Move the push decision **and** the row write to a job that runs 10 minutes later (e.g. a delayed queue, or a table of pending windows keyed by follower × author polled every minute). The kill switch `FOLLOW_UPDATE_PUSH_ENABLED` stays.
    - Push decision order stays in `NotificationService.sendUserPostPublished` (:506-570; dev_1.5.2 :563-640): official/virtual → muted → `claimAuthorDaily` → `FollowUpdatePushQuota` → push. Add the gone check (same as `ContentDetailService.requireVisiblePost` plus V1.5.2 FR-241) before it.
    - Merge: reuse `aggregate_key` + `writeAggregate` (:302-322) with key `FOLLOW_POST:{authorId}`; render `.one` / `.many` in `InteractionCopyRenderer` (:144-166) with the count of visible posts. Today the title is rendered at write time; for FR-323 it must be rendered at read time from the visible count.
    - Gone rows (FR-323): filter in `NotificationCenterService` when listing and in the unread-badge count. Today only comment bodies are checked (`bodyDeleted`, :432-436).
    - Copy: `notify.tpl.userPostPublished.post` / `.diary` (`messages_id.properties:3666-3667`, `messages_en.properties:3743-3744`; dev_1.5.2 :3694-3695 / :3771-3772); add `notify.tpl.userPostPublished.many`.
    - Group headers (FR-325): drop the `groupOf` / `notifyGroup*` headers in `notification_center_page.dart` (~:701-705 on `dev_1.5.2`); keep them in `exp_ledger_page.dart` (:146-150).
    - App: tapping a merged row needs the newest visible post ID from the server (the row's `targetRef`); the center already probes deleted posts for this type (`_postGone`, `notification_center_page.dart` :488-505).

- **Part 3 (less noise), code at `origin/dev_1.5.2`:**

    - Merge pattern to copy: `NotificationService.writeAggregate` / `sendInteraction` and the partial unique index on `(recipient_user_id, aggregate_key) WHERE is_read = false`; push debounce via Redis `SET NX EX` (`debounceKey`, `PUSH_DEBOUNCE = 10 min`, `NotificationService.java:64`).
    - Comments: `ContentNotifyListener.java:122,141,150`. Followers: `FollowNotifyListener.java:36,67-70`, `PetFollowNotifyListener.java:37,75-79`. Gifts: `NotificationService.java:353-375`, `GiftNotifyListener.java:80`. Mentions: `MentionNotifyListener.java:89-91`. Tickets: `SupportTicketService.java:209,212`. Ops: `OpsNotificationDispatcher.java:224,296,312`. Auto-comment: `AutoCommentService.java`.
    - Cap and quiet hours belong in one place every push passes through (`NotificationPusher` / the push gate before `LiveTencentImClient`), keyed by `PushCategory`. Tencent IM chat pushes don't pass through our server and stay outside.
    - Quiet-hours hold: a table of held pushes per user, flushed by a 07:00 WIB job.

- **Tests to update:** `MentionNotifyTest.java` (:112-123, :143-166), `PushGateIntegrationTest.java:120`, `PushExitStructureTest`.

## Change log

|Date|Who|Change|
|---|---|---|
|2026-11-19|Albar|First draft: FR-226 to FR-231, AC1 to AC22. Decisions from the coaching session on 2026-11-19.|
|2026-11-19|Albar|Review pass: text line hidden whenever the post/comment is no longer visible; old apps keep today's link format; push copy reaches old apps; text length and plain @/#; FR-119 override stated. ACs renumbered AC1 to AC25.|
|2026-11-19|Albar|Comment edits follow the same snapshot rule (confirmed). Dev questions wait for Hex's review.|
|2026-11-20|Hex|Review: renumbered FR-226–231 → **FR-268–273** (1.5.2 and KTP took the old numbers); code baseline moved to `origin/main` `ca55416d9`; FR-270 now builds on 1.5.2 FR-244 (OQ-2 for the comment-ID gap); nickname = user nickname, no display-name fallback, row shows the current nickname; stored text explained with an example, emoji-safe cut, line breaks; "not visible" defined per recipient with a case table; official-account push skip marked as a change; unban and recipient-blocks-mentioner added; row tap and icon stated; push language note corrected; frontmatter fixed. ACs renumbered AC1 to AC28.|
|2026-11-20|Hex|Decisions: comment ID stored and exact-comment landing done in 1.5.4, 1.5.2 PRD unchanged (OQ-2 closed); official accounts keep getting the mention push (skip virtual only, AC25); merge order with the other 1.5.4 PRDs added to §0.|
|2026-11-20|Hex|Row has **no second line**: the mentioned text is not shown (Hex). Removed the stored text, its length / emoji / visibility rules and the related ACs; replies use the comment wording. ACs renumbered AC1 to AC22.|
|2026-11-23|Hex|Final check: tap behavior for under-review / private / blocked-post-author cases stated (FR-271); AC17 also covers recipient blocking the mentioner; AC9 allows a 1.5.2 app to land on the comment. No rule changes.|
|2026-11-23|Hex|Status set to **final**.|
|2026-11-23|Albar|Merge-order text aligned with the final browsing-history PRD (server-side recording, app post detail page untouched). Formatting only: export backslashes and stray title line removed. No rule changes.|
|2026-11-24|Albar|UI design decisions written in (design deck in §0): white unread icon block with a violet border for all notification types (FR-269); larger comment highlight, radius 16 (FR-270); re-scroll to the comment section after a deleted comment, and mention rows must check for a deleted post so the row shows the toast (FR-270 code facts); tabular figures on post-detail counts (Appendix B); Android push small icon and time-text contrast out of scope (§5); old fallback copy spelled out (Appendix A). No ACs changed. Needs Hex's confirmation.|
|2026-11-24|Hex|Accepted Albar's UI decisions (white unread icon block for all types, larger comment highlight); mockup C2 redrawn as the fixed behaviour (comment section at the top). **Added Part 2, follow-update notifications (FR-321 to FR-324, AC23 to AC38)**: push sent 10 minutes late with gone posts dropped and one author's window merged; unread rows merged per author; rows for gone posts hidden; tap opens the newest visible post; followed-pet Diary also delayed and gone-checked. Status back to **draft** until Hex confirms.|
|2026-11-24|Hex|**FR-325 added**: notification center drops its day group headers and becomes one continuous list (AC39, AC40). Mockup B1, B2, C3 updated.|
|2026-11-24|Hex|PRD widened to **Notification Optimization**; folder renamed to `通知优化/`. **Part 3 added (FR-326 to FR-334, AC41 to AC64)** from the app-wide notification survey: comments and followers merge like likes, gift push debounced, one notification per event (comment+mention, ticket+rating), 8 capped pushes per user per day, quiet hours 00:00–07:00 WIB with a 07:00 summary, ops pushes 2 per user per day, auto-comments/likes follow the same rules, outcome log and config switches. OQ-5 (pet reminders outside the cap) and OQ-6 (old apps and merged follower rows) open.|
|2026-11-24|Hex|Appendix A: follow-update "many" copy changed to "{0} sudah posting {1} postingan baru, intip yuk 👀" after a native-speaker review ("baru posting {1}" could read as "only posted {1}"); English aligned.|
|2026-11-24|Hex|OQ-3 closed (notification-center rows, not pushes). Status set to **final** (Hex: "功能可以"). UI for Part 2 and Part 3 starts.|
|2026-11-24|Hex|UI step 2 findings decided: pet-follower "many" copy aligned with the single row ("mulai mengikuti"); a merged pet-follower row opens the newest follower's profile (FR-327).|
|2026-11-24|Hex|UI step 4 check: the name in merged rows is the newest person (as merged likes, `latestNickname`); AC41 corrected.|
|2026-11-24|Hex|UI final ("定稿"), 22 screens split into `拆页-App/`.|
