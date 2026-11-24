# 1\-5\-4 Mention Nickname prd

---
title: "@Mention Notifications with Nickname"
status: final
created: 2026\-11\-19
updated: 2026\-11\-23
---

# PRD: TailTopia Pet App — @Mention Notifications with Nickname \(V1\.5\.4\)

## 0\. About this document

- **What this is:** the fix for @mention notifications\. Today both the push and the notification center say that *someone* mentioned you\. After this change they say *who*: the push reads "Budi menyebutmu 📣", and the notification\-center row reads "**Budi** menyebutmu di komentar"\. A comment mention also opens the exact comment\.

- **Who it is for:** product \(Albar, Hex\), Dai's backend and app developers, QA\.

- **Release:** V1\.5\.4, as one release for backend and app \(Albar, 2026\-11\-19\)\. No early backend hotfix\.

- **Source spec:** V1\.3\.0 PRD FR\-119, "@ 通知文案" \(signed off 2026\-09\-01\)\. This PRD **replaces** that copy table\. Where they differ, this PRD wins\.

- **Code baseline:** `petgo-platform` `origin/main` `ca55416d9` \(V1\.5\.0, live\), checked 2026\-11\-20\. `dev_1.5.2` doesn't exist yet; the 1\.5\.2 changes that touch this PRD come from the 1\.5\.2 PRDs \(§4, FR\-270\)\. Re\-check against `dev_1.5.2` once it exists\.

- **Depends on:** V1\.5\.2 PRD "头像框与推送直达" **FR\-244** \(push opens the target page directly; push and notification center share one destination rule\)\. 1\.5\.4 builds on it and merges after it\.

- **Merge order \(1\.5\.4, Hex 2026\-11\-20\):** all three 1\.5\.4 PRDs \(KTP share link, mention nickname, browsing history\) build on 1\.5\.2 and merge after it\. Shared code: the one push/notification destination function that 1\.5\.2 FR\-244 creates\. The mention PRD adds the comment\-ID case \(FR\-270\) and merges first; the KTP PRD adds the card\-link route \(FR\-263\) and rebases on it\. Browsing history works on the Saya page and the collect module and doesn't touch that function, so it can merge any time after 1\.5\.2; it records post opens on the post detail page, which the mention PRD also scrolls, so whichever merges second re\-checks the detail page\.

- **Numbering:** **FR\-268 to FR\-273**, **AC1 to AC22**\. V1\.5\.2 uses FR\-225 to FR\-259 and the KTP share link PRD uses FR\-260 to FR\-267, so this PRD starts at FR\-268\. The browsing\-history PRD follows at FR\-274 \(OQ\-1\)\.

- **Decisions:** every rule here was decided by Albar on 2026\-11\-19 \(log in `.memlog.md`\), unless marked Hex 2026\-11\-20\. Copy is approved\.

## 1\. Why

A notification that says "someone mentioned you" gives the reader no reason to tap: they can't tell whether it is a friend, a stranger or spam\. Naming the person is what makes a mention worth opening\.

V1\.3\.0 specified nickname copy for both the push and the notification center\. It never reached production\. This PRD brings the code in line with that spec and makes mentions a little richer: the push and the row name the person, and comment mentions open the exact comment\.

**Goal:** mention notifications name the mentioner everywhere and open where the mention is\. **Success = shipped and verified by QA\.** There is no metric target \(Albar, 2026\-11\-19\)\.

## 2\. What is wrong today

We checked the code on `origin/main` `ca55416d9` and confirmed the wrong copy\.

|Where|V1\.3\.0 spec|What users get today|
|---|---|---|
|Push title|Ada yang menyebutmu 📣|**Kamu disebut**|
|Push body, post|\{nickname\} menyebutmu di sebuah postingan\. Ketuk untuk lihat\!|**Seseorang** menyebutmu di sebuah postingan|
|Push body, comment|\{nickname\} menyebutmu di komentar\. Ketuk untuk lihat\!|**Seseorang** menyebutmu di sebuah komentar|
|Notification center|\{nickname\} menyebutmu di sebuah postingan / di komentar|"Ada yang menyebutmu" \+ "Seseorang menyebutmu di sebuah postingan / komentar"|

Root causes:

1. **Push\.** The backend copy is a fixed sentence with no placeholder for a name\. The mention listener sends it without arguments\. The listener has the mentioner's user ID but never looks up the nickname\.

2. **Notification center\.** Likes, comments and follows store *who* acted, and the list returns their nickname\. Mentions were never added to that group, so the app has no name to show and falls back to its own fixed strings\.

3. **Where the requirement was lost\.** The V1\.3\.0 implementation story for mention notifications required separate post and comment wording but dropped the nickname that the signed\-off spec required\.

4. **Not the 1\.4\.2 "nickname variable" work\.** That work \(AB\-37\) only puts the *recipient's* own nickname into ops campaign pushes\. It never touched mentions\.

5. **Not fixable in admin\.** The copy lives in code \(backend message files and app string files\), not in an editable template\. This needs a backend change and an app release\.

Also found:

- The mention notification does not store the comment ID \(the mention event has it, but it is dropped when the notification is written\)\. So a comment mention can only open the post's comment section, not the comment\. Today the push also lands in the notification center first; 1\.5\.2 FR\-244 changes that \(§4\)\.

- If the mentioner's account was deleted or banned before the notification was sent \(e\.g\. a post held for review and approved later\), the notification still goes out\.

- The push is already in the recipient's account language \(the backend renders it with the recipient's locale\)\. The V1\.3\.0 rule "push is always Indonesian" was never what the code did, so nothing changes there\.

## 3\. Glossary

- **Mentioner:** the user who wrote the @mention\.

- **Recipient:** the user who was mentioned\.

- **Post mention / comment mention:** a mention inside a post's text, or inside a comment or reply\.

- **Nickname:** the mentioner's user nickname \(用户昵称\), the same name that like and comment notifications show\. Not a pet name\.

- **Account language:** the language the recipient chose in the app \(ID or EN\)\. Every push and every interaction row already uses it\.

## 4\. Features

### FR\-268: Push copy with the mentioner's nickname

||Bahasa Indonesia|English|
|---|---|---|
|Title \(both\)|\{nickname\} menyebutmu 📣|\{nickname\} mentioned you 📣|
|Body, post mention|Di sebuah postingan\. Ketuk untuk lihat\!|In a post\. Tap to view\!|
|Body, comment mention|Di komentar\. Ketuk untuk lihat\!|In a comment\. Tap to view\!|

- The title carries the name\. This deliberately differs from the V1\.3\.0 generic title "Ada yang menyebutmu 📣" \(Albar, 2026\-11\-19\)\.

- **Language:** the recipient's account language, like every other push \(already true today\)\.

- **Nickname at send time:** the push uses the mentioner's nickname when the push is sent\. A later rename doesn't change a push already delivered\.

- We don't truncate the nickname\. The phone truncates long titles\.

- **Unchanged:**

    - the block and hide checks;

    - at most 5 mentions per post or comment;

    - no mention notification for someone who already gets the comment/reply notification for the same comment;

    - the "Sebutan \(@\)" push setting;

    - one notification per post or comment, never merged\.

**AC1** Budi mentions Sari in a post\. Sari \(ID\) gets a push with title "Budi menyebutmu 📣" and body "Di sebuah postingan\. Ketuk untuk lihat\!"\.
**AC2** The same in a comment gives the body "Di komentar\. Ketuk untuk lihat\!"\.
**AC3** A recipient whose account language is EN gets "Budi mentioned you 📣" / "In a post\. Tap to view\!"\.
**AC4** Budi renames himself to "Budi Kucing" after the push was sent\. The delivered push still says "Budi"; the notification\-center row shows "Budi Kucing" \(FR\-269\)\.
**AC5** With "Sebutan \(@\)" switched off, no push arrives, but the notification\-center row is still created\.

### FR\-269: Notification\-center row with nickname

- Mentions join likes, comments and follows: the backend stores the mentioner \(and, for a comment mention, the comment ID\) with the notification, and the server builds the row in the recipient's account language \(Albar, 2026\-11\-19\)\.

- **This overrides V1\.3\.0 FR\-119\.** There, the app drew rows in the device language, and the backend sent only the notification type\.

- **The row is one line:** who mentioned you, and where\. Nickname in bold\. No second line: the text the recipient was mentioned in is not shown \(Hex, 2026\-11\-20\)\.

||Bahasa Indonesia|English|
|---|---|---|
|Post mention|**\{nickname\}** menyebutmu di sebuah postingan|**\{nickname\}** mentioned you in a post|
|Comment mention|**\{nickname\}** menyebutmu di komentar|**\{nickname\}** mentioned you in a comment|

- **Replies count as comments:** a mention in a reply, or in a reply to a reply, uses the comment wording\. There is no separate reply wording, in the row or in the push\.

- **Nickname:** the mentioner's **current** nickname, looked up each time the list loads \(same as like and comment rows\)\.

- **Look and tap:** the row looks like a post\-like row\. The left icon stays the current @ icon \(notification rows have no avatar\)\. The whole row is one tap target and opens the mention \(FR\-270\); the bold nickname is not a separate link to the mentioner's profile \(Hex, 2026\-11\-20\)\.

- **Old apps \(before 1\.5\.4\):**

    - They don't read the new row data, so they keep showing their generic copy, even for new mentions\.

    - They must still open the right post\. The notification keeps today's link format \(`POST:{postId}` / `COMMENT:{postId}`\), so a tap in an old app opens the post as before\. The comment ID for FR\-270 goes in a separate field; the link format does not change\.

**AC6** In 1\.5\.4, a new post mention shows one line: "**Budi** menyebutmu di sebuah postingan", with the @ icon on the left\.
**AC7** A comment mention, and a mention in a reply, shows "**Budi** menyebutmu di komentar"\.
**AC8** An EN account sees the EN wording\.
**AC9** In an app version older than 1\.5\.4, the new row still renders \(generic copy\), without errors, and tapping it opens the right post \(post mention\), or the post's comment section or that comment \(comment mention; a 1\.5\.2 app may already use the comment ID through FR\-244's shared rule, which is fine\)\.
**AC10** After the backend is deployed, a recipient on an app older than 1\.5\.4 receives the new push copy \(FR\-268\)\. Push copy comes from the backend\.

### FR\-270: Comment mentions open the exact comment

- **Builds on 1\.5\.2 FR\-244** \(Hex, 2026\-11\-20\)\. 1\.5\.2 makes a mention push open the post directly instead of the notification center, and gives push and notification center one shared destination rule\. 1\.5\.4 doesn't build its own routing; it adds the comment ID to that rule\.

- **What 1\.5\.4 adds:** the mention notification stores the comment ID \(FR\-269\) and sends it with the push, like comment\-like notifications do\. With it, a comment or reply mention opens the post and scrolls to and highlights that comment, from both the push and the row\.

- **The comment is deleted but the post exists:** open the post at its comment section \(Albar, 2026\-11\-19\)\.

- **The post is deleted:** the existing behavior from 1\.5\.2 FR\-244: the post page's "content no longer exists" state \(from the push\), and the existing toast without opening \(from the row\)\.

- Post mentions open the post, as in 1\.5\.2 FR\-244\.

- **Mentions from before 1\.5\.4** have no comment ID, so they open the comment section \(FR\-272\)\.

- **Split with 1\.5\.2** \(Hex, 2026\-11\-20\): 1\.5\.2 doesn't store the comment ID for mentions, so in 1\.5\.2 a comment mention opens the post's comment section\. Storing the comment ID and landing on the exact comment are done here, in 1\.5\.4\. The 1\.5\.2 PRD is not changed \(its FR\-244 table already describes the end state\)\.

**AC11** Tapping a comment\-mention push opens the post scrolled to that comment, highlighted\.
**AC12** The same from the notification\-center row\.
**AC13** A mention in a reply to a reply also lands on that reply\.
**AC14** After the comment is deleted, tapping opens the post's comment section\.
**AC15** After the post is deleted, tapping behaves as 1\.5\.2 FR\-244 defines for a deleted post\.

### FR\-271: When the mentioner or the content is gone

|Situation|Behavior|
|---|---|
|Mentioner's account deleted or banned **before** the notification is sent \(e\.g\. post held for review, approved later\)|No notification, no push|
|Mentioner's account deleted or banned **after** it was sent|Row is hidden and no longer counts as unread \(same as likes and comments\)|
|Mentioner's ban is lifted later|The row shows again; if it was never read, it counts as unread again \(same as likes and comments: the check runs each time the list loads\)|
|Recipient blocks or hides the mentioner after it was sent|Row is hidden and no longer counts as unread \(same as likes and comments\)|
|Post or comment deleted, taken down, back under review or otherwise no longer visible after it was sent|Row stays unchanged \(mentions are not recalled, V1\.3\.0\)\. Tapping follows FR\-270 for a deleted comment or post; in the other cases \(under review, private, recipient blocked the post author\) the post page shows its existing "not available" state, as 1\.5\.2 FR\-244 defines\. No new state\.|
|Recipient is an official account|Row is created and the push is sent, **as today** \(Hex, 2026\-11\-20\)\. The mention push keeps its current rule: skip virtual accounts only\. This differs from likes and comments, which skip official accounts too\.|
|Recipient is a virtual account|Row is created, no push \(unchanged\)|

- The push is sent only after the post or comment is saved\. A failed save sends nothing\.

**AC16** A post with a mention is held for review; the mentioner deletes their account; the post is approved\. The recipient gets nothing\.
**AC17** After the recipient got a mention, the mentioner's account is banned\. The row disappears and the unread count drops by one\. After the ban is lifted, the row is back\. The same row also disappears if the recipient blocks the mentioner\.
**AC18** After the post is deleted or taken down by ops, the row stays as it was\.
**AC19** An official account that is mentioned gets the row and the push, as today\. A virtual account gets the row only\.

### FR\-272: Old mention notifications

- Mentions sent before 1\.5\.4 have no record of the mentioner\. They keep the old generic copy \("Ada yang menyebutmu" / "Seseorang menyebutmu…", meaning "someone mentioned you"\)\. No backfill \(Albar, 2026\-11\-19\)\.

- Old rows keep opening as today: post, or comment section\.

**AC20** After the release, a mention row from before the release still shows the old copy and opens as before\.

### FR\-273: Tracking

- **No new events** \(Albar, 2026\-11\-19\)\. Other interaction pushes \(likes, comments, follows\) only track opens, and mentions follow the same rule\.

- **Existing events that cover mentions:**

    - `push_opened` with `push_type = CONTENT_MENTIONED` \(push tapped\);

    - `app_notification_item_tapped` with `notif_type = CONTENT_MENTIONED` \(row tapped\); `actor_count` is now filled for mention rows\.

- Everything goes to our own server \(V1\.5\.0 self\-built pipeline\)\. Nothing depends on PostHog\.

**AC21** Tapping a mention push records `push_opened` with `push_type = CONTENT_MENTIONED`\.
**AC22** Tapping a mention row records `app_notification_item_tapped` with `notif_type = CONTENT_MENTIONED` and `actor_count = 1`\.

## 5\. Non\-goals

- Who can be mentioned, the 5\-mention limit, and the @ picker are all unchanged\.

- No merging of mentions \("Budi dan 2 lainnya…", meaning "Budi and 2 others…"\)\.

- No backfill of old rows\.

- No push "sent" counting, for mentions or any other interaction push\. If wanted, that would be its own ticket covering all interaction pushes\.

- No change to the "Sebutan \(@\)" setting copy\.

- No avatar on the row and no tap\-the\-name\-to\-open\-profile\.

## 6\. Success

Shipped in 1\.5\.4 and AC1 to AC22 verified by QA on stag and production\. No metric target\.

## 7\. Open questions

|\#|Question|Owner|Needed by|
|---|---|---|---|
|OQ\-1|FR numbers re\-checked 2026\-11\-20: V1\.5\.2 uses FR\-225 to FR\-259; KTP share link FR\-260 to FR\-267; this PRD FR\-268 to FR\-273 \(was FR\-226 to FR\-231\); browsing history FR\-274 to FR\-281\. Next free number: FR\-282\. Re\-check before merging to `PetGo`|Albar|Before merging to `PetGo`|

## Appendix A\. Copy

All copy below is approved \(Albar, 2026\-11\-19\)\.

|Place|Bahasa Indonesia|English|
|---|---|---|
|Push title|\{nickname\} menyebutmu 📣|\{nickname\} mentioned you 📣|
|Push body, post|Di sebuah postingan\. Ketuk untuk lihat\!|In a post\. Tap to view\!|
|Push body, comment|Di komentar\. Ketuk untuk lihat\!|In a comment\. Tap to view\!|
|Row title, post|**\{nickname\}** menyebutmu di sebuah postingan|**\{nickname\}** mentioned you in a post|
|Row title, comment|**\{nickname\}** menyebutmu di komentar|**\{nickname\}** mentioned you in a comment|
|Row, old fallback \(unchanged\)|Ada yang menyebutmu / Seseorang menyebutmu di sebuah postingan / komentar|Someone mentioned you / Someone mentioned you in a post / comment|

## Appendix B\. Notes for developers

Paths are at `origin/main` `ca55416d9` \(checked 2026\-11\-20\)\. 1\.5\.2 will change the routing files listed under "Deep link"; re\-check those against `dev_1.5.2`\.

- **Push today:**

    - `notify/service/MentionNotifyListener.java:128-129` calls `sendWithCopy(..., args = null, ...)`;

    - `sendWithCopy` skips virtual accounts but not official accounts, and doesn't store the actor or the comment ID;

    - `ContentMentionedEvent` already carries `commentId` \(null = post mention\);

    - copy keys `notify.CONTENT_MENTIONED.{POST,COMMENT}.{title,body}` are in `i18n/messages_id.properties:3542-3545`, `messages_en.properties:3619-3622`, `messages.properties:3613-3616` and `messages_zh_CN.properties:3631-3634`\.

- **Pattern to reuse:** `NotificationService`:

    - `INTERACTION_TYPES` \(:55\-58\);

    - `sendInteraction` \(:242\-280\) stores the actor \(`aggregates.addActor`\) and the comment ID;

    - `pushInteraction` \(:592\-620\) pushes after commit and skips official and virtual accounts\. ⚠️ For mentions, **don't copy the official\-account skip**: keep today's rule \(skip virtual only, FR\-271\)\.

- Suggested: a dedicated `sendMention(...)` along these lines, with `aggregateKey = null` \(never merged\)\. Keep the `pushToUser` / `pushAllowed` pair \(`PushExitStructureTest`\)\.

- **Copy rendering:**

    - `InteractionCopyRenderer.title` \(:132\-173\) needs a `CONTENT_MENTIONED` case \(today `default` throws\);

    - `fallbackTitle` needs one too;

    - add templates `notify.tpl.mentioned.post` / `.comment` \(row\) and the new push title/body keys in all four message files\.

- **Mentioner gone:** `InteractionCopyRenderer.resolve` / `AccountQueryService.findActorViews` return no `ActorView` for deleted or banned accounts, so use that to skip\. The list already hides rows whose actor is filtered and recomputes unread the same way \(`NotificationCenterService`, T\-36\), which also covers unban and recipient blocks\.

- **List:**

    - `NotificationCenterService.render` \(:420\-445\) builds the title and actor once the type is an interaction type, but it only shows text for comment rows \(looked up live\)\. Mention rows show **no body text** \(FR\-269\): don't add `CONTENT_MENTIONED` to the comment\-text lookup;

    - old rows with no actor stay on the `plain` path \(FR\-272\)\.

- **App:**

    - add `'CONTENT_MENTIONED'` to `serverCopyTypes` \(`features/notify/domain/notification_item.dart:29-41`\);

    - fallback strings stay in `app_id.arb:2376-2378` / `app_en.arb:3656-3661`;

    - row page: `notification_center_page.dart` \(:1114, :1181\-1183, `_serverTitle` :1289\+\)\.

- **Deep link:** today `core/router/deep_link_routes.dart:215-221` \(`COMMENT:` → `?focus=comments`\); comment\-likes pass `commentId` at :230\-232 → `/content/{postId}?focus=comments&commentId={id}`\. 1\.5\.2 FR\-244 replaces `pushPayloadToLocation` and `_onTap` with one shared destination function; add the mention `commentId` case there\.

- **Tests to update:** `MentionNotifyTest.java` \(:112\-123, :143\-166\), `PushGateIntegrationTest.java:120`, `PushExitStructureTest`\.

## Change log

|Date|Who|Change|
|---|---|---|
|2026\-11\-19|Albar|First draft: FR\-226 to FR\-231, AC1 to AC22\. Decisions from the coaching session on 2026\-11\-19\.|
|2026\-11\-19|Albar|Review pass: text line hidden whenever the post/comment is no longer visible; old apps keep today's link format; push copy reaches old apps; text length and plain @/\#; FR\-119 override stated\. ACs renumbered AC1 to AC25\.|
|2026\-11\-19|Albar|Comment edits follow the same snapshot rule \(confirmed\)\. Dev questions wait for Hex's review\.|
|2026\-11\-20|Hex|Review: renumbered FR\-226–231 → **FR\-268–273** \(1\.5\.2 and KTP took the old numbers\); code baseline moved to `origin/main` `ca55416d9`; FR\-270 now builds on 1\.5\.2 FR\-244 \(OQ\-2 for the comment\-ID gap\); nickname = user nickname, no display\-name fallback, row shows the current nickname; stored text explained with an example, emoji\-safe cut, line breaks; "not visible" defined per recipient with a case table; official\-account push skip marked as a change; unban and recipient\-blocks\-mentioner added; row tap and icon stated; push language note corrected; frontmatter fixed\. ACs renumbered AC1 to AC28\.|
|2026\-11\-20|Hex|Decisions: comment ID stored and exact\-comment landing done in 1\.5\.4, 1\.5\.2 PRD unchanged \(OQ\-2 closed\); official accounts keep getting the mention push \(skip virtual only, AC25\); merge order with the other 1\.5\.4 PRDs added to §0\.|
|2026\-11\-20|Hex|Row has **no second line**: the mentioned text is not shown \(Hex\)\. Removed the stored text, its length / emoji / visibility rules and the related ACs; replies use the comment wording\. ACs renumbered AC1 to AC22\.|
|2026\-11\-23|Hex|Final check: tap behavior for under\-review / private / blocked\-post\-author cases stated \(FR\-271\); AC17 also covers recipient blocking the mentioner; AC9 allows a 1\.5\.2 app to land on the comment\. No rule changes\.|
|2026\-11\-23|Hex|Status set to **final**\.|
