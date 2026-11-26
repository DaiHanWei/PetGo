---
title: "Post Comment Ranking: Score and Frozen-Time Paging"
status: final
created: 2026-11-25
updated: 2026-11-26
---

# PRD: TailTopia Pet App — Post Comment Ranking: Score and Frozen-Time Paging (V1.5.4)

## 0. About this document

- **What this is:** a new default order for top-level comments under a post. Today they are sorted by like count, which in practice means **oldest first**. After this change, comments are ranked by a score that rewards real engagement and gives new comments a short head start. Every comment is scored with the same rule. Paging uses the order as it was when the post was opened, so a comment is never skipped and almost never repeated.

- **Who it is for:** product (Albar, Hex), Dai's backend and app developers, QA.

- **Release:** V1.5.4. Roadmap item "评论热度排序快照 (1.3.0 FR-114 未做完；2026-10-30 落入本版本)", widened to include the new score (Albar, 2026-11-25).

- **Source spec:** V1.3.0 FR-114, item 2 (`TailTopia/V1.3.0/v1-3-0prd-A.md`, decided 2026-08-28, pagination stability 2026-08-31): "top-level comments default to hot sort: likes desc, ties by time asc; snapshot the order when entering the detail page". This PRD **replaces** that sort rule. Where they differ, this PRD wins.

- **Research:** `comment-hot-sort-snapshot-learning-report.md` in this folder (Albar, 2026-11-25): parameter inventory, formula, paging options, how X / Instagram / TikTok rank comments, and the comment data for 6,920 posts. Numbers in §1 come from it. Where this PRD differs from the research, this PRD wins.

- **Code baseline:** checked against `petgo-platform` `dev_1.5.2` (last commit 2026-11-24). The code facts in §2 and Appendix B are confirmed there.

- **Numbering:** **FR-335 to FR-338**, **AB-60**, **AC1 to AC30**. FR-260 to FR-334 are taken (1.5.4 PRDs incl. search FR-282 to FR-291, Tailsonality FR-292 to FR-297, notifications FR-321 to FR-334; website and web shop FR-298 to FR-319), so this PRD starts at FR-335. AB-60 is the next free admin number. Next free after this PRD: FR-339 / AB-61. Numbering is maintained by Hex's side (re-checked 2026-11-26: no clash).

- **Decisions:** rules decided by Albar on 2026-11-25 and by Hex on 2026-11-25 and 11-26 (same rule for every comment, no report demotion, frozen-time paging for all app versions, and the follow-ups below). Log: `V1.5.4/.decision-log.md`. No `[ASSUMPTION]` left.

- **UI design:** no mockup. **App:** only the order changes (FR-336); no screen, label or control is added (Albar, 2026-11-25). **Admin:** one new section on the existing 「算法参数」 (Algorithm parameters) page, built like the existing feed ranking section (FR-338; Hex, 2026-11-26).

## 1. Why

Hex asked for two things:

1. **Keep the comment order fixed while someone pages through a post**, so no comment is shown twice or skipped.
2. **Give new comments exposure**, balancing engagement, newness and who wrote the comment.

What the data says (posts by real users, 2026-10-19 to 11-17, comments counted to 11-25):

- A post has a median of **1** top-level comment. Only **4 of 6,920 posts (0.06%)** have more than 10, which is the only case where a second page exists.
- The whole app gets about **59 comment likes a day**. Most comments have 0 likes, so today's "hot" sort is effectively **oldest first**: a new comment always starts at the bottom.

So the order matters more than paging today. But once newness is part of the score, the order changes every second (a comment's age keeps growing), and then paging must use a fixed point in time. Both ship together.

**Goal:** the first comments a viewer sees are comments with real engagement and fresh comments, not whatever came first. Paging through a long comment list never skips a comment.

**Success = shipped and the ACs verified by QA** (AC1 to AC30). No metric target (Albar, 2026-11-25; §5).

## 2. What is wrong today

| Area | V1.3.0 spec | What the code does (`dev_1.5.2`) |
|---|---|---|
| Sort | Most likes first; ties: oldest first | Same: `(likeCount DESC, createdAt ASC, id ASC)`, page size 10 |
| Paging stability | Snapshot on entering the detail page | **No snapshot.** Each page counts likes live. Decision A-6 accepted "one comment more or less" |
| New comments | Not addressed | Start with 0 likes, and ties go oldest first, so they always land at the bottom |

How a comment gets skipped today (page size 3 for the example): A 9 likes, B 7, C 5 ← last shown, D 4, E 2. While the user reads page 1, D gets 2 likes (now 6). Page 2 asks for "comments ranked below C (5 likes)", so D (6) is never shown. If A loses likes and drops below C, A is shown again on page 2.

## 3. Glossary

- **Top-level comment:** a comment on the post itself (一级评论). Replies and replies-to-replies are **second-level**; their order doesn't change (§5).

- **Thread:** a top-level comment's replies and replies-to-replies.

- **Automated account:** an account with account type `VIRTUAL` (seed accounts), and nothing else (Hex, 2026-11-25). Auto-comment and warm-reply comments are written by these accounts. **Real account:** every other account, **including official/admin accounts, the ops account (id 81) and internal staff accounts (ids 23 and 1175)**. No account is excluded by ID.

- **Visible:** a comment the viewer can see under today's rules (not deleted, not taken down, not shadow-hidden, not from a user the viewer or the post author hid, and so on). It depends on the viewer. This PRD doesn't change visibility.

- **Counted reply:** a reply that counts toward a score (FR-335). Unlike "visible", it **doesn't depend on the viewer**, so every viewer gets the same scores: a reply counts if it isn't deleted, its moderation status is visible (not taken down, not under review), and its writer isn't hidden by the post author. The viewer's own blocks and hides change which comments they see, never any score (Hex, 2026-11-26).

- **Score:** a number the server computes per top-level comment to rank it (FR-335). Users never see it.

- **Visit time (T):** the time of the viewer's first page request when they open the post or pull to refresh. All later pages of that visit are ranked as of T (FR-337).

## 4. Features

### FR-335: Comment score

Every visible top-level comment gets a score. The rule is the same for every comment, whoever wrote it, including comments by automated accounts (Hex, 2026-11-25):

```
engagement    = 1 × likes + 2 × distinct_repliers
author_bonus  = +3 if the post author liked this comment OR wrote a counted reply anywhere in its thread
                (once, not per action; see exclusions below)
fresh_bonus   = 3 × 0.5 ^ (age_hours / 4)        (+3 when posted, halves every 4 h;
                                                  age is measured at the visit time T, FR-337)
score         = engagement + author_bonus + fresh_bonus
```

The numbers above are starting values. Ops can recalibrate them after launch (FR-338). Scores are compared exactly, with no rounding (Albar, 2026-11-25).

**What counts:**

- **Likes:** likes on this comment from real accounts.

- **Distinct repliers:** the number of different real accounts that wrote a counted reply anywhere in this comment's thread: direct replies and replies-to-replies both count (Albar, 2026-11-25). Replying costs more effort than liking, so it weighs double. One person replying 10 times counts once (Albar, 2026-11-25).

- **Post author:** the post author can add to a comment's score in two ways: as a replier (+2) and through the author bonus (+3).

**What never counts:**

- likes and replies from automated accounts (see Glossary). An automated account's reply never raises the comment it sits under;

- replies that are not counted replies (deleted, taken down, under review, or by a user the post author hid; see Glossary). The V1.1.4 rule "hidden comments don't count as interaction" applies;

- the commenter's own replies in their own thread (a commenter can't raise their comment by replying to it);

- the commenter's like on their own comment (Albar, 2026-11-25);

- the author bonus on a comment **written by the post author**. Their own top-level comments keep the "Penulis" (author) tag. Apart from the author bonus, they are scored like any other comment (Albar, 2026-11-25; AC8);

- the author bonus when the **post author is an automated account** (a post by a seed account). Posts by official accounts get the author bonus like any other post.

**Fresh bonus over time:**

| Age | 0 h | 2 h | 4 h | 8 h | 12 h | 24 h |
|---|---|---|---|---|---|---|
| Bonus | 3.0 | 2.1 | 1.5 | 0.75 | 0.38 | 0.05 |

With the default numbers, a brand-new comment with no likes ranks above an old comment with 2 likes for about the first 2 hours. A comment with 3 or more engagement points is never pushed below a fresh comment with no engagement. The bonus is added to the score; the score is not divided by age. So an old popular comment keeps its place days later. Ops can explain the rule as "new comments get +3 points, halving every 4 hours".

See Appendix A for a full worked example.

**AC1** Comment X is 24 h old with 2 real likes (score ≈ 2.05). Comment Y is 1 h old with no likes (score ≈ 2.52). Y is shown above X. When the post is opened again 3 h after Y was posted (Y ≈ 1.78), X is above Y.
**AC2** One real user replies 5 times under comment Z. Z's engagement goes up by 2, not 10.
**AC3** The commenter replies under their own comment. Its score doesn't change.
**AC4** A comment gets one reply from the post author. Its score is 5 plus its fresh bonus (2 for the distinct replier + 3 author bonus).
**AC5** The post author likes and also replies to the same comment. The author bonus is still +3 (once).
**AC6** Two seed accounts each like a comment, and a seed account replies to it. Its score doesn't change. When the ops account (id 81) then likes it, its score goes up by 1.
**AC7** A reply is shadow-hidden. The replier no longer counts toward the comment's score from the next visit.
**AC8** The post author writes a top-level comment on their own post, then likes it and replies in its thread after another user replied. It has the "Penulis" (author) tag, and its score has no +3 author bonus (only the other user counts as a replier).
**AC9** A seed account publishes a post, and a real user comments on it. The seed account replies to that comment. The comment's score doesn't change (no +2, no +3). On a post by an official account, the official account's reply gives +2 and +3, like any post author.
**AC10** An auto-comment (written by a seed account) is 1 h old with no interaction (score ≈ 2.52). A real user's comment on the same post is 3 h old with no interaction (≈ 1.78). The auto-comment is shown first. After the post author replies to the auto-comment, its score on the next visit is 5 plus its fresh bonus, the same as AC4.

### FR-336: Final order

Top-level comments are shown in this order, the same for every viewer:

1. score, highest first;
2. then the commenter's user level, highest first: the level shown on the commenter's profile; an account with no level counts as level 0 (Hex, 2026-11-26). Level only breaks ties; it never changes the score (Albar, 2026-11-25);
3. then newest first. **This changes today's rule** (oldest first), so new comments aren't buried by ties;
4. then comment ID, highest first.

- **Ties in practice:** every comment carries a fresh bonus that never reaches exactly 0, so two comments of different ages almost never tie. The level tie-break will rarely decide anything. Accepted (Albar, 2026-11-25).

- **What each viewer sees** is this order with today's visibility rules applied for that viewer (blocked or hidden users, the viewer's own comment under review, and so on). Removing a comment from one viewer's view doesn't change anyone else's order.

- **The viewer's own new comment:** the app shows it at the top of the list on the commenter's device right away (as today). Everyone else sees it in its scored position the next time they open the post (FR-337).

See Appendix A for a full worked example.

**AC11** Two comments have exactly the same score. The one whose commenter has the higher user level is shown first; at equal level, the newer one is shown first.
**AC12** Viewer A has blocked user B. A doesn't see B's comment; the order of the other comments is the same as what viewer C sees.
**AC13** The viewer posts a top-level comment. It appears at the top of the list on their device right away, with no reload.

### FR-337: Paging uses the visit time (all app versions)

- **When:** on the viewer's first page request (opening the post's comment list, or pull-to-refresh), the server takes the current time as the visit time **T** and ranks the comments as of T (FR-335, FR-336). If the post has **10 or fewer** top-level comments visible to this viewer (including the viewer's own comments that only they can see), the server returns them all at once and tells the app there are no more pages. If it has **more than 10**, it returns the first 10, and the paging cursor carries T and the position of the last comment returned (Hex, 2026-11-25).

- **Ranked as of T:** every later page of the visit is ranked again as of T:
    - only comments posted at or before T are included;
    - only likes and replies made at or before T count;
    - ages are measured at T.

  So likes, replies and age changes during the visit don't change the order. They count the next time the post is opened. Nothing is stored on the server, and the visit doesn't expire: T stays in the cursor however long the viewer stays on the post.

- **A new T** is taken when the viewer opens the post again, or pulls to refresh.

- **Every app version** gets this behavior. Apps already pass the cursor back unchanged (they treat it as an opaque string), so paging needs no app change. The 1.5.4 app adds one safety step: when it adds a page, it drops any comment already in the list (Appendix B).

- **During the visit:**

    | Situation | Behavior |
    |---|---|
    | A comment is deleted, taken down or hidden before its page loads | Skipped. That page may return fewer than 10. No error |
    | Someone else posts a new top-level comment | Not shown until the next visit (it was posted after T) |
    | The viewer posts a top-level comment | Shown at the top on their device (FR-336). It was posted after T, so it never comes back on a later page. After a refresh it moves to its scored position; with the +3 fresh bonus, a new comment usually ranks near the top |
    | The viewer blocks or hides a commenter | Today's behavior: that user's comments disappear from what's already shown. Later pages skip them |
    | A like on an already-shown comment is removed, or a reply under it is deleted or hidden | Its score as of T goes down, so it can come back on a later page. The 1.5.4 app drops it (already in the list). Apps older than 1.5.4 may show it twice. Rare; accepted (Hex, 2026-11-25) |
    | A reply that was hidden at T is restored during the visit | The comment's score as of T goes up and it may move above the pages already loaded, so it isn't shown in this visit. Very rare; accepted |
    | Ops change the ranking parameters (FR-338) during the visit | Later pages use the new values, so one comment may be skipped or shown twice (the 1.5.4 app drops the duplicate). Very rare; accepted (Hex, 2026-11-26) |

- **A visit never skips a comment that was visible at T**, except in the "restored reply" and "ops change the parameters" rows above. On the 1.5.4 app it never shows the same top-level comment twice.

- **Landing on a comment from a notification** (e.g. a comment-like notification, or a comment mention in 1.5.4 FR-270): unchanged. The app already shows the target comment's thread at the top, highlighted, and drops it from the list below (since V1.4.2). When the notification points to a reply, its top-level comment is the one shown at the top.

**AC14** A post has 25 visible top-level comments. The viewer opens it and loads all three pages. Meanwhile, 5 different users like the 15th comment. All 25 comments are shown exactly once, in the order from when the post was opened.
**AC15** A post has 10 visible top-level comments. All 10 are returned in the first response, ranked by score, and the app doesn't try to load another page.
**AC16** A comment on page 2 is deleted before page 2 loads. Page 2 shows the other comments; no error, no duplicate.
**AC17** While the viewer is on page 1, someone else posts a top-level comment. It doesn't appear on page 2 or 3. After pull-to-refresh, it appears in its scored position.
**AC18** The viewer posts a top-level comment while on page 1, then scrolls to the end. Their comment is at the top and appears only once.
**AC19** The viewer opens the post, likes the 3rd comment, and scrolls to the end. The 3rd comment keeps its place. When the post is opened again, it is ranked with the new like.
**AC20** The viewer opens a post with 25 comments, loads page 1, leaves the app open for 3 hours, then scrolls to the end. All 25 comments are shown exactly once, in the order from when the post was opened.
**AC21** On the 1.5.4 app, the viewer loads page 1 of a 25-comment post. A like on the 10th comment is removed, so it now ranks lower as of T. The viewer scrolls to the end. The 10th comment appears only once.
**AC22** The viewer taps a comment-like notification for a comment on page 2. The app opens the post, shows and highlights that comment, and the comment appears only once when the viewer scrolls through the list.
**AC23** On an app older than 1.5.4, a post with 25 comments shows the new order on page 1 and loads all pages without errors.
**AC24** On an app older than 1.5.4, while the viewer reads page 1 of a 25-comment post, 5 different users like a comment that was on page 3. All 25 comments are shown, none twice.
**AC25** On an app older than 1.5.4, a post with 5 comments shows them in the new order (e.g. a 1-hour-old comment with no likes above a 3-day-old comment with no likes).

### FR-338: Tuning parameters in admin (AB-60)

- **Same as feed ranking** (Albar, 2026-11-25): the starting numbers in FR-335 can be changed in ops admin in 1.5.4, the way ops already tune home/Discover feed ranking, so they can be recalibrated after launch without an app release. They sit on the ops admin **「算法参数」 (Algorithm parameters)** page as a new "Comment ranking" section, next to the existing home/Discover feed ranking parameters (Albar, 2026-11-25). Allowed ranges confirmed by Albar, 2026-11-25.

    | Parameter | Default | Allowed range |
    |---|---|---|
    | Like weight | 1 | 0 to 10 |
    | Distinct replier weight | 2 | 0 to 10 |
    | Post author bonus | 3 | 0 to 10 |
    | Fresh bonus at posting time | 3 | 0 to 10 |
    | Fresh bonus half-life (hours) | 4 | 1 to 72 |

- **Admin page:** same layout, save flow and permissions as the existing feed ranking section (view `CONFIG_ALGO_PARAM_VIEW` and the matching edit permission); only the parameter list differs. No mockup (Hex, 2026-11-26).

- A change applies from the next visit (new T). A visit that is already open uses the new values from its next page (FR-337, "ops change the parameters").

- Each change is recorded like the feed parameters are today: in `config_change_logs`, with its own config type (e.g. `COMMENT_RANK`, next to `FEED_RANK`).

**AC26** Ops change the half-life from 4 to 8 hours. A post opened after the change is ranked with 8 hours.
**AC27** Ops enter a value outside the allowed range. Admin rejects it and keeps the old value.
**AC28** The change is recorded in `config_change_logs` with who changed it, when, and the old and new values.

### Cross-cutting checks

These two ACs test rules from more than one FR.

**AC29** (FR-335, FR-336) A post written by a seed account has two real users' comments and one auto-comment. All three are ranked by the same score, with no author bonus on any of them.
**AC30** (FR-336, FR-337) The same post, opened at the same moment by two different viewers who haven't blocked or hidden anyone, shows the same order.

## 5. Non-goals

- **Second-level replies:** order unchanged (time ascending).

- **No special rule for automated comments** (Hex, 2026-11-25): auto-comment and warm-reply comments are scored and ordered like every other comment. Only the likes and replies of automated accounts don't count (FR-335).

- **No report-based demotion** (Hex, 2026-11-25). PetGo has no comment-level report today: the report action under a comment reports the commenter's account, not the comment.

- **No UI change:** no sort toggle (e.g. "Terbaru", newest), no "Disukai penulis" (liked by author) label, no visible score (Albar, 2026-11-25).

- **No personalisation:** no ranking by who the viewer follows, and no per-viewer model. The order is the same for every viewer (Albar, 2026-11-25).

- **No cap** on how many fresh comments can be in the first 10 (Albar, 2026-11-25).

- **No comment pinning.** PetGo has no comment pin; the only pin is the feed slot.

- **No comment views or impressions:** not tracked today, and not added.

- **No new tracking events** (Albar, 2026-11-25). Score inputs are all in the database.

- **No post-launch metric check** in this PRD. The research report (B6, B8) lists checks that can be run with AI 查数 if wanted.

- **No change** to comment visibility, moderation, reporting, the "Penulis" (author) tag, the 200-character limit, the "KOMENTAR (n)" (comments (n)) count, the page size (10 top-level comments per page), how the next page is triggered, the comment layout, or how auto-comment and warm-reply comments are created.

## 6. Non-functional requirements

- **Speed:** opening the comment list and loading more must not feel slower than today, even though every page now scores all top-level comments of the post as of T. QA checks this against today's comment list (Hex, 2026-11-26).

- **No stored state:** paging stores nothing on the server; T and the position travel in the cursor.

- **Consistency:** the same inputs always give the same order (no random tie-breaks). Later pages always use T from the cursor, never the server's current time.

## 7. Open questions

None. (The per-page server time question was closed on 2026-11-26: the requirement is "not slower than today", §6.)

## Appendix A. Worked example

A post by a real user with 6 top-level comments, opened 10 hours after the post was published (T = publish time + 10 h). Every comment uses the same rule.

| Comment | Written by | Age at T | Real likes | Distinct real repliers | Post author engaged | Score | Place |
|---|---|---|---|---|---|---|---|
| P | Real user | 9 h | 1 | 1 (the post author) | Yes (replied) | 1 + 2 + 3 + 0.63 = **6.63** | 1 |
| R | Seed account (auto-comment) | 10 h | 0 | 1 (the post author) | Yes (replied) | 2 + 3 + 0.53 = **5.53** | 2 |
| S | Real user | 8 h | 2 | 0 | No | 2 + 0.75 = **2.75** | 3 |
| Q | Real user | 1 h | 0 | 0 | No | 0 + 2.52 = **2.52** | 4 |
| U | Seed account (auto-comment) | 5 h | 0 | 0 | No | 0 + 1.26 = **1.26** | 5 |
| V | Seed account (auto-comment) | 10 h | 0 | 0 (only a seed account replied) | No | 0 + 0.53 = **0.53** | 6 |

## Appendix B. Notes for developers

Code references are from `petgo-platform` `dev_1.5.2` (2026-11-24).

- **Today's query:**

    - `content/service/CommentQueryService.java` `topLevel(...)`: sort `(likeCount DESC, createdAt ASC, id ASC)`, page size 10. Javadoc: "不做服务端排序快照（AD-A8.3，决策 A-6 已接受代价）… 「已渲染的列表不重排」由客户端承担";

    - `content/service/CommentHotCursor.java`: three-part cursor `h1:likes:micros:id`, separate from `FeedCursor`;

    - `content/repository/CommentRepository.java` `findTopLevelByHot`: like count from `COUNT(comment_likes)` live on every page; nothing stored on the comment row. Visibility in the same query: moderation status, the viewer's hide relations (R1) and the post author's hide relations (R2).

- **Suggested implementation:** a new cursor version (e.g. `h2`) carrying T plus the last returned comment's score, created time and ID. On each page, compute the score as of T for every visible top-level comment of the post (posts are small: max 34 seen in the research data), sort by FR-336, and return the 10 that come after the cursor position. As of T means `comments.created_at ≤ T`, `comment_likes.created_at ≤ T` and reply `created_at ≤ T`.

- **Release switch-over:** an `h1` cursor sent by an app that loaded page 1 just before the release must not cause an error. A one-off duplicate in that moment is acceptable.

- **Automated account check:** `account_type = VIRTUAL` only. **Don't use `User.isSyntheticAccount()`**: it also counts role `ADMIN` (official accounts) as synthetic, which this PRD counts as real (Hex, 2026-11-25). Use the same check for likes, repliers and the post author.

- **Reply storage:** comments have two levels only (`Comment.java`: "no third level"). A reply to a reply is stored as a second-level comment whose `parent_id` is the top-level comment (`CommentService.createReply`); since V1.4.2 it also records the reply it answered in `reply_to_comment_id`. So "distinct repliers in the thread" = distinct authors of rows with `parent_id = <top-level comment id>`. `reply_to_comment_id` isn't needed for ranking.

- **Inputs per comment (all as of T):** real likes on the comment (excluding the commenter), distinct real repliers in the thread (counted replies only, excluding the commenter; no viewer-specific filters), whether a real post author liked it or replied in its thread, created time, commenter level. `GrowthAccount` has both `level` and `display_level`: use whichever is shown on the profile (FR-336); no growth record = level 0.

- **App (1.5.4):** when appending a page, skip top-level IDs already in the list (today `comment_section.dart` `_loadMore` does `_topLevel.addAll(page.items)` without that check). The anchor thread and the viewer's own new comments are already de-duplicated (`comment_section.dart`, V1.4.2). Pull-to-refresh and re-entry already start without a cursor, which gives a new T.

## Change log

| Date | Who | Change |
|---|---|---|
| 2026-11-25 | Albar | First draft and review passes, decisions from the PM session on 2026-11-25, based on the comment hot-sort learning report. |
| 2026-11-25 | Hex | Renumbered to FR-335 onwards: the old range (FR-299 to FR-304) clashed with the website and web shop PRD. |
| 2026-11-25 | Hex | Rule changes: **one rule for every comment** (no bottom layer and no separate scoring for automated comments; automated accounts' likes and replies still don't count); **report factor removed** (no comment-level report exists); **frozen-time paging (visit time T in the cursor) for every app version**, replacing the stored snapshot. Code facts checked against `dev_1.5.2`; dev questions on code facts, old-app cursors and notification landing closed. Now FR-335 to FR-338, AC1 to AC30; next free FR-339 / AB-61. |
| 2026-11-25 | Hex | Automated account = `VIRTUAL` accounts only; official/admin accounts and the ops account (id 81) count as real. AC6, AC9, Appendix A row V and Appendix B updated; the ops-account question closed. |
| 2026-11-25 | Hex | Internal staff accounts (ids 23, 1175) also count as real; no account is excluded by ID. |
| 2026-11-26 | Hex | Review fixes: scores use a viewer-independent "counted reply" (the viewer's own blocks/hides never change scores); a parameter change during a visit added to the FR-337 exceptions; admin section has no mockup and reuses the feed ranking section's layout and permissions; user level = the level on the profile, none = 0; file paths fixed; the "Terbaru" fallback moved to the Roadmap backlog. |
| 2026-11-26 | Hex | Numbering owned by Hex's side; re-checked (FR-335 to FR-338 and AB-60 unused elsewhere). The numbering open question removed. |
| 2026-11-26 | Hex | **Final.** No app UI and no admin mockup; hand to dev.  |
| 2026-11-26 | Hex | OQ-1 closed: no separate time limit; §6 "not slower than today" is the check. No open questions left. |
