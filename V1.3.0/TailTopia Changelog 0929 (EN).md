# Auto-comments on community posts are live

**Status:** Live in production · Backend only, no app release needed
**Released:** 2026-09-29 19:33 WIB

If a post gets no comments within 2 hours, AI looks at its photo and writes a one-line comment. The comment is posted from one of our Ops-run persona accounts. The goal is to get new posts their first interaction and get the author to reply. **The first run is tonight at 20:30 WIB.**

## Schedule

Two runs a day, Indonesia time (WIB):

| Run | Time |
|---|---|
| Morning | 10:30 |
| Evening | 20:30 |

Posts only get checked at these two times, so a post waits roughly 2–15 hours for its auto-comment. For example, a post published at 08:00 is not yet 2 hours old at 10:30, so it gets picked up in the 20:30 run.

## Which posts get a comment

- Posted after Sept 29, at least 2 hours old, public and approved
- No comments yet (a comment still under review counts as one)
- Posted by a real user. Posts from persona accounts, admins or vets are skipped
- Has a photo. AI only looks at the first one; text-only posts are skipped
- At most one auto-comment per post

## What the comments look like

- Casual Bahasa Indonesia, usually one sentence, like a quick note from another user. It ends with a question so the author wants to reply
- Mentions the one most striking detail in the photo instead of a generic line like "so cute! how old?"
- Example: `senyumnya lebar bgt 😆 abis diajak jalan2 ya?` ("such a big smile 😆 just back from a walk?")
- Posted from one of 20 persona accounts picked at random, preferring an account with the same pet type as the post (cat / dog). An account the author has blocked is never used

## When it skips

- No recognizable pet in the photo (scenery, screenshots, selfies, etc.)
- Pets that are sick, injured, lost or have passed away, or posts asking for help. An upbeat tone would be inappropriate, so these are skipped
- Violent, gory or otherwise inappropriate images

Comments never include medical advice, ads, links or @mentions, and never mention TailTopia staff or AI.

## Same as normal comments

- They go through the usual sensitive-word filter and content moderation
- The author gets the usual "someone commented on your post" notification
- Every post's result is logged: what was posted, which account posted it, or why the post was skipped

## Tonight's first run

Estimated from data as of 19:30 today:

| Metric | Estimate |
|---|---|
| Eligible posts with zero comments | ~53 |
| Of those, posts with a photo | ~46 |
| Comments expected to go out | 30–45 |

Each run can handle up to 200 posts, so tonight's run won't hit that limit.

## What we need from you

- If a comment sounds off, lands on the wrong post, or a user complains about "being commented on by a bot", screenshot it and send it to the tech team so we can tune it
- If it needs to be stopped urgently, contact tech. Turning off the switch and restarting the service stops it

> **Not done yet:** there is no daily cap per user yet, so someone who posts several times a day may get several auto-comments. We also don't track the author reply rate yet. Both are being evaluated.

---

Backend build `ce0002ee` (main) · PR #40 · Production database backed up before release
