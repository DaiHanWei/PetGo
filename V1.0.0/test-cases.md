# TailTopia V1.0.0 — Manual Acceptance Test Cases

> Source of truth: `V1.0.0/V1-0-0PRD.md`. Each test case traces back to one FR and its stated "后果" (consequences). Written in Given/When/Then format for manual QA execution. All in-app copy quoted in test cases is written in Bahasa Indonesia (target market language); test case structure/prose remains in English. No automated test infrastructure exists yet (no architecture/stories/code) — this document is a PRD-derived acceptance checklist, not generated test code.

**Status:** Complete — all 13 applicable PRD §4 modules covered (§4.2 Gabung Gath excluded, moved to 1.5.0 per PRD).

---

## §4.0 User Auth & Onboarding

### FR-0A — Browsing the home feed while logged out

**TC-0A-01 — Guest can browse home feed without a login wall**
- Given the user has not logged in
- When they open the app
- Then the home feed content stream is visible and scrollable without any login prompt blocking it

**TC-0A-02 — Core entry points are visible but gated for guests**
- Given the user is browsing the home feed while logged out
- When they tap the consultation entry, growth archive entry, or the "+" publish button
- Then the login prompt defined in FR-0C is triggered instead of the target feature opening

**TC-0A-03 — Guests cannot submit data**
- Given the user is logged out
- When they attempt any data-submitting action (e.g., liking, commenting, posting)
- Then the action is blocked and the FR-0C login prompt appears; no data is persisted under an anonymous identity

---

### FR-0B — Soft login nudge triggered by scrolling

**TC-0B-01 — Overlay appears at page 3 while logged out**
- Given the user is logged out and scrolling the home feed
- When they reach the 3rd page of content
- Then a bottom half-screen overlay appears with a prominent "Masuk dengan Google" primary CTA and a small, low-contrast close button

**TC-0B-02 — Dismissing suppresses the overlay for the rest of the session**
- Given the overlay from TC-0B-01 is showing
- When the user taps the close button
- Then the overlay disappears and does not reappear again during the same app session, even if the user keeps scrolling past more "page 3" boundaries (e.g., navigating away and back)

**TC-0B-03 — Overlay triggers at most once per session**
- Given the user has already dismissed or ignored the overlay once this session
- When they scroll to page 3 again (e.g., after a pull-to-refresh resets the feed)
- Then the overlay does not trigger a second time in the same session

**TC-0B-04 — Logged-in users never see this overlay**
- Given the user is logged in
- When they scroll past page 3 of the home feed
- Then no soft login overlay appears

---

### FR-0C — Hard login gate on core actions

**TC-0C-01 — AI consultation entry triggers login modal for guests**
- Given the user is logged out
- When they tap the AI consultation entry
- Then a login modal appears with copy "Masuk untuk melanjutkan menggunakan fitur ini", a "Masuk dengan Google" button, and a close control; visual weight is higher than the FR-0B soft overlay

**TC-0C-02 — Vet consultation entry triggers login modal for guests**
- Given the user is logged out
- When they tap the vet consultation entry
- Then the same FR-0C login modal appears

**TC-0C-03 — Publish "+" entry triggers login modal for guests**
- Given the user is logged out
- When they tap the "+" publish button
- Then the FR-0C login modal appears

**TC-0C-04 — Create pet profile entry triggers login modal for guests**
- Given the user is logged out
- When they attempt to create a pet profile
- Then the FR-0C login modal appears

**TC-0C-05 — Successful login resumes the original action**
- Given the FR-0C modal was triggered by tapping a specific gated feature (e.g., AI consultation)
- When the user completes Google login successfully from the modal
- Then the app returns to the original trigger point and the user can continue the action they started, without needing to re-tap the entry point

---

### FR-0D — Google login (sole method in V1.0.0)

**TC-0D-01 — Tapping Google login launches the system account picker**
- Given the user is on any login prompt (FR-0B or FR-0C)
- When they tap the "Masuk dengan Google" button
- Then the system's native Google account selector launches

**TC-0D-02 — Existing user logs in directly**
- Given the user has an existing TailTopia account linked to the selected Google account
- When authorization succeeds
- Then the app logs them in directly and returns to the original trigger point, skipping nickname/pet-status steps

**TC-0D-03 — New user proceeds to nickname confirmation**
- Given the selected Google account has no existing TailTopia account
- When authorization succeeds
- Then the app creates a new account automatically (no separate register/login choice was ever shown) and routes to FR-0E nickname confirmation

**TC-0D-04 — User cancels the Google auth dialog**
- Given the system Google account picker is open
- When the user cancels/dismisses it
- Then the app shows "Login gagal, silakan coba lagi" with a "Coba lagi" button, returns to the pre-login page, and creates no account

**TC-0D-05 — Network timeout during authorization**
- Given the user has selected a Google account
- When the network times out before authorization completes
- Then the app shows "Login gagal, silakan coba lagi" with a "Coba lagi" button, returns to the pre-login page, and creates no account

**TC-0D-06 — Google service error during authorization**
- Given the user has selected a Google account
- When Google's auth service returns an error
- Then the app shows "Login gagal, silakan coba lagi" with a "Coba lagi" button, returns to the pre-login page, and creates no account

**TC-0D-07 — Terms and Privacy links are accessible without a checkbox**
- Given the user is on a login prompt
- When they view the area below the Google login button
- Then they see tappable text links for "Ketentuan Layanan" and "Kebijakan Privasi" that open the corresponding H5 pages, and no separate confirmation checkbox is required to proceed

---

### FR-0E — New user nickname confirmation

**TC-0E-01 — Nickname defaults to Google display name**
- Given a new user has just completed Google authorization
- When the nickname confirmation page loads
- Then the nickname field is pre-filled with the Google account's display name

**TC-0E-02 — Nickname is editable with a 20-character limit**
- Given the user is on the nickname confirmation page
- When they edit the nickname field
- Then they can change it freely up to 20 characters, and input beyond 20 characters is prevented or rejected

**TC-0E-03 — Confirming proceeds to pet status selection**
- Given the user has a valid nickname (default or edited)
- When they tap confirm
- Then the app routes to FR-0F pet status selection

**TC-0E-04 — Back button exits the registration flow without creating an account**
- Given the user is on the nickname confirmation page
- When they press the back button
- Then the app exits the registration flow, returns to the logged-out home feed, and no account is created; the next login attempt re-triggers Google authorization from scratch

---

### FR-0F — Pet status selection

**TC-0F-01 — Pet status selection is mandatory**
- Given the user is on the pet status selection screen (registration flow)
- When they attempt to proceed without selecting an option
- Then they cannot continue; no skip option is offered

**TC-0F-02 — Selecting "A — I have a pet" routes to profile creation onboarding**
- Given the user is selecting pet status
- When they select option A
- Then the app routes to FR-0G pet profile creation onboarding

**TC-0F-03 — Selecting "B — Planning to adopt" routes directly to home**
- Given the user is selecting pet status
- When they select option B
- Then the app routes directly to the home feed, content direction reflects pet-knowledge/selection-guide focus, and no profile reminder banner (FR-0H) is shown

**TC-0F-04 — Selecting "C — Pet enthusiast, no plans" routes directly to home**
- Given the user is selecting pet status
- When they select option C
- Then the app routes directly to the home feed, content direction reflects community/content focus, and no profile reminder banner (FR-0H) is shown

**TC-0F-05 — Changing status from B/C to A later reuses the same onboarding flow**
- Given an existing logged-in user currently has status B or C
- When they change their status to A from "Saya → Status Hewan Peliharaan" or the growth archive tab
- Then the app routes them into the same FR-0G profile creation onboarding used during registration (including the skip option)

**TC-0F-06 — Back button returns to nickname confirmation**
- Given the user is on the pet status selection screen during registration
- When they press the back button
- Then the app returns to FR-0E nickname confirmation with the previously entered nickname preserved

---

### FR-0G — Pet profile creation onboarding (status A only)

**TC-0G-01 — Skip option is available**
- Given a new status-A user is on the profile creation onboarding screen
- When they look at the bottom of the page
- Then a "Lewati, buat nanti" entry is visible and tappable

**TC-0G-02 — Completing creation shows the success celebration page**
- Given the user fills out and submits the pet profile creation form
- When the profile is created successfully
- Then a celebration page appears showing the pet's avatar, name, and the text "Profil eksklusif [Nama Hewan] telah dibuat!"

**TC-0G-03 — Secondary CTA shares the pet card**
- Given the user is on the success celebration page
- When they tap the secondary "Bagikan kartu hewan peliharaan" CTA
- Then the system share sheet opens pre-loaded with the FR-14 pet card link

**TC-0G-04 — Primary CTA proceeds through push permission to home**
- Given the user is on the success celebration page
- When they tap the primary "Mulai jelajahi" CTA
- Then the FR-22D push notification permission prompt is triggered, and afterward (regardless of permission grant/deny) the user lands on the home feed with no profile reminder banner shown

**TC-0G-05 — Skipping creation routes to home with banner logic engaged**
- Given the user taps "Lewati, buat nanti" on the profile onboarding screen
- When the skip is confirmed
- Then the app routes to the home feed and the FR-0H reminder banner logic begins (banner shown per FR-0H rules)

---

### FR-0H — Home pet-profile reminder banner

**TC-0H-01 — Banner shows for status-A users without a completed profile**
- Given the user selected status A but has not completed pet profile creation (skipped during onboarding)
- When they land on the home feed
- Then a reminder banner is shown at the top with a "Buat sekarang" CTA and a close (X) button

**TC-0H-02 — Banner content matches spec**
- Given the banner is showing
- When the user inspects it
- Then it contains a "Buat sekarang" CTA that routes to profile creation, and a close (X) button

**TC-0H-03 — Dismissing hides the banner only for the current session**
- Given the banner is showing
- When the user taps the close (X) button
- Then the banner disappears for the remainder of the current app session, but reappears on the next app restart (if dismissal count is still under the cap)

**TC-0H-04 — Banner stops permanently after the 3rd restart dismissal**
- Given the user has dismissed the banner on 3 separate app restarts without creating a profile
- When they restart the app a 4th time
- Then the banner no longer appears, even though no profile has been created

**TC-0H-05 — Banner stops permanently once a profile is created**
- Given the banner has been showing (within the first 3 restarts)
- When the user completes pet profile creation via the banner's CTA or any other entry point
- Then the banner stops appearing on all subsequent sessions

**TC-0H-06 — Status B/C users never see this banner**
- Given the user's pet status is B or C
- When they land on the home feed at any point
- Then the FR-0H reminder banner never appears, regardless of restart count

---

## §4.1 Professional Consultation (Konsultasi Kilat)

### FR-1 — AI photo/text triage

**TC-1-01 — Submit with photo and text returns a result within 15 seconds**
- Given the user is on the AI consultation submission screen
- When they attach 1–3 photos and a text description, then submit
- Then a triage result is returned within 15 seconds

**TC-1-02 — Photo is optional; text-only submission is accepted**
- Given the user is on the AI consultation submission screen
- When they submit a text description with no photos attached
- Then the submission is accepted and processed normally

**TC-1-03 — Cannot attach more than 3 photos**
- Given the user has already attached 3 photos
- When they attempt to attach a 4th
- Then the app prevents adding a 4th photo

**TC-1-04 — Oversized photo is rejected**
- Given the user attempts to attach a photo larger than 10MB
- When they select it
- Then the app rejects the file with an appropriate error, and the file is not attached

**TC-1-05 — Unsupported file format is rejected**
- Given the user attempts to attach a file that is not JPG, PNG, or HEIC
- When they select it
- Then the app rejects the file

**TC-1-06 — Video upload is unavailable in V1.0.0**
- Given the user is on the AI consultation submission screen
- When they look for a video upload option
- Then no video upload option is present (video upload is gated to the paid version, post-V1.0.0)

**TC-1-07 — Result screen shows all three required elements together**
- Given a triage result has been returned
- When the user views the result screen
- Then danger level (green/yellow/red), observation advice, and home medication reference are all shown on the same screen

**TC-1-08 — Disclaimer is visually de-emphasized but present**
- Given the user is viewing any triage result
- When they scroll to the bottom of the result
- Then a disclaimer is shown in small, secondary-colored text that does not visually compete with the main content

**TC-1-09 — Timeout shows retry prompt**
- Given the user has submitted a triage request
- When no result is returned after 15 seconds
- Then the app shows "Analisis membutuhkan waktu lebih lama, silakan coba lagi nanti" with a "Kirim ulang" button

**TC-1-10 — AI service error shows fallback with soft link to vet**
- Given the user has submitted a triage request
- When the AI service returns an error
- Then the app shows "Layanan AI sementara tidak tersedia, silakan coba lagi nanti" with a "Kirim ulang" button and a soft nudge "atau langsung hubungi dokter hewan" linking to FR-4B

**TC-1-11 — Retry reuses the original submission without re-upload**
- Given the user hit a timeout or service error and is shown the "Kirim ulang" button
- When they tap "Kirim ulang"
- Then the original photos and text are resubmitted automatically without requiring the user to re-attach files or retype the description

**TC-1-12 — Green tier result shows correct icon and headline**
- Given the AI triage returns a green rating
- When the user views the result
- Then a green icon and the text "Belum ada risiko darurat" are displayed

**TC-1-13 — Green tier shows home-care observation advice**
- Given a green-tier result
- When the user views the result
- Then concrete home-care guidance (e.g., diet, rest) is shown

**TC-1-14 — Green tier shows a non-mandatory nudge toward vet consultation**
- Given a green-tier result
- When the user views the result
- Then a soft prompt "Ingin lebih yakin? Konsultasikan dengan dokter hewan untuk memastikan" is shown, linking to FR-4B, and proceeding to it is optional

**TC-1-15 — Green/yellow tier results offer "save to archive"**
- Given a green or yellow tier result
- When the user views the bottom of the result page
- Then a "Simpan hasil ini ke profil" prompt is shown, which triggers the FR-16 save flow when tapped

---

### FR-2 — Yellow tier conditional countdown protocol

**TC-2-01 — Yellow result includes all three required protocol elements**
- Given the AI triage returns a yellow rating
- When the user views the result
- Then the observation advice includes a specific observation indicator, a defined time window, and a clear escalation trigger condition

**TC-2-02 — Yellow result never uses definitive reassurance language**
- Given a yellow-tier result
- When the user reads the full result text
- Then no phrasing equivalent to "tidak parah" or "tidak perlu khawatir" appears anywhere on the page

**TC-2-03 — Time window and escalation condition are visually distinguished**
- Given a yellow-tier result
- When the user views the result
- Then the time window and escalation trigger condition are rendered with distinct visual treatment (e.g., a separate card or bold text), not blended into plain paragraph text

---

### FR-3 — Red tier half-screen strong alert

**TC-3-01 — Red result triggers the half-screen alert overlay**
- Given the AI triage returns a red rating
- When the result is displayed
- Then a half-screen red overlay appears immediately over the result page

**TC-3-02 — Overlay cannot be dismissed within the first 5 seconds**
- Given the red overlay is showing
- When the user attempts to swipe away or tap to close it before 5 seconds have elapsed
- Then the overlay remains on screen; no dismiss control is available yet

**TC-3-03 — Overlay content matches the required copy**
- Given the red overlay is showing
- When the user reads it
- Then it displays a ⚠️ icon, the main copy "Segera bawa [Nama Hewan] ke klinik hewan", and the sub copy "AI mendeteksi kondisi darurat, segera bawa hewan peliharaan Anda ke dokter"

**TC-3-04 — "Saya mengerti" appears after 5 seconds and closes the overlay**
- Given the red overlay has been showing for 5 seconds
- When the "Saya mengerti" button appears and the user taps it
- Then the overlay closes and the user returns to the triage result page

**TC-3-05 — No map navigation or hospital recommendation is shown**
- Given a red-tier result (overlay or underlying result page)
- When the user looks for navigation or hospital suggestions
- Then none are present anywhere in the red-tier flow

**TC-3-06 — No vet consultation upgrade entry on red result page**
- Given a red-tier result page (after the overlay is dismissed)
- When the user looks for a way to escalate to a vet consultation
- Then no such entry point exists on this page

**TC-3-07 — "Save to archive" saves directly for status-A users with an existing profile**
- Given the user has status A and an existing pet profile, and is viewing a red-tier result
- When they tap "Simpan ke profil"
- Then the result is saved to the archive immediately with no confirmation modal

**TC-3-08 — "Save to archive" triggers FR-16 modal for users without a profile**
- Given the user is status A without a profile, or status B/C, and is viewing a red-tier result
- When they tap "Simpan ke profil"
- Then the FR-16 modal flow is triggered (guides them to create a profile before saving), identical to the FR-16 behavior used elsewhere

---

### FR-4A — AI consultation entry

**TC-4A-01 — AI and vet entries are shown at equal visual weight**
- Given the user opens the consultation module
- When they view the entry points
- Then the AI consultation entry and vet consultation entry are presented at the same hierarchical level

**TC-4A-02 — AI consultation has no payment step**
- Given the user taps the AI consultation entry
- When they proceed through submission
- Then no payment step appears anywhere in the flow

**TC-4A-03 — Vet entry remains independently reachable from the AI result page**
- Given the user is viewing an AI result page that shows a soft nudge toward vet consultation
- When they ignore the nudge and navigate back to the consultation module
- Then the vet consultation entry is still independently accessible, not hidden or altered by having viewed the AI result

---

### FR-4B — Vet consultation entry

**TC-4B-01 — Vet and AI entries shown at equal visual weight**
- Given the user opens the consultation module
- When they view the entry points
- Then the vet consultation entry and AI consultation entry are presented at the same hierarchical level

**TC-4B-02 — Vet consultation is free in V1.0.0**
- Given the user proceeds through a vet consultation request
- When they reach the point of submitting the request
- Then no payment step is required

**TC-4B-03 — Online availability is shown as a time-window estimate, not a live count**
- Given the user opens the vet consultation entry
- When they view the availability indicator
- Then it shows a general time-window statement (e.g., "Hari kerja 8:00–23:00 biasanya ada dokter hewan online") and does not show a real-time count of online vets

**TC-4B-04 — Active ongoing consultation replaces the new-request option**
- Given the user already has one consultation in progress
- When they open the vet consultation entry again
- Then it displays "Lihat konsultasi yang sedang berlangsung →" instead of an option to start a new request

**TC-4B-05 — Tapping the ongoing-consultation link jumps directly to that session**
- Given the user sees "Lihat konsultasi yang sedang berlangsung →"
- When they tap it
- Then the app navigates directly into the existing chat session

**TC-4B-06 — Cannot start a second concurrent vet consultation**
- Given the user has one consultation in progress
- When they attempt to initiate a new vet consultation through any entry point
- Then the app prevents it and routes them to the existing session instead

**TC-4B-07 — Submitting a request enters the matching/waiting screen**
- Given the user submits a vet consultation request
- When the request is sent
- Then a waiting screen appears showing "Sedang mencarikan dokter hewan untukmu…"

**TC-4B-08 — Timeout prompt appears after 1 minute with no acceptance**
- Given the user has been on the waiting screen for 1 minute with no vet accepting
- When the timeout threshold is reached
- Then a timeout prompt appears with two options: "Tetap menunggu" and "Gunakan triase AI dulu"

**TC-4B-09 — "Tetap menunggu" resets the timer and keeps matching**
- Given the timeout prompt is showing
- When the user taps "Tetap menunggu"
- Then the waiting timer resets and the app continues searching for an available vet

**TC-4B-10 — "Gunakan triase AI dulu" navigates away while keeping the vet request queued**
- Given the timeout prompt is showing
- When the user taps "Gunakan triase AI dulu"
- Then the app navigates to FR-4A AI consultation, and the original vet request remains active in the matching queue in the background

**TC-4B-11 — Push notification sent if vet accepts while user is off the chat screen**
- Given the user submitted a vet request and navigated away from the waiting/chat screen
- When a vet accepts the request
- Then a push notification "Dokter hewan telah menerima konsultasimu, ketuk untuk mulai mengobrol" is sent

**TC-4B-12 — No push sent if user is already on the waiting screen when vet accepts**
- Given the user is actively on the waiting screen
- When a vet accepts the request
- Then the app navigates directly into the chat session without sending a push notification

**TC-4B-13 — Force-quitting the app while waiting cancels the request**
- Given the user is on the waiting screen with a pending request
- When they force-quit the app (kill the process)
- Then the system automatically cancels the matching request and removes it from the pending queue; no vet is able to accept it afterward

**TC-4B-14 — Cancel button is available during waiting**
- Given the user is on the waiting screen
- When they look for a way to stop waiting
- Then a "Batal" button is visible

**TC-4B-15 — Tapping cancel shows a confirmation dialog**
- Given the user taps "Batal" on the waiting screen
- When the tap registers
- Then a confirmation dialog appears asking "Konfirmasi batalkan pencarian ini?"

**TC-4B-16 — Confirming cancellation removes the request and returns to module home**
- Given the cancellation confirmation dialog is showing
- When the user confirms
- Then the request is removed from the vet pending queue and the app returns to the consultation module home screen

**TC-4B-17 — Escalating from AI result passes full context to the vet**
- Given the user is viewing an AI triage result and taps "Konsultasi dokter hewan" to escalate
- When the escalation request is created
- Then the AI danger rating, the user's text description, and all uploaded photos/videos are attached to the request

**TC-4B-18 — Vet sees the AI context in the pending-request preview before accepting**
- Given an escalated request is in a vet's pending queue
- When the vet opens the request preview
- Then they can see the AI rating, description, and media before deciding to accept

**TC-4B-19 — Full AI context is shown at the top of the chat after acceptance**
- Given a vet accepts an escalated request
- When the chat session opens
- Then the full AI context (rating, description, media) is displayed at the top of the conversation

**TC-4B-20 — User does not need to redescribe symptoms after escalation**
- Given the user has escalated from an AI result to a vet chat
- When the chat session begins
- Then the user is not prompted or required to re-enter their symptom description or re-upload media

**TC-4B-21 — No vets online shows the offline state with expected resumption window**
- Given no vets are currently available to accept requests
- When the user opens the vet consultation entry
- Then the page shows "Saat ini belum ada dokter hewan yang online" along with an expected resumption time window

**TC-4B-22 — Offline state nudges toward AI triage**
- Given the offline state is showing
- When the user views the page
- Then a soft prompt "Coba triase AI dulu? AI bisa langsung memberikan penilaian awal, dan kamu bisa konsultasi dengan dokter hewan kapan saja setelah mereka online" is shown with a button routing to FR-4A

**TC-4B-23 — User can remain on the offline page instead of being redirected**
- Given the offline state is showing
- When the user ignores the AI nudge button
- Then they are able to stay on the vet consultation page without being forcibly redirected

---

### FR-5 — Vet acceptance assist tools

**TC-5-01 — AI reference reply shown when no historical match exists**
- Given a vet accepts a request and the symptom-keyword database has no matching historical case
- When the vet views the assist panel
- Then an AI-generated reference reply is shown

**TC-5-02 — Historical judgment summary shown when matching cases exist**
- Given a vet accepts a request and the database contains cases matching the symptom keywords
- When the vet views the assist panel
- Then a summary of historical judgments for similar symptoms is shown, without the vet needing to search manually

**TC-5-03 — Disclaimer auto-displays on the user side**
- Given a vet has accepted a request and the chat is active
- When the user views the chat
- Then the disclaimer "Saran ini hanya sebagai referensi, keputusan akhir ada di tangan Anda" is shown automatically, without any action required from the vet

**TC-5-04 — Cold start shows only the AI reference reply, no historical summary section**
- Given the platform's historical case database is empty (launch state)
- When a vet accepts any request
- Then only the AI reference reply is shown; no historical judgment summary section appears at all

---

## §4.3 Growth Archive (Paspor Tumbuh Kembang)

> Includes FR-37, FR-39, FR-21, and FR-42, which appear later in the PRD document body (nested under the §4.6 heading due to iterative drafting) but belong functionally to this module.

### FR-11 — Pet profile creation

**TC-11-01 — Pet type is mandatory and determines the milestone list**
- Given the user is creating a pet profile
- When they attempt to submit without selecting a pet type
- Then submission is blocked; selecting "Kucing" / "Anjing" / "Lainnya" determines which FR-42 milestone list will apply

**TC-11-02 — Name is mandatory with a 20-character limit**
- Given the user is creating a pet profile
- When they leave the name field empty and attempt to submit
- Then submission is blocked; entering more than 20 characters is prevented or rejected

**TC-11-03 — Birthday requires a complete date**
- Given the user is creating a pet profile
- When they attempt to enter only month/day without a year, or leave it empty
- Then submission is blocked until a complete year/month/day date is provided

**TC-11-04 — Avatar is optional with a default placeholder**
- Given the user is creating a pet profile
- When they submit without uploading an avatar
- Then the profile is created successfully showing a default placeholder image

**TC-11-05 — Breed is optional free text with no validation logic**
- Given the user is creating a pet profile
- When they enter any arbitrary text in the breed field (or leave it blank)
- Then it is accepted as-is, used for display only

**TC-11-06 — Bio is optional with a 30-character limit**
- Given the user is creating a pet profile
- When they leave bio empty, or enter up to 30 characters
- Then submission succeeds; entering more than 30 characters is prevented or rejected

**TC-11-07 — Pet type is locked after creation**
- Given a pet profile has been created
- When the user opens profile editing (FR-39)
- Then the pet type field is not editable

**TC-11-08 — Successful creation auto-generates the pet card link**
- Given the user completes profile creation
- When the profile is saved
- Then an FR-14 pet card share link is generated automatically without further action

---

### FR-12 — Unified publish entry

**TC-12-01 — Single "+" entry opens the publish editor with type tabs**
- Given the user is logged in
- When they tap the "+" entry
- Then the editor opens showing three content-type tabs: "Berbagi Harian" / "Edukasi Profesional" / "Kalender Tumbuh Kembang"

**TC-12-02 — "Kalender Tumbuh Kembang" requires a pet association**
- Given the user selects "Kalender Tumbuh Kembang" in the editor
- When they attempt to publish without selecting a pet
- Then publish is blocked until a pet is selected

**TC-12-03 — Other two types have optional pet association**
- Given the user selects "Berbagi Harian" or "Edukasi Profesional"
- When they leave the pet association field empty
- Then publish is still allowed

**TC-12-04 — Event date field only appears for "Kalender Tumbuh Kembang"**
- Given the user is in the editor
- When they switch between content types
- Then the "Tanggal Kejadian" field is visible only when "Kalender Tumbuh Kembang" is selected

**TC-12-05 — Default event date is today when entering via "+"**
- Given the user enters the editor via the global "+" button and selects "Kalender Tumbuh Kembang"
- When the event date field renders
- Then it defaults to today's date

**TC-12-06 — Default event date matches the tapped calendar cell**
- Given the user enters the editor by tapping a date cell in the FR-37 calendar view
- When the editor opens
- Then the event date defaults to that cell's date and the type is pre-selected to "Kalender Tumbuh Kembang"

**TC-12-07 — Future dates cannot be selected as event date**
- Given the user is editing the event date field
- When they attempt to pick a date after today
- Then the date picker disallows it

**TC-12-08 — Past event dates have no lower limit**
- Given the user is editing the event date field
- When they pick any date in the past, however distant
- Then it is accepted

**TC-12-09 — Event date and publish time are independent**
- Given the user sets an event date different from today
- When they publish the post
- Then the post's event date and its actual publish timestamp both persist independently and can differ

**TC-12-10 — Status B/C users see "Kalender Tumbuh Kembang" greyed out**
- Given a status B or C user opens the publish editor
- When they view the type tabs
- Then "Kalender Tumbuh Kembang" is shown greyed out/disabled with a tooltip "Perlu membuat profil hewan peliharaan terlebih dahulu"

**TC-12-11 — Tapping the greyed-out option routes into profile creation**
- Given a status B/C user taps the disabled "Kalender Tumbuh Kembang" tab
- When the tap registers
- Then the app switches their status to A and routes into FR-0G profile creation onboarding

**TC-12-12 — Completing profile creation from this path returns to the publish page pre-selected**
- Given the user completes profile creation via TC-12-11's flow
- When creation finishes
- Then the celebration page is skipped, the app returns directly to the publish editor with "Kalender Tumbuh Kembang" pre-selected, ready to continue publishing

**TC-12-13 — All content defaults to public; no private option exists**
- Given the user is publishing any content type
- When they look for a visibility setting
- Then no "only visible to me" option is present anywhere in the flow

**TC-12-14 — Confirmation screen discloses public visibility**
- Given the user reaches the publish confirmation step
- When they view it
- Then it displays "Setelah diterbitkan, konten akan ditampilkan secara publik untuk semua pengguna"

**TC-12-15 — Text content is capped at 1000 characters across all types**
- Given the user is entering text in any of the three content types
- When they type beyond 1000 characters
- Then further input is blocked or publish is prevented

**TC-12-16 — Remaining character count is shown live**
- Given the user is typing text content
- When they view the editor
- Then a live remaining-character indicator (e.g., "Sisa 800 karakter") updates as they type, and publish is disabled once the limit is exceeded

**TC-12-17 — Empty text and empty image together block publish**
- Given the user has entered no text and attached no image
- When they view the publish button
- Then it is disabled/greyed out

**TC-12-18 — Image upload is capped at 9 photos, ≤10MB each, allowed formats only**
- Given the user is attaching images to a post
- When they attempt to exceed 9 images, attach a file >10MB, or attach an unsupported format
- Then each respective action is blocked

**TC-12-19 — Video upload is unavailable in V1.0.0**
- Given the user is in the publish editor
- When they look for a video attachment option
- Then none is present

**TC-12-20 — Published content appears in Feed and "Postingan Saya"**
- Given the user successfully publishes any of the three content types
- When the post passes moderation
- Then it appears in the global Feed (FR-17) and in the user's "Postingan Saya" list

**TC-12-21 — "Kalender Tumbuh Kembang" content additionally appears in the pet's timeline**
- Given the user publishes a "Kalender Tumbuh Kembang" post
- When it passes moderation
- Then it also appears in the associated pet's growth-archive timeline as a "Momen Bahagia" entry

**TC-12-22 — Clean content passes moderation with no perceptible delay**
- Given the user submits text and/or images containing no flagged content
- When moderation completes
- Then the post appears in Feed and "Postingan Saya" immediately, with no visible delay

**TC-12-23 — Flagged text blocks publish with a specific error**
- Given the user submits text containing a filtered keyword
- When moderation runs
- Then publish fails, the user remains on the editor with content preserved, and sees "Konten mengandung kata-kata tidak pantas, silakan ubah dan coba lagi"; the post does not enter a manual review queue

**TC-12-24 — Flagged image blocks publish with a specific error**
- Given the user submits an image flagged by the image-recognition service
- When moderation runs
- Then publish fails, the user remains on the editor, and sees "Gambar mengandung konten yang melanggar, silakan ganti dan coba lagi"

**TC-12-25 — Both text and image must pass for the post to go live**
- Given a post contains both text and images
- When either the text or the image fails moderation
- Then the entire post is blocked from publishing, not just the failing part

---

### FR-14 — Pet card external share page

**TC-14-01 — Hero section shows avatar, name, and days-together**
- Given a visitor opens a pet's H5 share page
- When the hero section renders
- Then it shows a large avatar, the pet's name, and "Bersama [Nama Panggilan Pengguna] selama X hari"

**TC-14-02 — Milestone badge strip shows latest 3–5 completed, locked ones greyed**
- Given the pet has completed at least one milestone
- When the visitor views the badge strip
- Then the most recent 3–5 completed milestones show colored badge icons, and incomplete ones show grey locked outlines

**TC-14-03 — Story stats row shows the three counters**
- Given the visitor views the page
- When the stats row renders
- Then it shows "X momen bahagia · X konsultasi · X pencapaian selesai" in one row

**TC-14-04 — Recent milestone activity shows only the latest L/M tier item**
- Given the pet has multiple completed milestones across tiers
- When the page renders the "recent milestone" line
- Then only the single most recent L or M tier milestone is shown, not S-tier or older ones

**TC-14-05 — Photo stream shows the latest 5 happy moments, reverse chronological**
- Given the pet has more than 5 happy moments
- When the photo stream renders
- Then exactly the 5 most recent (by event date) are shown, newest first

**TC-14-06 — Two CTAs are shown with distinct targeting**
- Given any visitor views the page
- When they view the CTA area
- Then a primary CTA "Buat profil serupa untuk hewan peliharaanku" and a secondary CTA "Lihat kisah lengkap [Nama Hewan]" are both shown

**TC-14-07 — Page content excludes daily-share and educational posts**
- Given the pet's owner has also published "Berbagi Harian" and "Edukasi Profesional" content
- When the H5 page renders
- Then none of that content appears; only growth-calendar happy moments and milestone data are shown

**TC-14-08 — Days-together is calculated from profile creation date**
- Given the pet profile was created N days ago
- When the hero section renders
- Then it shows exactly N days (today minus creation date)

**TC-14-09 — Zero milestones hides the badge strip and the milestone stat**
- Given the pet has not completed any milestones
- When the page renders
- Then the badge strip is not shown, and the "pencapaian" item is omitted from the stats row

**TC-14-10 — Zero happy moments shows a download placeholder**
- Given the pet has no published happy moments
- When the photo stream area renders
- Then it shows a placeholder prompt "Unduh aplikasi untuk melihat lebih banyak konten" instead of an empty stream

**TC-14-11 — Page loads within 3 seconds**
- Given a visitor opens the share link under normal network conditions
- When the page loads
- Then it fully renders within 3 seconds

**TC-14-12 — Load failure shows a generic error with retry**
- Given the page fails to load due to network or server error
- When the visitor views the screen
- Then a generic error message "Gagal memuat, periksa koneksi internet dan coba lagi" with a retry button is shown

**TC-14-13 — Deleted profile shows a not-found state with no data leakage**
- Given the pet profile behind this link has been deleted
- When a visitor opens the link
- Then the page shows "Profil hewan peliharaan ini sudah tidak ada" and displays no pet data of any kind

**TC-14-14 — Link supports Open Graph preview**
- Given the share link is pasted into WhatsApp, Line, or Instagram
- When the preview renders
- Then it shows the pet's avatar as the preview image and "Kisah tumbuh kembang [Nama Hewan]" as the title

**TC-14-15 — Without the app installed, both CTAs route to the app store**
- Given the visitor does not have TailTopia installed
- When they tap either CTA
- Then they are routed to the App Store (iOS) or Google Play (Android)

**TC-14-16 — With the app installed, both CTAs deep-link into the app**
- Given the visitor has TailTopia installed
- When they tap either CTA
- Then the app opens via deep link directly to that pet's read-only archive view

**TC-14-17 — Logged-out users hitting the deep link see the login prompt**
- Given the visitor has the app installed but is not logged in
- When the deep link opens the app
- Then the FR-0C login prompt is triggered

---

### FR-15 — Archive page animated share button (FAB)

**TC-15-01 — FAB persists through scrolling**
- Given the user is on their pet's archive page
- When they scroll the content area
- Then the FAB remains fixed in place, not scrolling away

**TC-15-02 — Animation plays once on first visit only**
- Given the user enters the archive page for the first time this install
- When the page loads
- Then the FAB plays its entrance animation once, and remains static on subsequent visits

**TC-15-03 — Tapping opens the system share sheet with the pet card link**
- Given the user taps the FAB
- When the share sheet opens
- Then it is pre-loaded with the FR-14 pet card link

**TC-15-04 — FAB is hidden for B/C users**
- Given a status B/C user (no pet profile) opens the Growth Archive tab
- When the tab renders
- Then no FAB is shown

---

### FR-16 — Consultation record save confirmation

**TC-16-01 — Status A with existing profile saves directly**
- Given the user is status A with an existing pet profile and just finished a consultation
- When the save prompt appears
- Then it reads "Simpan konsultasi ini ke profil [Nama Hewan]?"; tapping "Simpan ke profil" saves immediately

**TC-16-02 — Status A without a profile routes through profile creation**
- Given the user is status A without a profile and just finished a consultation
- When they tap "Buat profil sekarang" on the save prompt
- Then they are routed into FR-11 creation; on completion the celebration page is skipped, the consultation record is auto-saved, and they return to the result page

**TC-16-03 — Status B/C routes through FR-0G with auto status switch**
- Given the user is status B/C and just finished a consultation
- When they tap "Buat profil" on the save prompt
- Then their status switches to A, they enter FR-0G onboarding, and on completion the celebration page is skipped, the record auto-saves, and they return to the result page

**TC-16-04 — Skipping does not save and does not re-prompt for the same consultation**
- Given any variant of the save prompt is showing
- When the user taps "Lewati"
- Then the record is not saved, and the prompt does not reappear again for this specific consultation

**TC-16-05 — Saved entry contains the required fields**
- Given a consultation record has been saved via any path above
- When the user views it in the archive
- Then it includes date, symptom description, AI rating, and advice summary

---

### FR-37 — Growth Archive tab page layout

**TC-37-01 — Pet info card shows required fields and quick status edit**
- Given the user opens the Growth Archive tab with an existing profile
- When the page renders
- Then the info card shows avatar, name, breed, age, bio, and a status quick-edit control

**TC-37-02 — Stats bar shows happy-moment and consultation counts**
- Given the user views the archive page
- When the stats bar renders
- Then it shows "X momen bahagia · X konsultasi"

**TC-37-03 — Default view is timeline**
- Given the user enters the archive page fresh (new session)
- When it renders
- Then the timeline view is shown by default

**TC-37-04 — Milestone progress bar reflects pet-type-specific N**
- Given the pet's type is cat or dog
- When the progress bar renders
- Then it shows "Selesai X / 30"; for "Lainnya" type pets it shows "Selesai X / 15"

**TC-37-05 — Tapping the progress bar opens the milestone list**
- Given the user views the progress bar
- When they tap it
- Then the FR-42 milestone list page opens

**TC-37-06 — FAB shown in both views**
- Given the user toggles between timeline and calendar view
- When either view is active
- Then the FR-15 FAB remains visible

**TC-37-07 — Timeline entries sorted by event date, descending**
- Given the pet has multiple happy moments and health events
- When the timeline renders
- Then all entries are interleaved and sorted by event date, most recent first

**TC-37-08 — First happy moment shows a permanent tag**
- Given the pet's very first happy moment entry
- When it appears in the timeline
- Then it carries a permanent 🌟 "Momen bahagia pertama" tag, regardless of how many entries are added afterward

**TC-37-09 — First health event shows a permanent tag**
- Given the pet's very first health event entry
- When it appears in the timeline
- Then it carries a permanent 🌟 "Catatan konsultasi pertama" tag

**TC-37-10 — Calendar month navigation works via dropdown and swipe**
- Given the user is on the calendar view
- When they use the top dropdown selector or swipe left/right
- Then the view navigates to the selected/adjacent month accordingly

**TC-37-11 — Day cell with only a happy moment shows its thumbnail**
- Given a date has one or more happy moments and no health event
- When the calendar renders that cell
- Then it shows the first photo of the earliest-published entry on that date as the cell background

**TC-37-12 — Day cell with happy moment + health event shows thumbnail with badge**
- Given a date has both a happy moment and a health event
- When the calendar renders that cell
- Then it shows the photo thumbnail with a small 🏥 badge overlaid in the corner

**TC-37-13 — Day cell with only a health event shows the hospital icon**
- Given a date has a health event but no photo
- When the calendar renders that cell
- Then it shows a 🏥 icon marker

**TC-37-14 — Empty day cell shows date number with a faint "+"**
- Given a date has no records
- When the calendar renders that cell
- Then it shows the date number and a faint "+" prompt

**TC-37-15 — Future date cells are disabled**
- Given a date is in the future
- When the calendar renders that cell
- Then it is greyed out, shows no "+", and is not tappable

**TC-37-16 — Tapping a populated cell opens the day detail page**
- Given a date cell has at least one record
- When the user taps it
- Then a full-screen day detail page opens showing all entries for that date

**TC-37-17 — Tapping "+" on an empty cell opens a pre-filled publish entry**
- Given the user taps the "+" on an empty future-eligible date cell
- When the editor opens
- Then it is pre-selected to "Kalender Tumbuh Kembang" type with the event date pre-filled to that cell's date

**TC-37-18 — Day detail page has no publish entry and no direct delete**
- Given the user is on a day detail page
- When they look for a publish "+" or a delete control
- Then neither is present; deletion is only reachable via the content detail page's "···" menu

**TC-37-19 — Backdated content appears only on its event-date cell**
- Given the user publishes today a "Kalender Tumbuh Kembang" post with an event date set to a past date
- When they view the calendar
- Then the entry appears only on the past event-date cell, not on today's cell; today's cell remains empty if it has no other records

**TC-37-20 — View toggle persists for the session, resets on next Tab entry**
- Given the user switches to calendar view and navigates to another Tab
- When they return to the Growth Archive Tab within the same app session
- Then calendar view is still shown; after a fresh app session, it resets to timeline view as default

**TC-37-21 — Status A without a profile sees an empty state**
- Given the user is status A but skipped profile creation
- When they open the Growth Archive Tab
- Then it shows "Belum ada profil hewan peliharaan, buat sekarang" with a create button, instead of timeline/calendar content

**TC-37-22 — Status B/C sees the pet-owner-only prompt**
- Given the user is status B or C
- When they open the Growth Archive Tab
- Then it shows "Arsip tumbuh kembang khusus untuk pengguna berhewan peliharaan, ubah status hewan peliharaanmu untuk membukanya" with a status-change entry

**TC-37-23 — Timeline/calendar load failure preserves cached header data**
- Given the content area fails to load due to network/server error
- When the page renders
- Then the content area shows "Gagal memuat, tarik untuk mencoba lagi" with a retry entry, while the pet info card and stats bar still display cached data normally

**TC-37-24 — Day detail load failure shows retry**
- Given the day detail page fails to load
- When the user views it
- Then the body area shows "Gagal memuat, tarik untuk mencoba lagi" with a retry entry

---

### FR-39 — Pet profile editing

**TC-39-01 — All five editable fields can be changed**
- Given the user opens profile editing
- When they view the form
- Then avatar, name, breed, birthday, and bio are all editable (pet type is not, per FR-11)

**TC-39-02 — Entry point 1: Growth Archive tab edit button**
- Given the user is on the Growth Archive tab
- When they tap the "Edit" button on the pet info card
- Then the profile editor opens

**TC-39-03 — Entry point 2: "Saya" tab edit pet profile (status A only)**
- Given a status A user is on the "Saya" tab
- When they tap "Edit profil hewan peliharaan"
- Then the same profile editor opens

**TC-39-04 — Changes apply immediately and propagate to the pet card**
- Given the user edits and saves any field
- When they view the FR-14 pet card H5 page afterward
- Then the updated information is reflected

**TC-39-05 — No limit on edit frequency**
- Given the user has just saved an edit
- When they immediately open the editor again and make another change
- Then the app allows it without any cooldown or frequency restriction

---

### FR-21 — Growth Archive tab quick pet-status edit

**TC-21-01 — Status edit accessible from both tabs**
- Given the user is logged in
- When they check the Growth Archive tab and the "Saya" tab
- Then both expose a pet-status edit entry

**TC-21-02 — Both entries reuse the same status picker UI**
- Given the user opens status editing from either entry point
- When the picker renders
- Then it is the same FR-0F status selection UI in both cases, not a separate modal

**TC-21-03 — Changing status refreshes the Feed immediately**
- Given the user changes their pet status
- When the change is confirmed
- Then the home Feed immediately re-filters according to the new status (FR-17)

**TC-21-04 — B/C → A with no prior profile triggers onboarding**
- Given a status B/C user with no pet profile ever created changes status to A
- When the change is confirmed
- Then FR-0G profile creation onboarding (with skip option) is triggered; skipping it triggers the FR-0H banner

**TC-21-05 — B/C → A with an existing prior profile restores it directly**
- Given a status B/C user who previously had status A and an existing profile changes status back to A
- When the change is confirmed
- Then the existing profile becomes visible again directly, without triggering FR-0G or FR-0H

**TC-21-06 — A → B/C preserves profile data**
- Given a status A user with a profile changes status to B or C
- When the change is confirmed
- Then the pet profile data is retained (not deleted), the Growth Archive Tab shows the pet-owner-only prompt (FR-37), and the Feed refreshes accordingly

---

### FR-42 — First-time milestone system

**TC-42-01 — Milestone list is assigned by pet type at creation**
- Given a pet profile is created with type cat, dog, or other
- When the milestone system initializes
- Then the corresponding list is assigned: 30 items for cat, 30 for dog, 15 for other

**TC-42-02 — Milestone page reachable via the progress bar**
- Given the user is on the Growth Archive tab
- When they tap "Selesai X / N pencapaian"
- Then the milestone list page opens

**TC-42-03 — System-auto type completes without user action**
- Given a milestone with trigger type "Otomatis sistem" (e.g., first photo uploaded)
- When the qualifying action occurs
- Then the milestone is automatically marked complete and the corresponding celebration animation fires

**TC-42-04 — User-checkin "Sudah dicatat" opens a content picker scoped to growth-calendar posts**
- Given the user taps a grey (incomplete) user-checkin-type badge and selects "Sudah dicatat"
- When the content picker opens
- Then it lists only that pet's already-published "Kalender Tumbuh Kembang" posts, excluding "Berbagi Harian" and "Edukasi Profesional"

**TC-42-05 — Selecting a post completes the milestone**
- Given the content picker is open
- When the user selects one post
- Then the milestone is marked complete and the completion time is recorded

**TC-42-06 — Closing the picker without selecting leaves the milestone unchanged**
- Given the content picker is open
- When the user closes it without selecting anything
- Then the milestone remains incomplete with no state change

**TC-42-07 — A growth-calendar post can only be linked to one milestone**
- Given a post has already been used to complete one milestone
- When the user opens the content picker for a different milestone
- Then that post appears greyed out and cannot be selected again

**TC-42-08 — User-checkin "Buat postingan" routes to a pre-selected publish entry**
- Given the user taps "Buat postingan" on an incomplete user-checkin milestone
- When the editor opens
- Then it is pre-selected to "Kalender Tumbuh Kembang" type, with no milestone pre-locked yet

**TC-42-09 — Abandoning that publish flow leaves the milestone incomplete**
- Given the user entered publish via "Buat postingan" and then exits without publishing
- When they return to the milestone page
- Then the milestone remains incomplete

**TC-42-10 — Successful growth-calendar publish from this path auto-completes the milestone**
- Given the user entered publish via "Buat postingan" and successfully publishes a "Kalender Tumbuh Kembang" post
- When publish succeeds
- Then the system automatically marks the milestone complete

**TC-42-11 — Switching content type before publishing does not auto-complete**
- Given the user entered publish via "Buat postingan" but manually switches the type to "Berbagi Harian" or "Edukasi Profesional" before publishing
- When that post is published
- Then the milestone is NOT auto-completed; the user must return to the milestone page and act again

**TC-42-12 — Push+same-day type completes on same-day publish**
- Given a milestone with trigger type "Push sistem + diposting pengguna pada hari yang sama" reaches its trigger date
- When the system sends the reminder push and the user publishes a "Kalender Tumbuh Kembang" entry that same day
- Then the milestone auto-completes

**TC-42-13 — S-tier celebration matches spec**
- Given an S-tier milestone completes
- When the celebration fires
- Then a half-screen overlay lasting 1–2 seconds with badge display is shown

**TC-42-14 — M-tier celebration matches spec**
- Given an M-tier milestone completes
- When the celebration fires
- Then a full-screen animation lasting 3 seconds with a badge-unlock screen is shown

**TC-42-15 — L-tier celebration matches spec and auto-generates a share card**
- Given an L-tier milestone completes
- When the celebration fires
- Then a chest-opening style interactive animation plays, followed by an auto-generated, shareable milestone card

**TC-42-16 — Completed milestones are irreversible and show completion date**
- Given any milestone has been completed
- When the user views it afterward
- Then it cannot be reverted to incomplete, and (for user-checkin types) its completion date is displayed

**TC-42-17 — System-auto/push-type badges show explanation only, no confirm action**
- Given the user taps an incomplete badge whose trigger type is "Otomatis sistem" or "Push sistem + diposting pengguna pada hari yang sama"
- When the card opens
- Then it shows explanatory text about the trigger condition only, with no "Sudah dicatat" confirmation button (unlike user-checkin badges)

**TC-42-18 — Pet type lock keeps the milestone list consistent**
- Given a pet's type was set at creation and cannot be changed (FR-11)
- When the user views the milestone list at any time afterward
- Then it remains the same list assigned at creation, with no mid-stream list changes or data corruption

---

## §4.4 Homepage Feed (Homepage Content Feed)

### FR-17 — Home Feed content model

**TC-17-01 — Status A sees all three content types**
- Given the user's pet status is A
- When they view the home Feed
- Then content from all three types ("Berbagi Harian" + "Edukasi Profesional" + "Kalender Tumbuh Kembang" happy moments) is shown

**TC-17-02 — Status B sees only two types, growth-calendar excluded**
- Given the user's pet status is B
- When they view the home Feed
- Then only "Edukasi Profesional" and "Berbagi Harian" content is shown; "Kalender Tumbuh Kembang" happy moments are excluded

**TC-17-03 — Status C sees all three content types**
- Given the user's pet status is C
- When they view the home Feed
- Then content from all three types is shown

**TC-17-04 — Logged-out users see all content, unfiltered**
- Given the user is not logged in
- When they view the home Feed
- Then content from all three types is shown with no status-based filtering

**TC-17-05 — Filtering is hard (binary), not weighted**
- Given a status B user's Feed excludes growth-calendar content
- When they scroll extensively
- Then no growth-calendar items appear at any point — the exclusion is absolute, not a reduced-weight/lower-frequency treatment

**TC-17-06 — No follow/friend system; Feed is fully public**
- Given the user is logged in
- When they view the Feed
- Then it draws from the entire platform's public content, with no concept of "following" affecting what appears

**TC-17-07 — Sort order is pure reverse-chronological by publish time**
- Given multiple posts exist across different authors
- When the Feed renders
- Then items are ordered strictly by publish time, newest first, with no algorithmic re-ranking

**TC-17-08 — Changing pet status refreshes the Feed immediately**
- Given the user changes their pet status (via FR-21 or FR-20)
- When the change is confirmed
- Then the Feed immediately reloads content filtered to the new status

**TC-17-09 — Feed card shows author avatar and nickname, tappable to mini profile**
- Given the user views any Feed card
- When they look at the top-left
- Then the author's avatar and nickname are shown, and tapping them opens the FR-26 mini profile preview card

**TC-17-10 — Content preview is truncated to 2 lines**
- Given a post's text content exceeds 2 lines
- When it renders in the Feed card
- Then only the first 2 lines are shown, with the remainder truncated/ellipsized

**TC-17-11 — First image is shown when content has images**
- Given a post includes one or more images
- When its Feed card renders
- Then the first image is displayed on the card

**TC-17-12 — Text-only card is shown when content has no images**
- Given a post has no images
- When its Feed card renders
- Then the card displays as text-only, with no broken/placeholder image area

**TC-17-13 — Like/comment counts are not shown on the card**
- Given any Feed card
- When the user views it without opening it
- Then no like or comment count is visible; these only become visible after opening the detail page

**TC-17-14 — Tapping anywhere on the card opens the detail page**
- Given the user taps any part of a Feed card (not just the image or title)
- When the tap registers
- Then the FR-28 content detail page opens

**TC-17-15 — Infinite scroll loads the next batch near the bottom**
- Given the user is scrolling the Feed
- When they reach approximately 5 items from the bottom of the currently loaded content
- Then the next batch automatically begins loading

**TC-17-16 — Each batch loads 20 items**
- Given the user opens the Feed for the first time or triggers infinite scroll
- When content loads
- Then exactly 20 items are loaded per batch (first load and every subsequent batch)

**TC-17-17 — Pull-to-refresh fetches the latest content**
- Given the user is at the top of the Feed
- When they pull down to refresh
- Then the Feed fetches and displays the latest content

---

### FR-18 — Cold-start content and Feed empty state

**TC-18-01 — Seed content and user content are mixed with no distinguishing mark**
- Given the platform has both operator-seeded content and real user-published content
- When the user views the Feed
- Then both appear interleaved with no visual marker distinguishing seed content from user content

**TC-18-02 — Empty Feed shows the guidance empty state**
- Given the Feed has zero content (e.g., fresh environment before seeding)
- When the user views the home Feed
- Then it shows the guidance text "Jadilah yang pertama berbagi!" along with the publish "+" entry

**TC-18-03 — Feed load failure preserves already-loaded content**
- Given the Feed fails to load due to network or server error
- When the user views the screen
- Then it shows "Gagal memuat, tarik untuk mencoba lagi" with a retry entry; if content was already loaded before the failure, it remains visible

**TC-18-04 — Pagination failure shows a bottom retry prompt only**
- Given the user has content already loaded and infinite scroll triggers a failed load of additional content
- When the failure occurs
- Then a retry prompt appears at the bottom of the list only, without disrupting or hiding the already-loaded content above

**TC-18-05 — Upload failure during publish shows a specific error (FR-1 / FR-12 shared rule)**
- Given the user is uploading images as part of an AI consultation (FR-1) or content publish (FR-12)
- When the network drops or the server errors mid-upload
- Then the app shows "Gagal mengunggah gambar, periksa koneksi internet dan coba lagi" with a "Coba lagi" button

**TC-18-06 — Retry only re-uploads the failed files, text is preserved**
- Given an upload failure occurred and the retry button is showing
- When the user taps "Coba lagi"
- Then only the previously failed files are re-uploaded; any text already entered remains intact in the current session without requiring re-entry

**TC-18-07 — No persistent draft box; closing the editor clears content**
- Given the user has entered text/images in the publish or consultation editor
- When they close the editor screen or quit the app without submitting
- Then the content is cleared entirely and not saved to the server as a draft

**TC-18-08 — Lost content requires starting over**
- Given the user lost their in-progress content per TC-18-07
- When they want to publish again
- Then they must re-enter all content from scratch; no recovery mechanism exists

---

## §4.5 App Navigation Architecture

### FR-19 — Bottom Tab Bar navigation

**TC-19-01 — Tab Bar shows 5 positions in the correct order**
- Given the user is on any top-level page
- When they view the bottom Tab Bar
- Then it shows, left to right: "Beranda" | "Arsip Tumbuh Kembang" | [+] | "Konsultasi" | "Saya"

**TC-19-02 — Only "Beranda" is accessible while logged out**
- Given the user is logged out
- When they view the Tab Bar
- Then "Beranda" opens normally; the other four tabs each trigger the FR-0C login modal when tapped

**TC-19-03 — Growth Archive tab defaults to the current user's own pet**
- Given a logged-in user with a pet profile taps "Arsip Tumbuh Kembang"
- When the tab opens
- Then it displays that user's own pet's archive by default

**TC-19-04 — "+" button is visually elevated above the other tabs**
- Given the user views the Tab Bar
- When they compare the "+" button to the other 4 tabs
- Then it is rendered in a raised/elevated style, visually distinct from the 4 flush tabs

**TC-19-05 — Tapping "+" while logged out triggers the login modal**
- Given the user is logged out
- When they tap the "+" button
- Then the FR-0C login modal appears instead of opening the publish editor

**TC-19-06 — Successful login from a Tab Bar gate auto-navigates to the target tab**
- Given the user triggered FR-0C by tapping a gated tab (Growth Archive / "+" / Konsultasi / Saya) while logged out
- When they complete login successfully
- Then the app automatically navigates to the tab they originally tapped

**TC-19-07 — Tab Bar hides on second-level pages**
- Given the user navigates from a top-level tab into a second-level page (e.g., consultation detail, profile editing)
- When that page is shown
- Then the Tab Bar is hidden

**TC-19-08 — Tab Bar reappears on top-level pages**
- Given the user is on a second-level page with the Tab Bar hidden
- When they navigate back to any top-level tab
- Then the Tab Bar reappears

**TC-19-09 — Red dot badge shows on "Konsultasi" for unread vet replies**
- Given the user has an unread vet reply message
- When they view the Tab Bar
- Then a red dot badge appears on the "Konsultasi" tab

**TC-19-10 — Bell badge shows total unread notification count**
- Given the user has unread notifications combining vet replies and interaction notifications (likes/comments)
- When they view the notification bell icon
- Then it shows the combined total count

**TC-19-11 — Both badge types can show simultaneously**
- Given the user has both an unread vet reply and other unread notifications
- When they view the Tab Bar and bell icon
- Then the "Konsultasi" red dot and the bell count badge both display at the same time; neither suppresses the other

**TC-19-12 — Switching tabs during an active vet chat does not disconnect it**
- Given the user is in an active vet consultation chat
- When they tap a different Tab Bar item
- Then the chat session remains connected in the background, neither interrupted nor closed

**TC-19-13 — Unread indicator persists while away from the chat**
- Given the user switched away from an active chat per TC-19-12 and a new message arrived
- When they view the Tab Bar
- Then the red dot on "Konsultasi" continues to indicate the unread message

**TC-19-14 — Returning to the Konsultasi tab resumes the chat seamlessly**
- Given the user switched away during an active chat
- When they tap back into the "Konsultasi" tab
- Then they land directly back in the conversation screen with full, uninterrupted message history

**TC-19-15 — Vet account ban immediately revokes their login**
- Given an operator bans a vet account from the back office
- When the ban takes effect
- Then that vet account can no longer log in

**TC-19-16 — Banning a vet mid-session notifies the affected user**
- Given a vet is banned while they have an active consultation session with a user
- When the ban takes effect
- Then the user receives a system message: "Dokter hewan untuk sementara offline, konsultasi ini terputus, silakan mulai konsultasi baru"

**TC-19-17 — Interrupted session is marked accordingly in history**
- Given a session was interrupted per TC-19-16
- When the user views their consultation history
- Then that session appears marked as "Terputus"

**TC-19-18 — User can immediately start a new consultation after interruption**
- Given the user's session was interrupted due to a vet ban
- When they return to the consultation module
- Then they can immediately initiate a new consultation request without restriction

---

## §4.6 Personal Center ("Saya")

> Excludes FR-37/FR-39/FR-21/FR-42, which are physically located within this PRD section but are covered under §4.3 Growth Archive above, where they functionally belong.

### FR-20 — "Saya" page structure and content

**TC-20-01 — Top nav shows the fixed page title**
- Given the user opens the "Saya" tab
- When the page renders
- Then the top-left shows the fixed title "Saya"

**TC-20-02 — Help/feedback icon opens the help page**
- Given the user views the top-right of the "Saya" page
- When they tap the help/feedback icon
- Then the help & feedback page opens

**TC-20-03 — Settings icon opens the settings page**
- Given the user views the top-right of the "Saya" page
- When they tap the settings icon
- Then the settings page opens

**TC-20-04 — Settings page contains the three required options**
- Given the user is on the settings page
- When they view its contents
- Then they see language settings, logout, and account deletion

**TC-20-05 — User info block is the primary visual element**
- Given the user views the "Saya" page body
- When it renders
- Then avatar, nickname, and an edit button appear as the highest-visual-weight section

**TC-20-06 — Avatar defaults to the Google account avatar**
- Given a user has not customized their avatar
- When they view their profile
- Then it shows the avatar from their Google account, which they can replace

**TC-20-07 — Nickname is editable with a 20-character limit**
- Given the user taps to edit their nickname
- When they enter a new value
- Then up to 20 characters are accepted, and excess is prevented or rejected

**TC-20-08 — "Edit profil hewan peliharaan" entry shown only for status A**
- Given the user's status is A
- When they view the "Saya" page
- Then an "Edit profil hewan peliharaan" text entry is visible; status B/C users do not see it

**TC-20-09 — That entry opens the same editor as the Growth Archive entry point**
- Given the status A user taps "Edit profil hewan peliharaan"
- When the editor opens
- Then it is the identical shared editor page used by FR-39's Growth Archive entry point

**TC-20-10 — Pet card shown only for status A with an existing profile**
- Given the user is status A and has created a pet profile
- When they view the "Saya" page
- Then a pet card is shown with the pet's avatar, name, and the first photo from its most recent happy moment

**TC-20-11 — Tapping the pet card navigates to the Growth Archive tab**
- Given the pet card is visible
- When the user taps it
- Then the app navigates to the Growth Archive tab

**TC-20-12 — Pet card has lower visual weight than the user info section**
- Given both sections are visible
- When the user compares them
- Then the user info block is visually dominant ("60% human / 40% pet" design intent), with the pet card positioned below it

**TC-20-13 — Status A without a profile shows a guidance card instead**
- Given the user is status A but has not created a pet profile
- When they view the "Saya" page
- Then the pet card position instead shows a guidance card "Buat profil eksklusif untuk hewan peliharaanmu"

**TC-20-14 — Tapping the guidance card opens profile creation**
- Given the guidance card is showing
- When the user taps it
- Then the FR-11 creation flow opens

**TC-20-15 — Status B/C shows neither the pet card nor the guidance card**
- Given the user's status is B or C
- When they view the "Saya" page
- Then neither the pet card nor the guidance card appears in that section

**TC-20-16 — Pet status display includes an edit entry synced with Growth Archive**
- Given the user views their pet status on the "Saya" page
- When they check the edit entry
- Then it is present and functionally identical to the FR-21 entry on the Growth Archive tab

**TC-20-17 — Changing status refreshes the pet card section immediately**
- Given the user changes their pet status
- When the change is confirmed
- Then the pet-card area of the "Saya" page updates immediately to reflect the new status

**TC-20-18 — "Postingan Saya" shows all three content types, reverse chronological**
- Given the user has published content across all three types
- When they view "Postingan Saya"
- Then all of it appears mixed together, sorted by publish time, most recent first

**TC-20-19 — Each entry can be opened or deleted**
- Given the user views an entry in "Postingan Saya"
- When they tap it or use its delete option
- Then it opens the FR-28 detail page, or is removed via FR-36 delete

**TC-20-20 — Growth-calendar content in "Postingan Saya" and the archive timeline is the same record**
- Given a growth-calendar post appears both in "Postingan Saya" and the pet's archive timeline
- When the user deletes it from either location
- Then it is removed from both, confirming they are the same underlying record, not separate copies

**TC-20-21 — Sort order differs between the two views**
- Given the same growth-calendar content appears in both places
- When the user compares ordering
- Then "Postingan Saya" sorts by publish time while the archive timeline/calendar sorts by event date

**TC-20-22 — Account deletion requires a first confirmation explaining consequences**
- Given the user taps account deletion in settings
- When the first confirmation modal appears
- Then it states "Data tidak dapat dipulihkan setelah dihapus"

**TC-20-23 — Second confirmation requires explicit high-risk action**
- Given the user proceeds past the first deletion confirmation
- When the second step appears
- Then it requires typing a confirmation phrase or tapping a clearly marked high-risk button before deletion proceeds

**TC-20-24 — Logout returns to guest browsing on the home feed**
- Given the user is logged in
- When they tap logout
- Then the app returns to the home feed in the logged-out/guest browsing state (FR-0A)

**TC-20-25 — Profile edits apply immediately**
- Given the user edits their avatar or nickname
- When they save
- Then the change is reflected immediately without further action

**TC-20-26 — Deleted user's posts/comments remain visible post-deletion**
- Given a user has deleted their account
- When other users view the Feed or comment sections containing that user's past content
- Then the posts and comments remain visible, not removed

**TC-20-27 — "Postingan Saya" empty state shown when the user has never published**
- Given a user (status A, B, or C) has never published any content
- When they view the "Saya" page
- Then the "Postingan Saya" grid is replaced by an empty-state card with the headline "Belum ada postingan", supporting copy, and a "+ Buat Postingan" outline CTA that opens the P-37 type-selection page with no type preselected; the profile header and pet card/guidance card above it still render normally; the same copy is shown regardless of A/B/C status

**TC-20-27 — Deleted user's identity is anonymized on remaining content**
- Given a deleted user's content is still visible
- When another user views the author info
- Then the avatar shows a default placeholder and the nickname displays as "Pengguna yang Dihapus"

**TC-20-28 — Tapping the anonymized author does not open the mini profile card**
- Given another user sees a "Pengguna yang Dihapus" author
- When they tap that avatar/name
- Then the FR-26 mini profile preview card does not open

**TC-20-29 — Pet profile and account data are fully deleted, card link invalidated**
- Given a user completes account deletion
- When the deletion processes
- Then their pet profile (including the H5 card) and account data are fully removed, and the pet card share link becomes invalid immediately

**TC-20-30 — Consultation records are retained anonymized for the historical database**
- Given a user with past consultations deletes their account
- When the deletion processes
- Then their consultation records are retained with personal identity stripped, keeping only symptom description, AI rating, and advice summary for FR-5's historical reference database

---

### FR-27 — Language settings

**TC-27-01 — First launch auto-detects device language**
- Given a user installs and opens the app for the first time
- When the app initializes
- Then it matches: Indonesian device language → Bahasa Indonesia; English device language → English; any other device language → defaults to English

**TC-27-02 — Manual language switch takes effect immediately without restart**
- Given the user navigates to "Saya → Pengaturan → Bahasa"
- When they select a different language
- Then the app's language switches immediately, with no restart required

**TC-27-03 — User-generated content is not restricted by language setting**
- Given the user has the app set to any language
- When they publish content
- Then they may write in any language they choose, with no enforcement tied to the app's display language

**TC-27-04 — All UI copy, system prompts, and errors are available in both languages**
- Given the app is set to either Bahasa Indonesia or English
- When the user encounters any UI text, system prompt, or error message
- Then it is correctly localized in the selected language

---

## §4.7 Push Notifications

### FR-22A — Vet reply push notification

**TC-22A-01 — Push fires when the user is not viewing the conversation**
- Given a vet sends a reply in an active consultation
- When the user is not currently viewing that conversation screen
- Then a push notification is triggered

**TC-22A-02 — Notification content matches spec**
- Given the push fires
- When the user views it
- Then it shows title "Balasan Dokter Hewan" and body "Konsultasi hewan peliharaanmu mendapat balasan baru, ketuk untuk melihat"

**TC-22A-03 — Tapping the notification jumps to the consultation**
- Given the user receives this push
- When they tap it
- Then the app navigates directly to that consultation session

**TC-22A-04 — No duplicate push while actively viewing the conversation**
- Given the user is actively viewing the conversation when the vet replies
- When the reply arrives
- Then no push notification is sent (the message simply appears in the open chat)

---

### FR-22B — Content interaction push notifications

**TC-22B-01 — Like triggers a push with correct copy**
- Given another user likes the current user's content
- When the like registers
- Then a push fires with title "Suka Baru" and body "Seseorang menyukai [Judul Konten/Nama Hewan] milikmu"

**TC-22B-02 — Comment triggers a push with correct copy**
- Given another user comments on the current user's content
- When the comment is posted
- Then a push fires with title "Komentar Baru" and body "Seseorang mengomentari kontenmu, ketuk untuk melihat"

**TC-22B-03 — Tapping either notification opens the content detail page**
- Given the user receives a like or comment push
- When they tap it
- Then the corresponding content detail page opens

**TC-22B-04 — No notification batching in V1.0.0**
- Given multiple users like or comment on the same content within a short time
- When each interaction occurs
- Then each triggers its own individual push notification; no merging/batching occurs

---

### FR-22C — App version update reminder (in-app prompt)

**TC-22C-01 — Version check runs on every cold start**
- Given the user launches the app from a fully closed state
- When the app initializes
- Then it checks for an available new version

**TC-22C-02 — Recommended update shows a dismissible prompt**
- Given a regular (non-critical) new version is available
- When the app detects it
- Then a modal shows "Versi baru ditemukan, disarankan untuk memperbarui" with a "Nanti" option; dismissing it shows the same prompt again on the next launch

**TC-22C-03 — Forced update cannot be dismissed**
- Given a critical new version requiring forced update is available
- When the app detects it
- Then the modal has no dismiss option, and the user must update via the app store before continuing to use the app

**TC-22C-04 — Update routes to the correct store/in-app update**
- Given the user taps the update action
- When the action is triggered
- Then iOS routes to the App Store, and Android routes to Google Play or the in-app update flow

**TC-22C-05 — This uses an in-app modal, not a system push notification**
- Given a new version is available
- When the prompt appears
- Then it is rendered as an in-app modal that requires no push notification permission

---

### FR-22E — Vet-side new request push notification

**TC-22E-01 — New vet consultation request notifies online vets**
- Given a user submits a vet consultation request
- When the request enters the pending queue
- Then a push is sent to all currently online vet accounts

**TC-22E-02 — AI consultation does not trigger this push**
- Given a user submits only an AI consultation (not a vet request)
- When it is processed
- Then no push is sent to vets

**TC-22E-03 — Notification content matches spec**
- Given the push fires
- When a vet views it
- Then it shows title "Permintaan Konsultasi Baru" and body "Ada permintaan konsultasi baru, ketuk untuk melihat"

**TC-22E-04 — Offline vets do not receive the push**
- Given a vet account's status is offline (FR-32)
- When a new request enters the queue
- Then that vet does not receive a push

**TC-22E-05 — Tapping the notification opens the pending-request tab**
- Given a vet receives this push
- When they tap it
- Then the vet workbench opens directly to the "待接单" (pending) tab

---

### FR-40 — Pet birthday reminder push

**TC-40-01 — Triggers automatically one day before the pet's birthday**
- Given a pet profile has a birthday on file
- When the date reaches one day before that birthday
- Then the system automatically triggers the reminder

**TC-40-02 — Notification content matches spec**
- Given the reminder fires
- When the user views it
- Then it shows title "Pengingat Ulang Tahun 🎂" and body "Besok [Nama Hewan] akan berusia X tahun! Catat satu momen bahagia spesial"

**TC-40-03 — Tapping routes to the publish entry pre-selected to growth calendar**
- Given the user taps this notification
- When the app opens
- Then it routes to the unified "+" publish entry with "Kalender Tumbuh Kembang" pre-selected

**TC-40-04 — Unauthorized users see it in the in-app notification center instead**
- Given the user has not granted push permission
- When the reminder's trigger date arrives
- Then the notification appears in the FR-34 in-app notification center on that day, instead of as a system push

**TC-40-05 — No birthday field means no notification**
- Given a pet profile has no birthday filled in
- When the system evaluates reminders
- Then this notification never triggers for that pet

---

### FR-41 — Companionship anniversary reminder

**TC-41-01 — Triggers at 30/100/365 days since profile creation**
- Given a pet profile reaches exactly 30, 100, or 365 days since its FR-11 creation date
- When that day arrives
- Then the corresponding anniversary reminder triggers

**TC-41-02 — Notification content matches spec**
- Given the reminder fires
- When the user views it
- Then it shows title "Hari Jadi Kebersamaan 🎉" and body "Kamu sudah bersama [Nama Hewan] selama X hari, yuk lihat kisah tumbuh kembangnya"

**TC-41-03 — Appears in-app regardless of push authorization, plus system push if authorized**
- Given the reminder triggers
- When the user checks the FR-34 in-app notification center
- Then it is present there regardless of push permission status; if push is authorized, a system push is also sent

**TC-41-04 — Tapping routes to the Growth Archive tab**
- Given the user taps this notification
- When the app opens
- Then it navigates to the Growth Archive tab

**TC-41-05 — Each milestone fires exactly once**
- Given the 30-day anniversary has already triggered for a pet
- When time continues to pass
- Then it does not trigger again (the 100-day and 365-day milestones each fire once on their own respective dates)

---

### FR-22D — App permission requests and denial handling

**TC-22D-01 — Camera/album permission requested on AI consultation upload**
- Given the user taps "Unggah" in the AI consultation flow (FR-1) for the first time
- When the tap registers
- Then the camera/album permission request is triggered

**TC-22D-02 — Camera/album permission requested on avatar upload**
- Given the user taps the avatar edit control during pet profile creation (FR-11)
- When the tap registers
- Then the camera/album permission request is triggered

**TC-22D-03 — Camera/album permission requested on growth-calendar publish**
- Given the user taps the "+" publish entry to attach images (FR-12)
- When the tap registers
- Then the camera/album permission request is triggered

**TC-22D-04 — Granting proceeds normally**
- Given any of the above permission prompts appears
- When the user grants it
- Then the camera/album picker opens normally

**TC-22D-05 — Denying shows a guidance modal with the correct copy**
- Given the user denies the camera/album permission
- When the denial registers
- Then a guidance modal appears: "Perlu izin galeri untuk mengunggah, silakan aktifkan di pengaturan", with a "Buka Pengaturan" button and a "Batal" button

**TC-22D-06 — "Buka Pengaturan" routes to the system permission settings**
- Given the denial guidance modal is showing
- When the user taps "Buka Pengaturan"
- Then the OS-level app permission settings page opens (iOS: Settings > App Name; Android: app permission management)

**TC-22D-07 — Push permission is not requested at first launch**
- Given a brand-new user opens the app for the very first time
- When onboarding proceeds
- Then no push permission prompt appears at this point

**TC-22D-08 — Push permission requested after first completed consultation**
- Given the user completes their first AI or vet consultation
- When the result page closes
- Then the push permission prompt appears immediately with copy "Aktifkan notifikasi, dapatkan pemberitahuan segera saat dokter hewan membalas"

**TC-22D-09 — Push permission requested after first profile creation (never-consulted users only)**
- Given a user has never completed a consultation and just finished pet profile creation (FR-0G)
- When creation completes
- Then the push permission prompt appears immediately with copy "Aktifkan notifikasi untuk segera menerima pengingat ulang tahun dan hari jadi kebersamaan [Nama Hewan]", and the user confirms the prompt before landing on the home feed

**TC-22D-10 — Only the earliest-met trigger fires, and only once**
- Given a user both completes a consultation and creates a profile in their first session
- When the earlier of the two events occurs
- Then the push permission prompt fires at that point only, not a second time for the later event

**TC-22D-11 — Prompt never reappears once both triggers have passed or permission is granted**
- Given the user has already encountered the push permission prompt (granted or not) via either trigger
- When further trigger conditions are met later
- Then the system prompt does not appear again

**TC-22D-12 — Denial does not cause proactive re-prompting**
- Given the user denies the system push permission prompt
- When they continue using the app
- Then the app does not proactively re-trigger the system-level permission dialog again

**TC-22D-13 — "Saya" page offers a manual path to enable permission**
- Given the user previously denied push permission
- When they look in the "Saya" page/settings
- Then guidance is available directing them to manually enable notifications via system settings

---

## §4.8 Content Interaction (Likes & Comments)

### FR-23 — Content likes

**TC-23-01 — All three content types support liking**
- Given content of any of the three types (daily share, educational, growth-calendar happy moment)
- When the user views it in the Feed
- Then a like action is available on all of them

**TC-23-02 — Like is a toggle and can be undone**
- Given the user has liked a piece of content
- When they tap the like button again
- Then the like is removed (unlike)

**TC-23-03 — Like count updates immediately and only shows on the detail page**
- Given the user likes or unlikes content
- When the action registers
- Then the like count updates immediately on the FR-28 detail page, while the Feed card itself never displays a like count (consistent with FR-17)

**TC-23-04 — Liking requires login**
- Given the user is logged out
- When they tap the like button
- Then the FR-0C login prompt is triggered instead of registering a like

**TC-23-05 — Liking notifies the content author, except self-likes**
- Given a different user likes the current user's content
- When the like registers
- Then the FR-22B push notification is sent to the author; if the author likes their own content, no notification is sent

---

### FR-24 — Content comments (two-level structure)

**TC-24-01 — Any logged-in user can post a top-level comment**
- Given the user is logged in and viewing content
- When they submit a top-level comment
- Then it is accepted

**TC-24-02 — Top-level comment has a 200-character limit**
- Given the user is composing a top-level comment
- When they type beyond 200 characters
- Then further input is blocked or rejected

**TC-24-03 — Top-level comments appear immediately, sorted chronologically ascending**
- Given the user submits a valid top-level comment
- When it posts
- Then it appears immediately in the comment list, ordered oldest-first

**TC-24-04 — Posting a top-level comment notifies the content author**
- Given a user posts a top-level comment on someone else's content
- When it posts
- Then the FR-22B push notification is sent to the content author

**TC-24-05 — Second-level comments (replies) appear nested under their parent**
- Given the user replies to a top-level comment
- When the reply posts
- Then it appears displayed beneath that specific top-level comment

**TC-24-06 — Second-level comment has the same 200-character limit**
- Given the user is composing a reply
- When they type beyond 200 characters
- Then further input is blocked or rejected

**TC-24-07 — No further nesting beyond two levels**
- Given a second-level reply exists
- When the user attempts to reply to that reply
- Then it is added as another second-level reply under the same top-level comment, not as a third nested level

**TC-24-08 — Replying notifies the comment author being replied to**
- Given a user replies to another user's comment
- When the reply posts
- Then the FR-22B push notification is sent to the author of the comment being replied to

**TC-24-09 — Users can delete their own comments at any level**
- Given the user authored a top-level or second-level comment
- When they use the delete option on it
- Then it is removed

**TC-24-10 — Content authors can delete any comment on their own content**
- Given the user is the author of a piece of content
- When they delete any comment under it (regardless of who wrote it)
- Then it is removed

**TC-24-11 — Deleting a top-level comment cascades to its replies**
- Given a top-level comment has one or more second-level replies
- When it is deleted
- Then all of its replies are deleted along with it

**TC-24-12 — Comment count shown only on the detail page, not the Feed card**
- Given content has comments
- When the user views the Feed card versus the detail page
- Then the comment count appears only in the FR-28 interaction bar on the detail page, never on the Feed card (consistent with FR-17)

**TC-24-13 — Commenting requires login**
- Given the user is logged out
- When they attempt to comment
- Then the FR-0C login prompt is triggered

**TC-24-14 — Comments cannot be liked in V1.0.0**
- Given the user views any comment
- When they look for a like action on it
- Then none is present

**TC-24-15 — Failed comment submission preserves the draft**
- Given the user submits a comment and a network/server error occurs
- When the failure registers
- Then "Gagal mengirim, silakan coba lagi" is shown, and the input box retains the typed content so the user can retry without retyping

---

### FR-36 — Content deletion (no editing)

**TC-36-01 — Delete entry is available only to the content's author**
- Given the user views the "···" menu on a piece of content
- When the content is theirs
- Then a "Hapus" option is present; for other users' content, this option does not appear

**TC-36-02 — Deletion requires confirmation**
- Given the author taps "Hapus"
- When the confirmation modal appears
- Then it reads "Setelah dihapus, konten akan dihilangkan secara permanen dan tidak dapat dipulihkan"

**TC-36-03 — Deletion removes content from Feed and archive timeline**
- Given the author confirms deletion of a growth-calendar post
- When the deletion processes
- Then it is removed from both the Feed and the pet's growth-archive timeline simultaneously

**TC-36-04 — Deletion cascades to likes and comments**
- Given the deleted content had likes and comments from other users
- When the deletion processes
- Then all associated like and comment data is deleted along with it

**TC-36-05 — No editing exists; users must delete and republish**
- Given the user wants to change published content
- When they look for an edit option
- Then none exists anywhere in V1.0.0; the only path is to delete the post and publish a new one

---

## §4.9 Content Detail Page

### FR-28 — Content detail page structure

**TC-28-01 — Top nav shows back button and contextual "···" menu**
- Given the user opens any content detail page
- When they view the top bar
- Then the left shows a back button, and the right shows a "···" menu containing a report entry (FR-25) for others' content, or a delete entry (FR-36) for their own content (report is replaced by delete for own content)

**TC-28-02 — Author info is shown and tappable**
- Given the user views the detail page
- When they look below the top bar
- Then the author's avatar and nickname are shown, and tapping them opens the FR-26 mini profile preview card

**TC-28-03 — Full text content is displayed**
- Given a post with text content
- When the detail page renders
- Then the complete, untruncated text is shown (unlike the 2-line Feed preview)

**TC-28-04 — Multiple images are swipeable**
- Given a post has more than one image
- When the user views the media area
- Then they can swipe left/right between images, with a page indicator (e.g., "2/5") showing current position

**TC-28-05 — No community video display in V1.0.0**
- Given the user views any content detail page
- When they look for video playback
- Then none is present (video publishing is not supported in V1.0.0)

**TC-28-06 — Interaction bar shows like button/count and comment count**
- Given the user views the detail page
- When they look at the interaction bar
- Then it shows the like button with count, and the comment count

**TC-28-07 — Tapping the comment count jumps to the comment section**
- Given the user taps the comment count
- When the tap registers
- Then the view scrolls/jumps to the comment section

**TC-28-08 — Returning to Feed preserves scroll position**
- Given the user opened the detail page from a specific scroll position in the Feed
- When they tap the back button
- Then they return to the Feed at the same scroll position, not reset to the top

**TC-28-09 — Comment input is fixed at the bottom**
- Given the user views the detail page
- When they scroll
- Then the comment input box remains fixed at the bottom of the screen

**TC-28-10 — Tapping the comment input while logged out triggers login**
- Given the user is logged out
- When they tap the comment input box
- Then the FR-0C login prompt is triggered

**TC-28-11 — First 10 top-level comments load initially**
- Given a post has more than 10 top-level comments
- When the detail page loads
- Then only the first 10 are shown initially, with a "Lihat komentar lainnya" button to load 10 more at a time

**TC-28-12 — Second-level replies show first 3 with an expand option**
- Given a top-level comment has more than 3 replies
- When it renders
- Then only the first 3 replies are shown by default, with a "Lihat semua X balasan" link to expand the rest

**TC-28-13 — Empty comment section shows a guidance prompt**
- Given a post has zero comments
- When the user views the comment section
- Then it shows "Yuk, tulis sesuatu", and tapping that text focuses the comment input box directly

---

## §4.10 Content Reporting and Moderation

### FR-25 — Content reporting

**TC-25-01 — Report entry lives in the "···" menu, not on the main card**
- Given the user views a Feed content card
- When they look for a report option
- Then it is accessible only via the "···" menu, not taking up space on the main card UI

**TC-25-02 — Report type is a single-select from five options**
- Given the user opens the report flow
- When they view the type options
- Then they see: "Melanggar Hukum/Aturan" / "Informasi Palsu" / "Konten Tidak Pantas" / "Pelecehan" / "Lainnya", selectable as a single choice

**TC-25-03 — Submission shows an acknowledgment, not a resolution**
- Given the user submits a report
- When submission completes
- Then they see "Laporanmu telah kami terima, akan segera kami proses"; the eventual review outcome is never communicated back to them

**TC-25-04 — Report enters the operations review queue**
- Given a report is submitted
- When it is processed
- Then it is routed into the operations team's manual review queue

**TC-25-05 — Confirmed violation removes the content everywhere**
- Given operations determines the reported content violates guidelines
- When the decision is applied
- Then the content is removed from the Feed, "Postingan Saya", and (if applicable) the growth-archive timeline simultaneously

**TC-25-06 — Author is notified of removal without naming the reporter**
- Given content is removed per TC-25-05
- When the author checks their notifications
- Then they see "Kontenmu telah dihapus karena melanggar pedoman komunitas", with no mention of who reported it

**TC-25-07 — No appeal entry exists**
- Given the author's content was removed
- When they look for a way to appeal the decision
- Then no appeal mechanism exists anywhere in V1.0.0

**TC-25-08 — No violation found results in silent retention**
- Given operations reviews a report and finds no violation
- When the decision is applied
- Then the content remains untouched and neither the reporter nor the author receives any notification

**TC-25-09 — No comment-reporting feature exists**
- Given the user views any comment
- When they look for a way to report it specifically
- Then no such option exists (only whole-content reporting is supported)

**TC-25-10 — No user-account-reporting feature exists**
- Given the user views another user's profile/mini card
- When they look for a way to report the account itself
- Then no such option exists

---

## §4.11 Other Users' Avatar Tap (Mini Profile Preview Card)

### FR-26 — Mini profile preview card

**TC-26-01 — Tapping another user's avatar/nickname opens a bottom-sheet card**
- Given the user is viewing Feed content authored by someone else
- When they tap that author's avatar or nickname
- Then a card slides up from the bottom of the screen

**TC-26-02 — Card shows avatar and nickname**
- Given the mini card is open
- When the user views it
- Then it displays that user's avatar and nickname

**TC-26-03 — Card shows published content count**
- Given the mini card is open
- When the user views it
- Then it shows "Telah memposting X konten"

**TC-26-04 — Card shows the required placeholder copy**
- Given the mini card is open
- When the user reads its message
- Then it reads exactly "Halaman profil eksklusifnya sedang disiapkan dengan cermat, lebih banyak keseruan akan segera hadir ✨"

**TC-26-05 — Card can be closed via outside tap or "×"**
- Given the mini card is open
- When the user taps outside it or taps the "×" in the top-right
- Then it closes

**TC-26-06 — No follow button is shown**
- Given the mini card is open
- When the user views its actions
- Then no "follow" button is present (V2 feature)

**TC-26-07 — No "view profile" button is shown**
- Given the mini card is open
- When the user views its actions
- Then no "view full profile" button is present

**TC-26-08 — Copy avoids technical/under-construction phrasing**
- Given the user reads the card's message
- When they check its wording
- Then it contains none of: "fitur sedang dikembangkan", "nantikan", "belum didukung", or equivalent technical/apologetic phrasing

**TC-26-09 — Card is a bottom sheet, not a page navigation**
- Given the user opens the mini card
- When they observe the transition
- Then it appears as an overlay bottom sheet on top of the current Feed screen, without navigating to a new page

---

## §4.12 Vet Workbench

### FR-29 — Vet account login entry

**TC-29-01 — A small "Login Dokter Hewan" link appears below the Google button**
- Given a user is on the standard login page
- When they look below the Google login button
- Then a small text link reading "Login Dokter Hewan" is visible

**TC-29-02 — Tapping it opens a separate account/password login page**
- Given the user taps "Login Dokter Hewan"
- When the tap registers
- Then a dedicated account+password login page opens, fully separate from the Google OAuth flow

**TC-29-03 — Login form has account and password fields, no forgot-password option**
- Given the vet is on the login page
- When they view the form
- Then it has account (email/username) and password fields, with no "forgot password" option (resets are handled by operations in V1.0.0)

**TC-29-04 — Successful login routes to the vet workbench**
- Given a vet enters valid credentials
- When login succeeds
- Then the system recognizes the account as a vet type and routes to the FR-30 workbench

**TC-29-05 — Vet accounts cannot access user-side features**
- Given a vet is logged in
- When they attempt to reach the regular home feed, growth archive, or other user-side features
- Then access is blocked; the vet only has access to the workbench

---

### FR-30 — Vet workbench (independent Tab Bar)

**TC-30-01 — Vet Tab Bar shows the correct 4 tabs**
- Given a vet is logged in
- When they view the bottom Tab Bar
- Then it shows, left to right: "Menunggu Diambil" | "Berlangsung" | "Riwayat" | "Saya"

**TC-30-02 — "Menunggu Diambil" lists pending requests for grab-style acceptance**
- Given new consultation requests exist
- When the vet views this tab
- Then it lists them as cards for first-come-first-served acceptance

**TC-30-03 — "Berlangsung" lists active sessions, tappable into chat**
- Given the vet has ongoing sessions
- When they view this tab
- Then each is listed, and tapping one opens its chat screen

**TC-30-04 — "Riwayat" lists ended sessions**
- Given the vet has completed past sessions
- When they view this tab
- Then those sessions are listed

**TC-30-05 — "Saya" includes online/offline toggle**
- Given the vet views their "Saya" tab
- When they look for availability controls
- Then an online/offline status toggle is present, affecting FR-4B's user-facing display

**TC-30-06 — New requests broadcast to all online, idle vets**
- Given a user submits a vet consultation request
- When it enters the queue
- Then it is pushed simultaneously to every vet who is both online and has no active session (FR-22E)

**TC-30-07 — Pending cards show a symptom summary and image preview**
- Given a vet views "Menunggu Diambil"
- When they look at a request card
- Then it shows a symptom summary and an image preview

**TC-30-08 — Opening a request starts a 3-minute preview window**
- Given the vet taps a pending request card
- When the detail page opens showing the full description and media
- Then a 3-minute preview countdown begins

**TC-30-09 — User cancellation during preview closes it for the vet**
- Given the vet is previewing a request
- When the user cancels their request during this window
- Then the vet sees "Permintaan ini telah ditutup" and returns to the pending list

**TC-30-10 — Another vet accepting first closes it for this vet**
- Given the vet is previewing a request
- When another vet accepts it first
- Then this vet sees "Permintaan ini telah diambil oleh dokter hewan lain" and returns to the pending list

**TC-30-11 — No action within 3 minutes returns to the list**
- Given the vet has been previewing a request for 3 minutes without acting
- When the timer expires
- Then they are automatically returned to the pending list, and the request remains visible to other vets

**TC-30-12 — Accepting writes atomically; first to accept wins**
- Given the vet taps "Ambil" (accept)
- When the backend processes it
- Then on success a session is created, the request disappears from all other vets' pending lists, and it moves into "Berlangsung" for the accepting vet

**TC-30-13 — Losing the accept race shows the same already-taken message**
- Given the vet taps "Ambil" at nearly the same moment as another vet
- When the backend determines another vet won the race
- Then this vet sees "Permintaan ini telah diambil oleh dokter hewan lain" and returns to the pending list

**TC-30-14 — User is notified once a vet accepts**
- Given a vet successfully accepts a user's request
- When acceptance completes
- Then the user receives the notification "Dokter hewan telah menerima konsultasimu, ketuk untuk mulai mengobrol"

**TC-30-15 — Vet can voluntarily release an accepted request**
- Given the vet has an active session in "Berlangsung"
- When they tap "Batalkan Penerimaan"
- Then a confirmation dialog appears: "Konfirmasi batalkan penerimaan? Setelah dibatalkan, permintaan akan kembali masuk ke antrean menunggu"

**TC-30-16 — Confirming release rebroadcasts the request and notifies the user**
- Given the vet confirms releasing the request
- When the action processes
- Then it is rebroadcast to all online, idle vets, and the user receives "Dokter hewan untuk sementara tidak dapat menerima, sedang mencarikan ulang untukmu", with their 1-minute matching timer reset

**TC-30-17 — Release is capped at 2 per request**
- Given a request has already been released by vets twice
- When it would be released a 3rd time
- Then it is instead flagged as anomalous on the backend for manual operations handling (rather than rebroadcasting again)

**TC-30-18 — Chat supports text and images**
- Given the vet is in an active session
- When they compose a message
- Then they can send text and/or images

**TC-30-19 — FR-5 assist tools are shown to the vet**
- Given the vet is in an active session
- When they view the chat screen
- Then the symptom history database (or AI reference reply), and disclaimer, are presented per FR-5

**TC-30-20 — Original user submission shown at the top of the chat**
- Given a session has started
- When the vet views the chat
- Then the user's original description and uploaded media are pinned at the top

---

### FR-31 — Consultation session-close mechanism (with rating confirmation gate)

**TC-31-01 — Vet-initiated close requires confirmation**
- Given the vet taps "Akhiri Sesi"
- When the tap registers
- Then a confirmation dialog appears: "Konfirmasi akhiri sesi?"

**TC-31-02 — Confirming sends the user a rating request notification**
- Given the vet confirms ending the session
- When the action processes
- Then the user receives a notification with title "Konsultasi Selesai" and body "Dokter hewan telah menyelesaikan konsultasi ini, silakan beri penilaian untuk layanan ini"

**TC-31-03 — Session enters "pending close," not immediate close**
- Given the vet has confirmed ending the session
- When the user has not yet rated
- Then the session status is "pending close," not fully closed

**TC-31-04 — User can still message during the 30-minute window**
- Given the session is in "pending close" status
- When the user sends another message within 30 minutes
- Then it is delivered and the vet is notified, with the option to keep replying

**TC-31-05 — Rating within 30 minutes closes the session immediately**
- Given the user submits a rating within 30 minutes of the close request
- When the rating is submitted
- Then the session closes immediately

**TC-31-06 — No rating within 30 minutes auto-closes as "unrated"**
- Given 30 minutes pass with no rating submitted
- When the window expires
- Then the session auto-closes and is recorded as "Belum dinilai"

**TC-31-07 — Closing triggers the save-to-archive prompt and rating re-ask**
- Given a session closes via either path
- When closure completes
- Then the FR-16 save-to-archive prompt fires, and if no rating was given, the FR-33 re-ask flow is queued

**TC-31-08 — Force-quitting mid-chat starts the same 30-minute window**
- Given the user force-quits the app during an active chat
- When the app closes
- Then the session is treated as the user having disconnected, entering the same 30-minute protected window

**TC-31-09 — Reopening the app within the window resumes the session**
- Given the user reopens the app within 30 minutes of disconnecting
- When they navigate to "Konsultasi" → "Berlangsung" (or its equivalent area)
- Then they can resume the session

**TC-31-10 — Not returning within 30 minutes auto-closes the session**
- Given the user does not reopen the app within 30 minutes of disconnecting
- When the window expires
- Then the session auto-closes

---

### FR-32 — Vet online status management

**TC-32-01 — Vet can toggle online/offline from "Saya"**
- Given the vet is on their "Saya" tab
- When they use the status toggle
- Then they can switch between online and offline

**TC-32-02 — Online vets receive new requests**
- Given a vet's status is online
- When a new consultation request is submitted
- Then they are included in the pool of vets it's broadcast to (assuming no active session)

**TC-32-03 — Offline vets do not receive new requests**
- Given a vet's status is offline
- When a new consultation request is submitted
- Then it is not broadcast to them

**TC-32-04 — Offline status reflects on the user side**
- Given all vets are currently offline
- When a user opens the vet consultation entry
- Then they see "Saat ini belum ada dokter hewan yang online"

**TC-32-05 — Status changes take effect immediately**
- Given the vet toggles their status
- When the change is saved
- Then it applies immediately to subsequent request broadcasts, with no delay

---

## §4.13 Vet Rating

### FR-33 — Post-consultation user rating

**TC-33-01 — Star rating (1–5) is mandatory**
- Given the user reaches the rating screen
- When they attempt to submit without selecting a star rating
- Then submission is blocked

**TC-33-02 — Optional text review has a 100-character limit**
- Given the user is on the rating screen
- When they enter review text beyond 100 characters
- Then further input is blocked or rejected; leaving it empty is also allowed

**TC-33-03 — Confirm button reads "Kirim Penilaian"**
- Given the user has selected a star rating
- When they view the confirm button
- Then it reads "Kirim Penilaian"

**TC-33-04 — Rating is recorded to the vet's account and visible to operations**
- Given a user submits a rating
- When operations views that vet's record in the back office
- Then the new rating appears in their historical ratings and contributes to their average score

**TC-33-05 — Ratings are not publicly shown to regular users in V1.0.0**
- Given a vet has received multiple ratings
- When a regular user looks for that vet's rating anywhere in the app
- Then no public rating display exists; ratings are visible only in the operations back office

**TC-33-06 — Timeout closes the session and queues a re-ask for next visit**
- Given the user does not rate within 30 minutes of the close request
- When the session auto-closes
- Then a one-time re-ask rating prompt is queued to appear the next time the user enters the consultation tab

**TC-33-07 — Re-ask is deferred if the user has another active session**
- Given the user has a pending re-ask rating and also has a different active consultation session
- When they enter the consultation tab
- Then the re-ask prompt is deferred until that active session ends, rather than interrupting it

**TC-33-08 — Still-unrated sessions stop being asked and are recorded accordingly**
- Given the user dismisses or ignores the re-ask prompt without rating
- When they continue using the app
- Then that specific consultation is not asked again and remains recorded as "Belum dinilai"

**TC-33-09 — Vet's history tab shows the user's rating per session**
- Given a vet views their "Riwayat" tab
- When they open a past session's record
- Then the user's rating for that session is visible (if one was given)

---

## §4.14 Notification Center & Consultation History

### FR-38 — Push notification deep-link rules

**TC-38-01 — Vet reply push opens the matching session**
- Given the user taps a vet-reply push notification
- When the app opens
- Then it navigates to "Konsultasi" tab → that specific ongoing session, not just the home feed

**TC-38-02 — Consultation-ended push opens the rating modal**
- Given the user taps the consultation-ended push
- When the app opens
- Then it navigates to "Konsultasi" tab and shows the FR-33 rating modal

**TC-38-03 — Like push opens the content detail page**
- Given the user taps a like-notification push
- When the app opens
- Then it navigates to the FR-28 detail page for that specific content

**TC-38-04 — Comment push opens the detail page scrolled to comments**
- Given the user taps a comment-notification push
- When the app opens
- Then it navigates to the FR-28 detail page and scrolls/jumps to the comment section

**TC-38-05 — Birthday reminder push opens the pre-selected publish entry**
- Given the user taps the birthday reminder push
- When the app opens
- Then it navigates to the unified "+" publish entry with growth-calendar type pre-selected

**TC-38-06 — Anniversary reminder push opens the Growth Archive tab**
- Given the user taps the companionship anniversary push
- When the app opens
- Then it navigates to the Growth Archive tab

**TC-38-07 — L-tier milestone push opens the milestone list**
- Given the user taps an L-tier milestone push
- When the app opens
- Then it navigates to the Growth Archive tab → milestone list page

**TC-38-08 — Cold start from a notification skips the home feed**
- Given the app is not running
- When the user taps any push notification
- Then it cold-starts directly into the target page per the table above, without passing through the home feed first

**TC-38-09 — Background-to-foreground from a notification jumps directly**
- Given the app is running in the background
- When the user taps a push notification
- Then the app foregrounds and navigates directly to the target page

**TC-38-10 — Foreground notifications appear as a banner**
- Given the app is already open and in the foreground
- When a push notification arrives
- Then it displays as an in-app banner; tapping the banner navigates to the target page

---

### FR-34 — Global notification center (bell icon)

**TC-34-01 — Bell icon is positioned top-right of the home nav bar**
- Given the user views the home feed
- When they look at the top navigation bar
- Then the notification bell icon is on the right side

**TC-34-02 — Unread notifications show a red count badge**
- Given the user has unread notifications
- When they view the bell icon
- Then a red numeric badge is shown

**TC-34-03 — Tapping the bell opens the notification list, newest first**
- Given the user taps the bell icon
- When the list opens
- Then all notifications are shown in reverse chronological order

**TC-34-04 — Tapping a notification item marks it as read**
- Given the user taps any item in the notification list
- When the tap registers
- Then that item's unread state clears

**TC-34-05 — Acting on a system push also marks the matching in-app item read**
- Given the user taps a system push notification and is routed to its target page
- When they later open the notification center
- Then the corresponding entry is already marked as read

**TC-34-06 — Vet reply entry matches the consolidated copy**
- Given a vet-reply notification exists in the list
- When the user views it
- Then it shows title "Balasan Dokter Hewan" and body "Konsultasi hewan peliharaanmu mendapat balasan baru, ketuk untuk melihat"

**TC-34-07 — All seven notification types render with their defined title/body**
- Given notifications of every type defined in FR-22A/FR-22B/FR-31/FR-40/FR-41/FR-42 exist for the user
- When they view the notification list
- Then each renders with its exact defined title and body text (vet reply, consultation ended, liked, commented, birthday, anniversary, L-tier milestone), with no missing or placeholder copy

---

### FR-35 — Consultation tab structure (including history)

**TC-35-01 — Entry points section shows AI and vet entries at equal level**
- Given the user opens the "Konsultasi" tab
- When they view the top section
- Then the AI consultation entry (FR-4A) and vet consultation entry (FR-4B) are shown side by side at equal visual weight

**TC-35-02 — Active session card shown when one exists**
- Given the user has an ongoing consultation
- When they view the "Konsultasi" tab
- Then an active session card is shown, tappable into the chat

**TC-35-03 — "Riwayat Konsultasi Saya" lists all past records**
- Given the user has consultation history
- When they scroll the "Konsultasi" tab
- Then a complete list of past AI and vet consultation records is shown

**TC-35-04 — Each history entry shows date and type**
- Given the user views their consultation history
- When they look at any entry
- Then it shows the date and whether it was an AI or vet consultation

**TC-35-05 — AI entries show danger level and symptom summary**
- Given an AI consultation entry in the history
- When the user views it
- Then it shows the danger level (green/yellow/red) and a symptom summary

**TC-35-06 — Vet entries show vet nickname, summary, and user rating**
- Given a vet consultation entry in the history
- When the user views it
- Then it shows the vet's nickname, a session summary, and the rating the user gave (if any)

**TC-35-07 — Each entry indicates whether it was saved to the archive**
- Given the user views their consultation history
- When they look at any entry
- Then it indicates whether that record was saved to the pet's archive (FR-16) or not
