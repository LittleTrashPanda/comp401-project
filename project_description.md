# Critic's Notepad: A Private Restaurant & Dish Journal

## 1. Introduction

The main idea of the **Critic's Notepad** project is to develop an iOS (iPhone) application that helps people remember, in detail, what they ate, where they ate it, and how it was, so that they can return to the restaurants and dishes they loved and avoid the ones that disappointed them. The target users are people who dine out frequently, people with specific dietary requirements, and anyone with strong food preferences who wants a reliable personal record instead of a vague memory.

Most people can recall whether they "liked" a restaurant, but the details fade quickly: which dish was the good one, whether it was worth the price, whether it was better as take-out, or whether something on the menu caused problems with a dietary restriction. When the time comes to choose a place to eat, these details are exactly what matter, and they are usually gone.

Critic's Notepad is a **journal, not a review platform**. Entries are private by design. There are no followers, no likes, no public star ratings, and no audience to write for. A user records honest, quick impressions for one reader: their future self. What a user puts in is what they get out.

The application is organized around two connected records:

-   **Restaurants** --- The places a user has visited, each with a history of visits and an overall experience rating per visit (service, atmosphere, wait times, dine-in versus take-out).
-   **Dishes** --- The specific items a user ordered at a restaurant, each rated separately on **taste** and **value for money**, with optional notes, a photo, and dietary tags.

Every time a user eats out, they create a **visit log**. A visit log records the restaurant experience and one or more dish entries. Because each dish entry is tied to both a restaurant and a date, the app can build a history over time: how a restaurant's experience has changed across visits, how a favorite dish has held up, and how long it has been since the user last went somewhere they enjoyed.

Users can tag dishes with dietary information, such as **contains gluten**, **contains dairy**, or **contains nuts**, so that the restaurant's page reminds them next time which items to avoid. When several people share one phone at a meal, for example a couple who eat out together, each dish can be attributed to the person who ordered it.

Over time, the journal becomes a personal decision tool. A user deciding where to eat can filter their own history, for example "places I rated 8/10 or higher that I haven't visited in three weeks," and find an answer grounded in their own experience rather than strangers' opinions.

------------------------------------------------------------------------

## 2. Significance

Eating out is expensive and takes effort. Choosing a place, traveling there, waiting for a table, and paying for the meal all add up. When a meal is disappointing, the cost is not just the money but the evening. People therefore want to make sure they get their money's worth and avoid repeating bad experiences, yet most rely entirely on memory to do so.

Existing restaurant apps help users *discover* places through public reviews, friends' activity, and rankings. They are much less focused on helping a user *remember* their own experiences at the level of detail that guides the next order.

Critic's Notepad aims to address this gap in several ways.

First, it provides **dish-level memory**. A restaurant is rarely good or bad as a whole; one dish may be excellent while another is forgettable. Recording ratings per dish lets users know exactly what to order again and what to skip.

Second, it separates **taste from value**. A dish can taste good but be overpriced, or be ordinary but excellent for the price. Rating the two independently reflects how people actually decide what to order.

Third, it supports **honest, low-pressure logging**. Because entries are private, users do not need to write polished reviews or worry about how their opinions look to others. A score and a few words are enough. This makes it more likely that users log consistently and that their records reflect what they actually thought.

Fourth, it helps users with **dietary requirements** remember which dishes, at which restaurants, did or did not meet their needs. For someone avoiding gluten, a reminder that "the calzone here contains gluten" is far more useful than a general star rating.

Fifth, it provides **history over time**. Restaurants change: menus, chefs, and service quality shift. A record of repeated visits shows whether a place is still as good as it was, and how long it has been since a favorite was last enjoyed.

Market evidence suggests that people want to keep track of where they eat. Several apps in the Food & Drink category now position themselves around personal restaurant tracking. For example, Beli's App Store listing shows **"4.8 out of 5", "18K Ratings"**, an **Editors' Choice** award, and a **"#58 Food & Drink"** chart position, and both YUMMI ("Restaurant & Food Diary") and Crumbs ("Restaurant Journal") describe themselves as journals (all figures as shown on the US/UK App Store listings on 6 November 2026; see Section 4). However, these apps combine tracking with social sharing, friend activity, and discovery, which is the space Critic's Notepad deliberately stays out of.

The overall goal is to help users make better dining decisions using the most trustworthy source available to them: their own past experiences.

------------------------------------------------------------------------

## 3. Innovation

Critic's Notepad differentiates itself from review platforms and social food-tracking apps through four core innovations. Each is written as: what current apps do → the gap → what Critic's Notepad does → why it matters.

### 3.1 Dish-First, Two-Axis Ratings

**What current apps do:** Yelp is built around a single rating per restaurant in public reviews. Beli ranks restaurants relative to one another and lets users "add notes and favorite dishes." YUMMI logs meals from photos and lets users find a meal "by place, date or dish."

**The gap:** None of these listings describe rating individual dishes on separate dimensions. Dishes appear as notes, favorites, or photos, not as structured, comparable scores.

**What Critic's Notepad does:** Each dish entry carries its own **taste score (1--10)** and **value score (1--10)**, separate from the visit's **restaurant experience score (1--10)**. A user can record that the food was a 7 for taste and a 9 for value while the dine-in experience was only a 5.

**Why it matters:** Users decide what to *order*, not just where to go. Two-axis dish scores answer "Is this worth ordering again, and is it worth the price?" at a glance. The difference is visible within the first log a user creates.

### 3.2 Quality History and "Been a While" Rediscovery

**What current apps do:** YUMMI shows meals in a log, a calendar, and a map, and can show past visits to a place. Crumbs lets users "keep track of where you've been." Beli keeps ranked lists of places a user has been.

**The gap:** These apps record *that* a user went somewhere, but the listings do not describe tracking *how good it was each time*, or surfacing favorites the user has not returned to recently.

**What Critic's Notepad does:** Every restaurant and every dish keeps a visit-by-visit score history, with an **average score**, a **trend** across visits, and a **last visited** date. The History screen lets users filter by their own average rating and by time since last visit, for example "average 8/10 or higher, not visited in 3+ weeks."

**Why it matters:** It turns the journal from a scrapbook into a decision tool: "Where should I go tonight that I know I'll enjoy but haven't had in a while?" It also shows when a once-favorite place is slipping. This is hard for a competitor to copy quickly, because it depends on structured per-visit scores that their data models do not appear to collect.

### 3.3 Private by Design, with No Audience

**What current apps do:** Yelp is a public review platform. Beli centers on a friends' newsfeed and "Match Score." Crumbs emphasizes "see what your friends think." YUMMI is the closest: it calls itself "a food journal first" and lets users keep "Foodprints" private, but it is still built around following friends and foodies, and rewards sharing with coins.

**The gap:** Even where privacy is an option, the product is shaped around an audience: feeds, followers, and incentives to post. Users write differently when they might be read.

**What Critic's Notepad does:** There is no social layer at all: no profiles, followers, feed, likes, or public scores. Every entry is private by default and by design, and the logging flow is built for speed (a score and a few words) rather than for presentation.

**Why it matters:** Users can be blunt, brief, and honest, which makes the record more useful to them later. **Honest note:** privacy *as an option* already exists in YUMMI, so privacy alone is not a strong differentiator. It becomes defensible when combined with 3.1 and 3.2: an app with no audience can optimize every screen for personal recall and quick logging, which socially driven apps, whose growth depends on sharing, are unlikely to do.

### 3.4 Dietary Flags Tied to Dishes and Diners

**What current apps do:** Beli lets users add tags to organize and filter their lists of restaurants. Yelp lists general business attributes (not verified on the listing, see Section 11).

**The gap:** Tags describe *restaurants*, not the specific dishes a person can or cannot eat, and not *who* at the table they apply to.

**What Critic's Notepad does:** Each dish can be tagged with dietary flags (e.g., contains gluten, dairy, nuts, shellfish, meat, or a custom tag) and attributed to a **diner** (e.g., "Me," "Eliza"). A restaurant's page then shows a "Heads-up" list of flagged dishes, so the next visit starts with a reminder.

**Why it matters:** For users with dietary requirements, remembering which dish caused a problem is more important than any rating. It is a feature a user notices immediately the second time they visit a restaurant.

The primary innovation of Critic's Notepad is therefore not any single feature, but the combination of **dish-level, two-axis ratings, visit-by-visit quality history, personal dietary memory, and a private, audience-free logging experience** in one focused journal.

------------------------------------------------------------------------

## 4. Competitive Landscape

The four competitors below were provided in the idea draft. Their Sensor Tower overview pages loaded only a page title (no downloads, revenue, or rank data were readable without a rendered or logged-in session), so market signals below come from the public App Store listings, as shown on 6 November 2026. Yelp's Google Play listing could not be read; Yelp's row is based on general product knowledge and is marked as unverified.

### 4.1 Competitor Comparison

| Competitor | Target users | Key services | Monetization | Market signals (as shown) | Main strengths | Main weaknesses |
| --- | --- | --- | --- | --- | --- | --- |
| [Yelp](https://app.sensortower.com/overview/com.yelp.android?country=US) | General public looking for local businesses | Public reviews, business listings, photos, bookmarks, ordering/reservations *(unverified)* | Free; business advertising *(unverified)* | Not readable (Sensor Tower and Google Play pages did not load content) | Huge coverage of restaurants and reviews *(unverified)* | Public, audience-driven reviews; restaurant-level rating, not personal dish memory |
| [Beli](https://app.sensortower.com/overview/1478375386?country=US) | Food enthusiasts who want to rank restaurants and follow friends | Ranked lists and maps, friends' newsfeed, tags, notes and favorite dishes, Taste Profile, Match Score, recommendations | Free with in-app purchases (e.g., "Beli Supper Club - Annual $74.99", creator subscriptions "$5.79" monthly) | "4.8 out of 5", "18K Ratings"; "#58 Food & Drink"; Editors' Choice | Polished ranking, strong social graph, recommendations | Reviewers call the ranking system "tedious" and note "you cannot opt out"; ask for custom labels |
| [YUMMI](https://app.sensortower.com/overview/1056015053?country=US) | People who want a photo-based food diary | Foodprints from photos, log/calendar/map views, search by place/date/dish, Foodmarks (want-to-try), follow friends, private or public posts, Yummi coins | Free (no in-app purchases shown) | "4.2 out of 5", "98 Ratings" | Closest to a personal diary; private option; calendar and map views praised | Social features and coins still central; a reviewer noted visit dates shown incorrectly in map mode; some loading latency |
| [Crumbs](https://app.sensortower.com/overview/6786327027?country=GB) | London diners | Save places to try, track places visited, follow friends and see their ratings, meal-out recommendations | Free (no in-app purchases shown) | "5.0 out of 5", "6 Ratings" (UK); version 1.2 | Clear positioning as a restaurant journal; positive early reviews | Very new; London-focused; friend-driven; no dish-level detail shown |

### 4.2 Key Services Analysis

-   **Table stakes:** saving restaurants a user has visited, a want-to-try list, photos, search, and a map of places.
-   **Competitor differentiators:** Beli's relative ranking, Taste Profile, and Match Score; YUMMI's automatic Foodprints from photo time and location, and calendar view; Crumbs' London focus.
-   **Gaps:** structured dish-level ratings; separate taste and value scores; score history across repeat visits; dietary memory per dish; a truly audience-free logging experience. Beli reviewers' complaints about a tedious, mandatory ranking system also suggest demand for simpler, absolute scoring.

### 4.3 Feature Matrix

✓ = offered, partial = partially offered, ✗ = not offered or not shown on the listing.

| Service / innovation | Yelp* | Beli | YUMMI | Crumbs | **Critic's Notepad** |
| --- | --- | --- | --- | --- | --- |
| Log restaurants visited | partial | ✓ | ✓ | ✓ | ✓ |
| Photos of meals | ✓ | ✗ | ✓ | ✗ | ✓ |
| Want-to-try list | ✓ | ✓ | ✓ | ✓ | ✗ (open question) |
| Map of places | ✓ | ✓ | ✓ | ✗ | ✗ (future) |
| Friends' feed / following | partial | ✓ | ✓ | ✓ | ✗ (by design) |
| Recommendations | ✓ | ✓ | ✓ | ✓ | ✗ (by design) |
| **No social layer / no audience** | ✗ | ✗ | partial | ✗ | **✓** |
| **Dish-level entries** | partial | partial | ✓ | ✗ | **✓** |
| **Separate taste and value scores** | ✗ | ✗ | ✗ | ✗ | **✓** |
| **Restaurant experience scored separately from dishes** | ✗ | ✗ | ✗ | ✗ | **✓** |
| **Score history and trend per restaurant/dish** | ✗ | ✗ | ✗ | ✗ | **✓** |
| **Filter by own average score and time since last visit** | ✗ | partial | partial | ✗ | **✓** |
| **Dietary flags on specific dishes** | ✗ | partial | ✗ | ✗ | **✓** |
| **Per-dish diner attribution** | ✗ | ✗ | ✗ | ✗ | **✓** |

\*Yelp row unverified (listing not readable).

### 4.4 Positioning

Critic's Notepad does not compete on discovery, coverage, or social features, where Yelp and Beli are strong. Instead, it serves the user who already knows where they eat and wants to remember precisely what was good, what was worth the money, and what to avoid. Against YUMMI, its closest competitor, it trades photo-first sharing for structured dish scores and history, and removes the audience entirely.

------------------------------------------------------------------------

## 5. Example Visit Log

A visit log could present information in the following form.

### Sakura Sushi --- Thursday, 6 November 2026

**Restaurant experience:** 5/10\
**Visit type:** Dine-in\
**Note:** Long wait and cramped seating. Get take-out next time.

**Dish: California Roll**

-   **Taste:** 7/10
-   **Value:** 9/10
-   **Ordered by:** Me
-   **Dietary tags:** Contains shellfish
-   **Would order again:** Yes
-   **Note:** Generous portion for the price. Compare with Tokyo House.
-   **Photo:** attached

**Restaurant summary (shown on the restaurant's page):**

-   **Visits:** 1
-   **Average experience:** 5.0/10
-   **Last visited:** Today
-   **Best dish so far:** California Roll (taste 7, value 9)
-   **Heads-up:** none

**Dish comparison (shown on the dish's page):**

| Restaurant | Taste | Value | Last ordered |
| --- | --- | --- | --- |
| Tokyo House | 8 | 6 | 12 Oct 2026 |
| Sakura Sushi | 7 | 9 | 6 Nov 2026 |

------------------------------------------------------------------------

## 6. MVPs

The application is built in four sequential MVPs. Each MVP is usable on its own, and each later MVP deepens a differentiator or adds a new one.

### MVP1: Private Dish & Restaurant Log

**Uniqueness highlight:** *Dish-First, Two-Axis Ratings (3.1) and Private by Design (3.3).* From the first log, a user rates the restaurant experience and each dish's taste and value separately, in a private journal with no audience, which no listed competitor offers.

**Goal:** A user can log a restaurant visit with one or more dishes in under a minute, and later look back at any restaurant or dish to see what they thought.

**Main screens**

-   **Journal (Home):** a reverse-chronological list of visit logs. Each row shows the restaurant name, date, experience score, and a thumbnail of the first dish photo. A prominent "New Log" button.
-   **New Visit flow:** a short, step-by-step sheet:
    1.  *Choose restaurant:* search the user's existing restaurants, or add a new one (name required; area/address optional).
    2.  *Visit details:* date (defaults to today), dine-in or take-out, restaurant experience score (1--10 slider or number picker), optional note.
    3.  *Add dishes:* add one or more dish entries (see below), then "Save Log."
-   **Add Dish sheet:** dish name (with suggestions from dishes already logged at this restaurant), taste score (1--10), value score (1--10), "Would order again" toggle, optional note, optional photo (camera or photo library).
-   **Restaurant Detail:** name and area, number of visits, average experience score, last visited date, list of visits, and a list of all dishes ever logged here with their latest taste and value scores.
-   **Dish Detail:** dish name, restaurant, photo(s), every logged instance with date, taste, value, and note.
-   **Edit/Delete:** any visit or dish entry can be edited or deleted from its detail screen.

**Main flows**

-   *Log a meal:* Journal → New Log → choose/add restaurant → visit details → add dishes → Save → returns to Journal with the new entry at the top.
-   *Look back:* Journal → tap visit → Restaurant Detail → tap dish → Dish Detail.

**Tasks**

1.  [Differentiator] A user creates a visit log and rates the restaurant experience separately from the food, with a dine-in/take-out choice and a free-text note.
2.  [Differentiator] A user adds one or more dishes to a visit, each with its own taste score and value score.
3.  [Differentiator] A user marks a dish "Would order again" or not, so the restaurant page shows clearly what to reorder.
4.  [Differentiator] All entries are private: there is no sign-up, profile, or sharing, and the app stores data on the device.
5.  [Table stakes] A user attaches a photo to a dish entry and views it later on the Dish Detail screen.
6.  [Table stakes] A user adds a restaurant by name, with optional area or address.
7.  [Table stakes] A user browses past logs in the Journal and opens any restaurant or dish.
8.  [Table stakes] A user edits or deletes an entry.

**Representative scenario --- Max tries the new sushi place**

Max is trying out the new sushi place in town and wants to compare it with his usual restaurant. He taps "New Log," adds "Sakura Sushi" as a new restaurant, and chooses "Dine-in." He gives the restaurant experience 5/10 and notes, "Get take-out from here instead of dining in." He then adds a dish, "California Roll," rating it 7/10 for taste and 9/10 for value, and attaches a photo. Later, he opens the Dish Detail screen to look at his photo and notes alongside his earlier California Roll entries from his usual restaurant.

### MVP2: Dietary Flags and Multiple Diners

**Uniqueness highlight:** *Dietary Flags Tied to Dishes and Diners (3.4).* A user sees, before ordering, which dishes at this restaurant did not meet someone's dietary needs, which competitors' restaurant-level tags cannot show.

**Goal:** Users can record dietary information and who ordered each dish, and are reminded of problem dishes when they return.

**Main screens**

-   **Dietary Tag picker (in Add Dish sheet):** a set of preset tags (contains gluten, dairy, nuts, shellfish, egg, meat; vegetarian; vegan; spicy) plus custom tags. Each tag can be marked as a *problem for* one or more diners.
-   **Diners (in Settings):** a list of people who eat with the user (e.g., "Me," "Eliza"), each with an optional dietary profile (e.g., "Avoid gluten").
-   **Add Dish sheet (updated):** an "Ordered by" selector listing diners; defaults to "Me."
-   **Restaurant Detail (updated):** a **Heads-up** banner at the top listing dishes flagged as a problem for any diner, e.g., "Calzone --- contains gluten (Eliza)." Dish lists can be grouped by diner.
-   **New Visit flow (updated):** when the user picks a restaurant that has flagged dishes, the Heads-up banner appears immediately in the flow.

**Main flows**

-   *Flag a dish:* Add Dish → Tags → select "Contains gluten" → mark as a problem for Eliza → Save.
-   *Return visit reminder:* New Log → choose restaurant → Heads-up banner shows flagged dishes → continue logging.

**Tasks**

1.  [Differentiator] A user tags a dish with one or more dietary tags, including custom tags.
2.  [Differentiator] A user adds diners and sets a simple dietary profile for each.
3.  [Differentiator] A user records which diner ordered each dish, so two people can log separate dishes on one phone in a single visit.
4.  [Differentiator] When a user opens or starts a log for a restaurant, the app shows a Heads-up list of dishes flagged for any diner's dietary needs.
5.  [Differentiator] A user filters a restaurant's dish list by diner or by tag.

**Representative scenario --- Liam and Eliza at their usual Italian place**

Liam and Eliza go to their usual Italian restaurant but want to try new dishes. Liam enjoys his spaghetti; Eliza dislikes her calzone because it does not meet her dietary needs. On Liam's phone, they create one visit log with two dish entries: "Spaghetti," ordered by Liam, rated 8 for taste and 7 for value; and "Calzone," ordered by Eliza, rated 3 for taste, tagged "Contains gluten" and marked as a problem for Eliza. Next time they start a log at this restaurant, the Heads-up banner reminds them: "Calzone --- contains gluten (Eliza)."

### MVP3: History, Trends, and Rediscovery

**Uniqueness highlight:** *Quality History and "Been a While" Rediscovery (3.2).* A user can ask their own journal "What do I love that I haven't had lately?" and see whether a restaurant is getting better or worse, which competitors' visit lists do not provide.

**Goal:** Users can search and filter their full history by their own scores and recency, and see how restaurants and dishes have changed over time.

**Main screens**

-   **History (new tab):** a searchable list of all restaurants and dishes, with a segmented control for *Restaurants* / *Dishes*. Each row shows average score, number of visits, and "last visited X days/weeks ago."
-   **Filter sheet:** minimum average score (e.g., 8+), score type (experience, taste, value), last visited (e.g., more than 1 week, 3 weeks, 3 months ago), visit type (dine-in/take-out), dietary tag, diner, "would order again" only. Sort by average score, last visited, or number of visits.
-   **Restaurant Detail (updated):** a line chart of experience scores across visits, with each point labeled by date. A trend label: **Improving**, **Steady**, or **Slipping**, based on recent visits compared with earlier ones. The chart displays actual scores and does not smooth or assume improvement.
-   **Dish Detail (updated):** taste and value charts across instances, and a **Compare** section listing the same dish name at other restaurants (as in Section 5).
-   **Journal (updated):** an optional "Been a while" card highlighting one or two highly rated restaurants not visited recently.

**Main flows**

-   *Decide where to eat:* History → Filter → average 8+ → last visited more than 3 weeks ago → results → Restaurant Detail.
-   *Compare a dish:* Dish Detail → Compare → see the same dish at different restaurants side by side.

**Tasks**

1.  [Differentiator] A user filters restaurants or dishes by their own average score and by time since last visit.
2.  [Differentiator] A user views a restaurant's experience score across visits as a chart, with a trend label.
3.  [Differentiator] A user views a dish's taste and value scores over time.
4.  [Differentiator] A user compares the same dish across different restaurants.
5.  [Differentiator] The Journal surfaces a "Been a while" suggestion of a highly rated place not visited recently.
6.  [Table stakes] A user searches history by restaurant name, dish name, or note text.
7.  [Table stakes] A user sorts results by score, recency, or number of visits.

**Representative scenario --- Grace chooses dinner**

Grace is debating what to have for dinner. She wants something she hasn't had in a while but knows she will enjoy. She opens History, taps Filter, sets "average 8/10 or higher" and "last visited more than 3 weeks ago," and sees that the local steakhouse, which averages 8.6 across five visits, was last visited three weeks ago. She opens its page, checks that its trend label reads "Steady," notes which steak she rated highest, and decides to go.

### MVP4: Backup, Export, and Opt-In Insights

**Uniqueness highlight:** *Private by Design (3.3), extended to data ownership.* The user's journal is backed up and exportable, and any contribution to restaurant insights is strictly opt-in, anonymous, and aggregated, the opposite of review platforms where every opinion is public.

**Goal:** Protect users' journals across devices, let them take their data with them, and introduce the planned business model without compromising privacy.

**Main screens**

-   **Settings → Backup & Sync:** turn on iCloud sync; last-synced status.
-   **Settings → Export:** export the journal as CSV or PDF, with photos optionally included.
-   **Settings → Privacy & Insights:** a clear explanation of what anonymous, aggregated data would be shared with restaurants (e.g., dish popularity, how well dietary needs are met, general sentiment), what is never shared (notes, photos, identity, exact visit times), and an opt-in toggle that is off by default.

**Tasks**

1.  [Table stakes] A user enables iCloud sync so their journal is available on a new iPhone.
2.  [Table stakes] A user exports their journal for personal backup.
3.  [Differentiator] A user reads a plain-language privacy explanation and chooses whether to contribute anonymous, aggregated data.
4.  [Differentiator] A user can turn contribution off at any time, and the app confirms that no further data will be shared.

*Restaurant-facing analytics (the dashboard restaurant owners would buy) is a separate product and is out of scope for these MVPs.*

------------------------------------------------------------------------

## 7. Restaurant and Dish History

When users open a restaurant, they can view a summary such as:

### Bella Italia

-   **Visits:** 6
-   **Last visited:** 3 weeks ago
-   **Average experience:** 7.8/10
-   **Recent experience scores:** 8 → 9 → 7 → 8 → 7 → 8
-   **Trend:** Steady
-   **Best dishes:** Spaghetti Carbonara (taste 8.5, value 7.0), Tiramisu (taste 9.0, value 8.0)
-   **Heads-up:** Calzone --- contains gluten (Eliza)

A chart displays experience scores across visits. The application should not assume that quality always improves or always stays the same: if a user's scores are 9, 8, 6, 5, the chart should show them faithfully, and the trend label should read "Slipping."

Restaurant experience, dish taste, and dish value should be tracked separately, because together they provide a more useful picture than a single overall score. A restaurant with a poor dining room but excellent food is a good take-out choice; a restaurant with great service but poor value is a special-occasion choice.

Users should be able to see:

-   Number of visits
-   Date of the most recent visit
-   Average and recent experience scores
-   Experience trend
-   Best-rated and "would order again" dishes
-   Dishes flagged for dietary needs

------------------------------------------------------------------------

## 8. Recommended Usage Model

Critic's Notepad's core loop can be summarized as:

**Eat → Log → Rate (experience, taste, value) → Flag → Look Back → Decide → Return or Avoid**

The MVPs focus on making each step quick and private. An important design principle is that **logging must be fast**. If recording a meal feels like writing a review, users will stop doing it. Scores and toggles should carry most of the information; notes and photos remain optional.

------------------------------------------------------------------------

## 9. MVP Scope and Development Priorities

| Feature | Development Phase |
| --- | --- |
| Visit logs with restaurant experience score | MVP1 |
| Dine-in / take-out and visit notes | MVP1 |
| Dish entries with separate taste and value scores | MVP1 |
| "Would order again" toggle | MVP1 |
| Dish photos | MVP1 |
| Restaurant and Dish detail screens | MVP1 |
| Private, on-device storage with no account | MVP1 |
| Edit and delete entries | MVP1 |
| Dietary tags (preset and custom) on dishes | MVP2 |
| Diners and per-dish attribution | MVP2 |
| Dietary profiles per diner | MVP2 |
| Heads-up banner for flagged dishes | MVP2 |
| History tab with search | MVP3 |
| Filter by own average score and time since last visit | MVP3 |
| Score charts and trend labels | MVP3 |
| Dish comparison across restaurants | MVP3 |
| "Been a while" suggestions | MVP3 |
| iCloud sync and export | MVP4 |
| Opt-in anonymous, aggregated insights | MVP4 |
| Restaurant search via Apple Maps | Future |
| Map of visited restaurants | Future |
| Want-to-try list | Future |
| Restaurant-facing analytics dashboard | Future (separate product) |

For the first version, restaurants can be entered manually by name. This avoids depending on an external places service, keeps the app fully private, and makes logging behavior predictable and easy to test.

------------------------------------------------------------------------

## 10. Conclusion

Critic's Notepad aims to help people who eat out remember precisely what was good, what was worth the money, and what to avoid, through a private journal built around dish-level, two-axis ratings, dietary memory, and a history of every visit.

The central objective of the MVPs is to demonstrate a complete personal loop:

**log a meal quickly and honestly, rate the experience and each dish separately, flag dietary problems, look back over time, and use that history to decide where to eat next.**

By choosing **memory over discovery** and **privacy over audience**, Critic's Notepad occupies a space that review platforms and social food apps leave open: a trustworthy record written by, and for, a single diner.

------------------------------------------------------------------------

## 11. Assumptions & Open Questions

**App name**

-   The draft's working name, **Critic's Notepad**, is used throughout. Because it is a working name, alternatives to consider:
    -   **Forkbook** --- short and food-related; suggests a personal notebook of meals.
    -   **Second Helping** --- captures the core value: knowing what is worth going back for.
    -   **Plate Notes** --- plain and descriptive; emphasizes dish-level notes rather than reviews.
-   "Critic" may suggest public reviewing, which conflicts slightly with the "journal, not review" positioning.

**Assumptions made to fill gaps**

-   Rating scale is 1--10 for all scores, based on the draft's examples.
-   Restaurants are entered manually in MVP1 (no maps or places lookup).
-   Data is stored on the device with no account in MVP1; iCloud sync arrives in MVP4.
-   "Diners" (people sharing a phone at a meal) was inferred from the Liam and Eliza scenario.
-   The trend labels (Improving / Steady / Slipping) and "Been a while" suggestions are added to support the draft's "history of experiences, tracking overall quality" point.
-   Dish comparison across restaurants was inferred from Max wanting to "compare the food to his usual restaurant."

**Decisions still needed**

-   **Monetization versus privacy (contradiction):** the draft says the app is "private by design" but also plans to sell anonymous analytical data to restaurant owners. These can coexist only with strict opt-in, aggregation, and clear disclosure (as in MVP4), and only once the user base is large enough for aggregation to be meaningful. Selling user-derived data, even anonymously, may undermine trust in a privacy-first product. Consider alternatives such as a one-time paid upgrade or a small subscription for sync, export, and advanced history.
-   Is a "want-to-try" list in scope? Every competitor offers one; the draft does not mention it.
-   Should restaurants be selectable from Apple Maps search to reduce typing and duplicate entries?
-   Should diners have their own score views (e.g., "Eliza's favorites")?

**Unclear parts of the draft**

-   "No pressure for quality of reviews" is interpreted as a fast, minimal logging flow with optional notes.
-   The draft rates Max's California Roll on taste and value but gives only one score to the restaurant; it is assumed that the restaurant score is the visit's experience score.

**Competitor research limitations**

-   All four Sensor Tower pages returned only a page title; download, revenue, rank, and trend data could not be read without a rendered or logged-in session. No Sensor Tower figures are reported.
-   Market signals were taken instead from public App Store listings for Beli, YUMMI, and Crumbs (as shown on 6 November 2026).
-   Yelp's Google Play listing could not be read; Yelp's details in Section 4 are based on general product knowledge and are unverified.
-   Competitor-inspired additions beyond the draft: photos (implied by the draft), search, sort, iCloud sync, and export (table stakes). Map view and want-to-try list are listed as Future only.

**Innovation points that overlap with existing apps**

-   **"Private, not social":** YUMMI already offers private entries and calls itself "a food journal first." Sharpen this by removing the social layer entirely and by making privacy visible in the product (no account required, on-device storage, opt-in-only insights).
-   **"History of experiences":** YUMMI and Crumbs already track places visited. Sharpen this by tracking *scores* per visit, showing trends, and filtering by personal average and recency.
-   **"Tracking and ratings for specific dishes":** YUMMI logs dishes and Beli allows favorite dishes. Sharpen this by keeping separate taste and value scores and comparing the same dish across restaurants.
