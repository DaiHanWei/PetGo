# TailTopia Admin Console: Content Operations Guide

**How to use this guide**: After you log in to the admin console, the left sidebar is organized into groups (✍️ Content, 👥 Users, ⚙️ Settings & security, etc.). For each feature below you'll find **where it is (group → page)**, **what it does**, and **how to use it**. All times in the admin console are **Jakarta time (WIB)**.

---

## 1. Content exposure & highlighting

### 1. Pinned slots (✍️ Content → Pinned slots)
**What it does**: Gives you a fixed slot in the App's home feed and on topic pages. You can put an already-published post in the slot, or a promo card (an image with a title and a link). You can set a start and end time for each slot. The topic tab lets you schedule pins for each topic page separately.
**Ideas**:
- On weekends, pin a great community post to the top of the home feed so new users see quality content first
- During a sale, pin a promo card that takes users straight to the campaign products in Toko
- Pin an official explainer post on the #tipsmakanan topic page as a starting guide for that topic

> Only public posts can be pinned. Diaries that the author has set to private won't show up.

### 2. Content tags (✍️ Content → Content tags)
**What it does**: Puts an honor tag such as "Best of the Week" on a public post. The post shows a small badge, and users can tap it to read the tag's description. You can set an end date; leaving it empty keeps the tag forever.
**Ideas**:
- Run a weekly "Best of the Week": tag the winners for one week and let the tag expire automatically, so it becomes a recurring feature
- Tag contest winners as "Contest Winner" to encourage more people to join the next round

### 3. Topics (✍️ Content → Topics)
**What it does**: Lets you manage topics that users create with #, and create **official topics** (only official topics can have a description). The home topic row shows up to 5 topics: the ones you add here appear first, in your order, and the remaining spots are filled automatically by the most popular topics of the last 7 days. You can also hide or disable a topic.
**Ideas**:
- Before a campaign, create an official topic (e.g. #PawFriday), write the campaign description, and add it to the home topic row
- When a topic that users started is getting popular, move it into the home topic row to boost it
- If a topic starts collecting inappropriate content, hide it first

### 4. Content (✍️ Content → Content)
**What it does**: Shows every post. You can filter and sort by publish date or by when the likes happened, and see view and comment counts. You can export the list as a CSV. You can also **throttle** a single post or a whole account (this only reduces how often it's shown in the home feed recommendations), or take a post down yourself and restore it.
**Ideas**:
- Every Monday, sort by likes from the last 7 days to find candidates for "Best of the Week" and for pinning
- If an account is spamming but hasn't broken any rules, throttle it for 7 days instead of taking its posts down
- Export the CSV for your weekly content report

> Throttling is not a takedown. The post stays online: it's still visible on the author's profile, through a direct link and on topic pages, and its position in the category tabs doesn't change. Don't tell people who reported it that it was "removed".

---

## 2. Cold start & community atmosphere

### 5. Seed Content / Bulk content (✍️ Content)
**What it does**:
- **Seed Content**: Publish a single post as a virtual account or a real ops account, with up to 9 images and an optional related species. It appears in the feed mixed with regular users' posts, with no special label.
- **Bulk content**: Prepare a whole batch at once. Upload the images first, then paste captions or import them with the Excel template, preview, and publish. The second tab, "Scheduled posts", publishes posts automatically at the time you set.

**Ideas**:
- Before launching a new topic, schedule 10–20 seed posts so the topic page isn't empty
- Use the Excel template to schedule weekend or holiday content a week ahead; it goes live automatically
- The first image sets the post's height in the home feed, so crop it to the right ratio before uploading

> Scheduled posts still go through automatic moderation, with no exceptions.

### 6. Publishing Identities (👥 Users → Publishing Identities)
**What it does**: Create and manage virtual accounts and set their nickname and avatar. Virtual accounts can't log in; they exist only to publish seed content and warm comments.
**Ideas**: Create a set of personas for each species (a few cat owners, a few dog owners) so seed content feels like it comes from real users.

### 7. Comments (✍️ Content → Comments)
**What it does**: View and take down comments. You can also **comment on posts as a virtual identity (warm comments)**. The system lists identities that match the post's species first and shows how many comments each identity has posted today. Comments go through moderation and appear only once approved.
**Ideas**:
- Every day, find a batch of posts that have no comments yet and give new users a warm first comment on their first post, which helps keep them coming back
- Don't pile too many virtual comments on the same post. The system will warn you that it may look staged, but it won't stop you

### 8. Warm-reply follow-ups (📥 Inbox → Warm-reply follow-ups)
**What it does**: When a real user replies to one of our warm comments, the reply shows up here. You can reply again as the same virtual identity, or just mark it as read.
**Ideas**: Clear this list every day and keep the conversation going, so users feel they're really being heard.

---

## 3. Reaching users

### 9. Ops pop-ups (⚙️ Settings & security → Ops pop-ups)
**What it does**: Shows an image with a title, text and a button when a user opens the App and lands on the home screen. The button can link to a product, a product category, a page inside the App (home, create post, Toko, Know Your Pet, health, value bundles, etc.) or an external link. You can target all users, new users (registered within N days) or existing users, and add more filters. You can set priority, start and end times, and frequency (at most once a day).
**Ideas**:
- Show users registered within the last 3 days a "Create your first post" prompt that opens the create post page
- On a sale day, show all users the campaign poster with a button that goes to the campaign products
- Use a 4:5 image under 1MB, and leave space in the top-right corner for the close button

> System pop-ups (forced update, push permission, etc.) take priority, and only one ops pop-up is shown at a time. Check the results in PostHog.

### 10. System notifications (⚙️ Settings & security → System notifications)
**What it does**: Sends an in-app notification together with a push notification. You can target all users, specific user IDs (CSV upload supported), or users who match conditions: registration date, last active date, whether they've created a pet profile, pet species, whether they've ever placed a shop order, whether they've added a phone number, user level, and payment status. You can insert variables such as the user's nickname or pet's name, and schedule the send. Write one version in Indonesian and one in English; each user sees the version that matches their account language.
**Ideas**:
- Send a win-back message to cat owners who haven't been active for 30 days: "{pet name} misses you, come see today's top cat posts"
- Notify contest winners (upload their IDs), with a link that opens the contest post
- Send a new-user coupon to users who created a pet profile but have never ordered

> A scheduled notification can't be edited after you create it. To change it, cancel it before it's sent and create a new one. Banned users, deleted accounts and virtual accounts are excluded automatically.

### 11. User tags (👥 Users → User tags)
**What it does**: Puts an identity tag such as "Creator" or "Contest Winner" on a user. Other users can see it in the App and tap it to read the description. You can assign tags in bulk and set an end date.
**Ideas**: Tag active, high-quality creators as "TailTopia Creator" to give them recognition, and to make it easy to find potential community ambassadors later.

---

## 4. Campaign rewards

### 12. EXP System (⚙️ Settings & security → EXP System)
**What it does**: View and adjust the EXP rules and level table; add or remove EXP for a single user; **Bulk grant EXP** (paste a list of user IDs or upload a CSV, and enter a campaign name that users will see in their EXP history). You can also set the display level of virtual and official accounts (it only affects the avatar badge and frame).
**Ideas**:
- Give every campaign participant 50 EXP, with "Lomba Foto Kucing" as the campaign name
- Raise the display level of seed virtual accounts a little so they look like long-time users

### 13. Users (👥 Users → Users)
**What it does**: Look up users, **gift PawCoin**, and give back free uses (1–3 at a time).
**Ideas**: Give PawCoin to the first-place winner of a campaign. When a user reports that a bug used up their free uses, give some back to make up for it.

### 14. Share rewards in Platform Config (⚙️ Settings & security → Platform Config)
**What it does**: Turn share rewards on or off, and set the monthly limit and how much PawCoin each share earns.
**Ideas**: Raise the monthly limit for the duration of a referral campaign, then set it back afterwards.

---

## 5. Shop & gift tools for campaigns (usually managed by the e-commerce team; good to know they exist)

- **Top Banner** (🛍 Shop): The rotating banners at the top of Toko. A banner can carry a coupon that users claim with one tap.
- **Coupons** (🛍 Shop): Universal codes, one-time redeem codes, claimable coupons and new-user coupons
- **Pinned products** on the Products page: These products take turns appearing first each time users open Toko
- **Gift catalog** (⚙️ Settings & security): Gifts, categories and prices in the gift panel. You can add exclusive gifts for a specific species or level.

**Example campaign: "Cat Photo Week"**
1. In Topics, create the official topic #KucingCantik and add it to the home topic row
2. Use Bulk content to schedule 15 seed posts in advance
3. Use Ops pop-ups to show all users the campaign poster, with a button that opens the create post page
4. Leave warm comments on entries every day in Comments, and keep the conversations going in Warm-reply follow-ups
5. When the campaign ends, pick the winners by likes in Content, give them a Content tag, and pin them in Pinned slots
6. Use Bulk grant EXP in the EXP System to reward the winners, and System notifications (with their IDs) to tell them they won

---

## Can't see a page or button? Ask Hex

The sidebar shows only the pages you have access to. If you can view a page but not edit it, you'll be able to open it, but its buttons will be greyed out or missing. Most of the features above are **not given to any role by default**; access has to be turned on for each person.

**Why ask Hex**: The App and the admin console are updated constantly, and new pages or buttons can arrive with every release. Access has to be turned on by hand, so Hex may forget to give it to everyone when a new feature goes live. If a colleague can see something you can't, or there's a button you can't click, **just message Hex with the page name and what you need to do** (e.g. "I need to create official topics on the Topics page"), and Hex will turn it on for you.
