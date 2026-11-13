# Chef's Journal — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan phase-by-phase. Track progress with the checkbox (`- [ ]`) items under each phase's Definition of Done.

**Goal:** Build a native iPhone app for a private restaurant and dish journal. Users log visits, rate each dish on taste and value separately from the restaurant experience, flag dietary problems per diner, and use their own history to decide where to eat.

**Architecture:** SwiftUI + SwiftData, MVVM grouped by feature (see `CLAUDE.md`). Each feature has a ViewModel that is `ObservableObject` and `@MainActor`, owned by the feature's root view with `@StateObject`. ViewModels write through a `JournalStoreProtocol` service that wraps `ModelContext`. Views may read with `@Query`, which is the SwiftData exception in `CLAUDE.md` §6. All derived numbers (averages, trends, "Been a while", filters) come from pure calculators that take `Sendable` value snapshots, so they can be unit-tested without UI or a database.

**Tech Stack:** Swift 6 (strict concurrency), SwiftUI, SwiftData (CloudKit-compatible schema), Swift Charts, PhotosUI, `UIImagePickerController` (camera only, wrapped), Swift Testing, XCTest (UI tests only), `os.Logger`, String Catalog.

**Inputs:** `project_description.md` (behaviour, data and logic win) · Figma Make prototype `UYXGpMHSz4MUOOyGcx3khF` "Private Restaurant Journal App" (layout and visuals win). The Make file is a React/Vite prototype, not frame-based. Figma references below therefore cite its component names in `src/App.tsx`, its CSS classes in `src/index.css`, and `DESIGN_NOTES.md`.

**Standard verification command** (used by every phase):

```bash
xcodebuild test -project ChefsJournal.xcodeproj -scheme ChefsJournal \
  -destination 'platform=iOS Simulator,name=iPhone 17' | xcbeautify
```

Expected: `** TEST SUCCEEDED **` and zero warnings under strict concurrency. If iPhone 17 isn't installed, use any available iOS 27 simulator.

---

## 1. App Summary (from the description)

Chef's Journal (the description's working title is *Critic's Notepad*) is a **private, audience-free journal** for people who eat out often, people with dietary requirements, and people with strong food preferences. It is "a journal, not a review platform": no account, no profiles, no feed, and no public scores.

- **Visit log** = restaurant + date + dine-in/take-out + **experience score (1–10)** + optional note + one or more **dish entries**.
- **Dish entry** = name + **taste (1–10)** + **value (1–10)** + "Would order again" + optional note + optional photo. MVP2 adds **dietary tags** (each can be a *problem for* one or more diners) and **"Ordered by" diner**.
- **Restaurant page:** visit count, average experience, last visited, visits, dishes, best dishes, **Heads-up** (flagged dishes). MVP3 adds an experience **chart and trend** (Improving / Steady / Slipping).
- **Dish page:** photo, every logged instance, taste and value history, and **Compare** with the same dish name at other restaurants.
- **History:** search, plus filters on own average score, time since last visit, visit type, tag, diner and "would order again", and sorting. **"Been a while"** suggestions appear on the Journal.
- **MVP4:** iCloud sync, CSV/PDF export, and an opt-in anonymous-insights toggle (off by default).
- Core loop: **Eat → Log → Rate → Flag → Look Back → Decide → Return or Avoid.** Logging a visit must take under a minute.

## 2. Screen Inventory (from Figma Make)

| # | Screen / surface | Figma component | Purpose | States shown in Figma |
|---|---|---|---|---|
| S1 | **Tab bar**: Journal · History · Settings | `TabBar` | Root navigation | active tab |
| S2 | **Journal** (Home) | `Journal` | Reverse-chronological visits, "New Log", privacy line | populated, row without photo (initials placeholder), save-success toast, "Been a while" card, synced/unsynced privacy line |
| S3 | **New Visit, step 1**: "Where did you eat?" | `NewVisit` step 1 | Search own restaurants or add one by name | recently visited suggestions, typed-query results, "Add “X”" row |
| S4 | **New Visit, step 2**: "How was the visit?" | `NewVisit` step 2 | Date, Dine-in/Take-out, Heads-up, experience slider, note | unset score (Continue disabled), Heads-up shown for flagged restaurant |
| S5 | **New Visit, step 3**: "What did you order?" | `NewVisit` step 3 | Added dishes list, Add Dish, Save Log | no dishes (disabled reason), dish added (Edit) |
| S6 | **Add Dish** (nested sheet) | `AddDish` | Name + suggestions, Taste/Value score stack, Would order again, Ordered by, Dietary tags, photo, note | Done disabled until complete, tag selected, "tagged but no problem-for" note, photo attached/empty |
| S7 | **Confirmation alerts** | `Confirm` | Discard draft · Delete visit · Delete dish · Turn off contribution | destructive |
| S8 | **Restaurant Detail** | `RestaurantDetail` | Area, name, summary strip, Heads-up, experience history, dishes with filter chips, visit note, delete | Heads-up none, "Not enough visits yet", chips (All / diner / tag) |
| S9 | **Dish Detail** | `DishDetail` | Hero photo, name, large ScorePair, would order again, summary strip, history, Compare, note and tags, delete | insufficient history, compare table with current row highlighted |
| S10 | **History** | `History` | Search, Restaurants/Dishes segment, active filter chips, ranked results | results, "No matches" empty state |
| S11 | **Filters** sheet | `FilterSheet` | Min average, score type, last visited, visit type/tag/diner, sort, reset | — |
| S12 | **Settings** | `Settings` | Privacy card, Diners, Backup & Sync, Export, Privacy & Insights | local vs synced copy |
| S13 | **Diners** + **New Diner** mini-sheet | `Diners` | List (Me is locked), add name and dietary profile | — |
| S14 | **Backup & Sync** | `Backup` | iCloud toggle and status | off, syncing, synced |
| S15 | **Export** | `ExportScreen` | CSV/PDF, include photos, export | idle, generating, ready |
| S16 | **Privacy & Insights** | `Privacy` | May / never contributed, opt-in toggle | off, on, turn-off confirmation |

**Reusable components** (from Figma; built in `Shared/Components/`):

| Component | Figma | Notes |
|---|---|---|
| `ScorePairView` | `ScorePair` / `.score-pair` | Cobalt two-column Taste \| Value block, regular and `large` sizes. This is the design's "signature" |
| `ExperienceStampView` | `Experience` / `.experience` | Tomato circular stamp in regular (82 pt) and `compact` (55 pt) sizes |
| `TrendBadgeView` | `Trend` | ↗ Improving (green), → Steady (grey), ↘ Slipping (tomato) |
| `ScoreSliderView` | `ScoreInput` | 0–10 slider where 0 means **Unset** ("—"). The value is shown in serif |
| `HeadsUpBannerView` | `.heads-up` / `.heads-up.none` | Warning (tomato-soft) and none (green-soft) variants |
| `SummaryStripView` | `.summary-strip` | Three columns: value + caption |
| `ChipView` | `.tag`, `.filter-scroll`, `.active-chips` | Selectable, static and removable (×) variants |
| `SuccessToastView` | `.success-toast` | Auto-dismisses after 2.6 s |
| `PhotoThumbnailView` | `.visit-row img`, `.photo-placeholder`, `.dish-row img` | Circle, arched (34/12 radius), or initials placeholder |
| `EmptyStateView` | `.empty-state` | Icon, serif title, helper text |
| `PrimaryButtonStyle`, `OutlineButtonStyle`, `NewLogButtonStyle` | `.primary`, `.outline-action`, `.new-log` | The New Log button has a 4 pt solid cobalt "pressed" offset shadow |
| `ScoreChartView` | `Chart` (defined but not placed on any screen) | Line of actual scores, labelled points, 0/5/10 grid |

**Icons:** map the prototype's inline SVGs to SF Symbols. Do not import SVGs. `book` → `book.closed`, `clock` → `clock`, `gear` → `gearshape`, `plus` → `plus`, `search` → `magnifyingglass`, `chevron` → `chevron.right`, `check` → `checkmark`, `filter` → `line.3.horizontal.decrease`, `cloud` → `icloud`, `export` → `square.and.arrow.down`, `lock` → `lock`, `people` → `person.2`, `camera` → `camera`, `alert` → `exclamationmark.triangle`, `trash` → `trash`.

**Images:** the prototype uses one Unsplash sushi photo as sample data, and the Make file bundles two PNGs. **The app ships no static imagery.** Dish photos are user content. A sample photo may go in `Preview Content` for `#Preview`s only.

## 3. Design Tokens (set up in Phase 1)

Source: `src/index.css` `:root` and its `prefers-color-scheme: dark` block, plus the `DESIGN_NOTES.md` token table. Implement colours as **Asset Catalog colour sets** with Any/Dark appearances, exposed through `Shared/Constants/DesignTokens.swift`.

| Token (`Color.journal…`) | Light | Dark | Role |
|---|---|---|---|
| `paper` | `#FAF7EF` | `#181A1F` | screen background ("Porcelain") |
| `surface` | `#FFFDF8` | `#22242A` | grouped settings, fields |
| `ink` | `#10183F` | `#F6F1E7` | primary text, Been-a-while card |
| `muted` | `#6F6C66` | `#AAA69F` | secondary text |
| `rule` | `#D7D0C4` | `#3C3D42` | dividers, field borders |
| `cobalt` | `#1959DC` | `#6E9BFF` | actions, Taste/Value, selected |
| `cobaltSoft` | `#EEF3FF` | `#202C45` | score stack, selected chip fill |
| `tomato` | `#C84C38` | `#F0806C` | Experience, caution, destructive |
| `tomatoSoft` | `#FFF0EB` | `#3A2522` | Heads-up background |
| `success` | `#237A48` | `#6BC58D` | Would order again, Improving, synced |
| `gold` | `#F2C94C` | `#F2C94C` | Been-a-while eyebrow and ring, owner avatar |

**Typography:** use Dynamic Type only, with no fixed sizes (`CLAUDE.md` §14). The prototype's Georgia/New York maps to `.fontDesign(.serif)`. The prototype's px sizes map to text styles:

| Use | Figma px | SwiftUI |
|---|---|---|
| Journal title | 35 serif | `.largeTitle` serif |
| Restaurant/dish title, sheet step title, page title | 29–34 serif | `.title` serif |
| Card title (Been a while) | 22 serif | `.title2` serif |
| Section heading | 18 bold | `.headline` |
| Row name (restaurant, dish) | 17–19 serif | `.body` serif, semibold |
| Body, controls | 15–16 | `.body` / `.callout` |
| Support, captions, eyebrow | 9–13 | `.footnote` / `.caption` / `.caption2` (eyebrow: uppercase, `tracking` 1.4) |
| Score numerals | 19–34 serif | `.title3`…`.largeTitle` serif, `monospacedDigit()` |

**Spacing** (`Spacing`): `xxs 3`, `xs 7`, `s 11`, `m 16`, `gutter 20`, `section 24`. **Corner radius** (`Radius`): `small 10` (fields, score pair), `medium 16` (Heads-up, grouped surfaces, search field), `large 24` (primary buttons, sheets). **Minimum tap target:** 44 pt.

---

## 4. Reconciliation: Mismatches and Open Questions

### 4.1 In the description but not (fully) in Figma

| Item | Description | Figma | Plan decision (my call unless answered) |
|---|---|---|---|
| Restaurant area/address input | Optional at creation | "Area or address can be added next", but no field exists | Optional **Area** text field at the top of step 2, shown only for a newly added restaurant |
| Editable visit date | "Date (defaults to today)" | Static "Today" row | Compact `DatePicker`, no future dates |
| Edit visit / edit dish | Required (MVP1 task 8) | "Edit" buttons only open delete alerts | Reuse New Visit (starting at step 2) and Add Dish sheets in **edit mode**, prefilled |
| Journal first-run empty state | Implied | Listed as "not fully simulated" | `EmptyStateView` with a New Log prompt |
| Preset tags egg, meat, vegan | 9 presets | Only 6 chips (gluten, dairy, nuts, shellfish, vegetarian, spicy) | Ship all 9 description presets plus custom |
| Custom tags | Required | No input UI | "+ Custom" chip opens a text-field alert |
| Marking a tag as a "problem for" a diner | Core MVP2 rule | Only the explanatory note; no control | Per selected tag, a "Problem for" menu that multi-selects diners, shown under the tag chips |
| Ordered-by picker | Diner selector, default "Me" | Static "Me ›" row | `Picker` (menu style) over diners |
| Restaurant dish list grouped by diner | "can be grouped by diner" | Filter chips only | Chips (All / each diner / each tag) only; grouping deferred (YAGNI) |
| Restaurant "Best dishes" summary | §5, §7 | Dish list sorted "Best first" | Sort the dish list by best (see 4.3 Q6); no separate block |
| Experience chart and dish taste/value charts | MVP3 | `Chart` component exists but only the "Not enough visits" state is placed | `ScoreChartView` (Swift Charts) with ≥ 2 visits, trend label with ≥ 3 |
| History "Dishes" segment row | Required | Segment exists; only restaurant rows designed | Reuse `history-row` layout with a dish name and restaurant subtitle, showing avg taste/value |
| Filter sub-pickers (visit type, tag, diner) | Required | "Any ›" rows lead nowhere | Pushed selection lists inside the filter sheet's `NavigationStack` |
| "Would order again only" filter | Required | Missing | Toggle row in Filters |
| Multiple photos per dish | "photo(s)" on Dish Detail | One photo per entry | One photo per **entry**. Dish Detail shows a photo per instance (hero = latest) |

### 4.2 In Figma but not in the description

| Item | Figma | Plan |
|---|---|---|
| Discard-draft confirmation when cancelling New Visit | `Confirm "Discard this draft?"` | Implement (only when the draft has content) |
| Save-success toast "Visit saved to your journal" | `.success-toast` | Implement |
| "Unset" score state (slider 0) | `ScoreInput` | Implement; 0 is never persisted. Valid saved range is 1–10 |
| Deleting a restaurant's only visit also removes the restaurant | Delete-visit alert copy | Implement as a store rule |
| "Me" diner can't be deleted | Diners row | Implement; seeded on first launch |
| Diner profiles only *suggest* problem-for, never auto-add | New Diner helper copy | Implement as a suggestion hint, not auto-flagging |
| Ranked numbering in History results | `.rank` | Implement |
| Dark appearance | CSS dark tokens | Implement via colour sets |
| Export via the iOS save-to-Files sheet | Export copy | `.fileExporter` |
| Design assumptions A1–A8 (`DESIGN_NOTES.md`) | Trend halves ±0.5 with < 3 visits insufficient; Been-a-while = avg ≥ 8 and ≥ 3 weeks; Compare is case-insensitive; restaurant taste/value filters use dish averages; dishes need name+taste+value | Adopted as the rules in Phases 2, 8 and 9 |

### 4.3 Conflicts with `CLAUDE.md`

- **Custom chrome vs Liquid Glass.** The prototype draws its own tab bar, nav header, sheet handle and status bar. `CLAUDE.md` requires system components. **Decision:** use `TabView`, `NavigationStack` toolbars, `.sheet` with `.presentationDragIndicator`, and `.alert`/`.confirmationDialog`. Apply design tokens to *content* and use `.tint(.journalCobalt)`. Do not imitate glass or blur.
- **Fixed 390 × 844 viewport.** The prototype uses a fixed viewport, but iOS 27 iPhone apps are resizable. Use adaptive layouts and check previews at small (iPhone SE) and large sizes, plus accessibility XXL Dynamic Type.

### 4.4 Open Questions (defaults applied until answered)

1. **App name.** The prompt says *Chef's Journal*. The description and Figma copy say *Critic's Notepad* (for example, the Settings footer "Critic's Notepad keeps your blunt notes…"). **Default:** the display name and all copy use "Chef's Journal".
2. **iCloud sync prerequisites.** This needs a paid Apple Developer team, an iCloud container ID and the CloudKit entitlement. Is that available? **Default:** keep the schema CloudKit-compatible from Phase 2, and build sync in Phase 10 behind the toggle. If no team is available, Phase 10 ships sync as "unavailable" with an explanation.
3. **Opt-in insights has no backend.** Nothing exists to send data to. **Default:** Phase 10 stores the preference only and transmits nothing. Copy must not claim data is being sent.
4. **Export "Include photos" with CSV.** CSV cannot hold images. **Default:** the toggle applies to PDF only and is disabled with a caption when CSV is selected.
5. **Deleting a diner who has attributed dishes.** This is not simulated in Figma. **Default:** confirm, then dishes become unattributed and their problem-for links are removed.
6. **"Best dish" ranking.** **Default:** taste descending, then value descending, then most recent. Uses the latest instance per dish name.
7. **Deleting a visit's last dish.** The Figma alert hints you could delete the whole visit instead. **Default:** "Delete Dish" proceeds and the visit remains with zero dishes. The alert also offers "Delete Visit".
8. **Duplicate restaurants.** **Default:** names match case-insensitively with trimmed whitespace. Typing an existing name selects the existing restaurant rather than creating a duplicate.
9. **"Been a while" count.** The description says "one or two"; Figma shows one card. **Default:** up to 2 cards, highest average first.
10. **Want-to-try list, Apple Maps search, map view, per-diner score views.** These are listed as open or future in the description. **Default:** out of scope.

---

## Global Constraints

- iOS **27.0+**, iPhone. Swift 6 language mode, strict concurrency. No third-party dependencies.
- Follow `CLAUDE.md` in full: feature folders, `@StateObject`/`@ObservedObject` for feature ViewModels, no `@EnvironmentObject`, no `AnyView`, `.task {}` not `.onAppear { Task {} }`, `NavigationStack` with `navigationDestination(for:)`, `os.Logger` (no `print`), no `try!`, no silent `try?`, custom `Error` enums with `LocalizedError`.
- **Scores:** integers **1–10** when saved. A slider value of 0 means "unset" and blocks saving.
- **Privacy:** no account, no networking in MVP1–3, no analytics SDKs. Never log notes, names or photos (`privacy: .private`).
- **SwiftData schema is CloudKit-compatible from day one:** every attribute has a default or is optional, every relationship is optional, and there is no `@Attribute(.unique)`.
- **User-facing strings:** all in `Resources/Localizable.xcstrings`, with no string concatenation.
- **Photos:** downsample to at most **1600 px** on the long edge and JPEG quality 0.8 before storing (`@Attribute(.externalStorage)`). Thumbnails are generated at display size.
- **Global ViewModels:** none are needed. Shared state lives in SwiftData (`@Query`) or `@AppStorage` (sync preference, insights opt-in). Add a global `@Observable` only if a later phase proves the need.
- Every view has `#Preview`s covering populated, empty and (where relevant) error states, using an in-memory `ModelContainer` from `PreviewData`.

## Review Focus

Spec-implied failure modes that no single feature test naturally covers. Each has a test assigned to the phase that owns the code.

1. **Duplicate or near-duplicate restaurant names** ("Sakura Sushi " vs "sakura sushi") must resolve to one restaurant → Phase 2 store test.
2. **Deleting the last visit** must remove the restaurant, and deleting a restaurant's visits must not orphan dishes or photos → Phase 2 store test.
3. **Accessibility Dynamic Type sizes and very long names or notes** must wrap or truncate without clipped scores or overlapping stamps → Phase 3/5 previews at `.accessibility3` with an 80-character name.
4. **A tag with no problem-for diner must not create a Heads-up.** Only tag + diner does, and deduplication happens across repeat visits → Phase 7 calculator test.
5. **Trend with few or odd-count visits:** fewer than 3 visits gives `nil` ("Not enough visits yet"), and odd counts drop the middle visit. 9, 8, 6, 5 must read **Slipping** → Phase 9 calculator test.

---

## Target File Structure

```
ChefsJournal/
├── App/ChefsJournalApp.swift, RootTabView.swift, ModelContainerFactory.swift
├── Features/
│   ├── Journal/        Views/, ViewModels/
│   ├── NewVisit/       Views/ (NewVisitSheet, ChooseRestaurantStep, VisitDetailsStep, AddDishesStep, DishEditorSheet), ViewModels/, Models/ (VisitDraft, DishDraft)
│   ├── RestaurantDetail/ Views/, ViewModels/
│   ├── DishDetail/     Views/, ViewModels/
│   ├── History/        Views/ (HistoryView, FilterSheet), ViewModels/, Models/ (HistoryFilter)
│   └── Settings/       Views/ (SettingsView, DinersView, BackupView, ExportView, PrivacyInsightsView), ViewModels/
├── Core/
│   ├── Persistence/    Models/ (Restaurant, Visit, DishEntry, Diner, DietaryFlag), JournalStore.swift, JournalStoreError.swift
│   ├── Insights/       RestaurantStatsCalculator, TrendCalculator, BeenAWhileFinder, HeadsUpCalculator, HistoryQueryEngine, DishComparison
│   └── Services/       PhotoProcessor.swift, CameraPicker.swift, JournalExporter.swift, SyncStatusMonitor.swift
├── Shared/
│   ├── Components/     (table in §2)
│   ├── Extensions/     Date+Relative.swift
│   └── Constants/      DesignTokens.swift
├── Resources/          Assets.xcassets, Localizable.xcstrings, PrivacyInfo.xcprivacy
├── Preview Content/    PreviewData.swift, sample-dish.jpg
├── ChefsJournalTests/  (mirrors Features/ and Core/)
└── ChefsJournalUITests/
```

---

## Phase 1: Project Scaffold, Design System and App Shell

**Goal:** Create a buildable app with design tokens, the shared component library, and an empty three-tab shell.

**Scope**
- Create the Xcode project `ChefsJournal` (iOS App, SwiftUI, Swift Testing, plus a UI test target). Set iOS 27.0, Swift 6, strict concurrency complete, and Display Name "Chef's Journal".
- Create the folder structure above, `Localizable.xcstrings`, and a `PrivacyInfo.xcprivacy` with no tracking and no collected data.
- Add colour sets plus `DesignTokens.swift` (`Color.journal*`, `Spacing`, `Radius`, and font helpers such as `Font.journalTitle`).
- Build the shared components from §2, except `ScoreChartView`, which moves to Phase 9. Each takes plain values (for example, `ScorePairView(taste: Int, value: Int, size: .regular | .large)`), not models.
- Add `Date+Relative.swift`: `func lastVisitedDescription(relativeTo now: Date) -> LocalizedStringResource` ("Today", "Yesterday", "3 days ago", "3 weeks ago", "2 months ago").
- Add `RootTabView` with `TabView` tabs Journal (`book.closed`), History (`clock`) and Settings (`gearshape`). Each tab holds a placeholder `NavigationStack`, and the app is tinted cobalt with a paper background.

**Figma references:** `TabBar`, `ScorePair`, `Experience`, `Trend`, `ScoreInput`, `Toggle`, `.heads-up`, `.summary-strip`, `.tag`, `.success-toast`, `.empty-state`, `.primary`, `.outline-action`, `.new-log`; the `:root` and dark tokens in `index.css`.

**Definition of Done**
- [ ] The app builds and launches to the three-tab shell in light and dark mode.
- [ ] Every shared component has `#Preview`s for all variants, at default and `.accessibility3` Dynamic Type sizes.
- [ ] No hardcoded colours, font sizes or magic numbers outside `DesignTokens.swift`.
- [ ] Tests pass.

**Verification**
- Tests in `ChefsJournalTests/Shared/DateRelativeTests.swift`, a parameterised `@Test(arguments:)`: same day → "Today", 1 day → "Yesterday", 21 days → "3 weeks ago", 62 days → "2 months ago".
- `TrendBadgeView` and `ScorePairView` expose an accessibility label such as "Taste 7 out of 10, value 9 out of 10", checked in a preview with VoiceOver in the Accessibility Inspector.
- Manual: toggle the dark appearance in the simulator, and check that the tab bar is the system (Liquid Glass) bar.

---

## Phase 2: Data Model, Journal Store and Restaurant Statistics

**Goal:** Build MVP1 persistence and the domain rules, fully unit-tested, with no new UI.

**Scope**
- SwiftData models (`Core/Persistence/Models/`), CloudKit-compatible:
  - `Restaurant { id: UUID, name: String, area: String, createdAt: Date, visits: [Visit]? (cascade) }`
  - `Visit { id: UUID, date: Date, visitTypeRaw: String (VisitType: .dineIn/.takeOut), experienceScore: Int, note: String, restaurant: Restaurant?, dishes: [DishEntry]? (cascade) }`
  - `DishEntry { id: UUID, name: String, tasteScore: Int, valueScore: Int, wouldOrderAgain: Bool, note: String, photoData: Data? (.externalStorage), visit: Visit? }`
- `ModelContainerFactory.make(inMemory: Bool) throws -> ModelContainer`. The app injects it with `.modelContainer(_)`.
- `Features/NewVisit/Models/VisitDraft.swift` and `DishDraft.swift`: `Sendable` value types with `isComplete` validation (name not blank after trimming, scores in 1...10, at least 1 dish for a visit).
- `JournalStoreProtocol` (`@MainActor`) with the concrete `JournalStore(modelContext:)`:
  - `func restaurants(matching query: String) throws -> [Restaurant]` (case-insensitive contains, ordered by most recent visit)
  - `func existingRestaurant(named name: String) throws -> Restaurant?` (trimmed, case-insensitive exact match)
  - `func saveNewVisit(_ draft: VisitDraft) throws -> Visit` (find-or-create the restaurant)
  - `func updateVisit(_ visit: Visit, with draft: VisitDraft) throws`
  - `func deleteVisit(_ visit: Visit) throws` (removes the restaurant when it has no visits left)
  - `func deleteDish(_ dish: DishEntry) throws`
  - `func dishNameSuggestions(for restaurant: Restaurant) -> [String]` (distinct, most recent first)
- `JournalStoreError: LocalizedError` (`.invalidDraft`, `.saveFailed`).
- `Core/Insights/RestaurantStatsCalculator`: `static func summary(for visits: [VisitSnapshot]) -> RestaurantSummary`, where `RestaurantSummary { visitCount, averageExperience: Double?, lastVisited: Date?, bestDishes: [DishSnapshot] }`. `VisitSnapshot` and `DishSnapshot` are `Sendable` structs created from the models.
- `Preview Content/PreviewData.swift` seeds the description's examples: Sakura Sushi with California Roll 7/9 and experience 5; Bella Italia with 6 visits and scores 8,9,7,8,7,8; Hearthside Steakhouse with 5 visits averaging 8.6, last visited 3 weeks ago; Tokyo House with California Roll 8/6 on 12 Oct 2026.

**Figma references:** none visual. The data shapes come from `NewVisit`, `AddDish`, `RestaurantDetail` and the delete-visit copy in `Confirm`.

**Definition of Done**
- [ ] The models compile with every attribute defaulted or optional and every relationship optional.
- [ ] Store and calculator tests pass against an in-memory container.
- [ ] The app still launches (the shell is unchanged).

**Verification** (`ChefsJournalTests/Core/Persistence/JournalStoreTests.swift`, `Core/Insights/RestaurantStatsCalculatorTests.swift`)
- `saveNewVisitCreatesRestaurantVisitAndDishes`: the counts are 1, 1, 1.
- `savingWithExistingNameReusesRestaurant`: "Sakura Sushi " and then "sakura sushi" leave `restaurants.count == 1` (Review Focus 1).
- `deletingOnlyVisitRemovesRestaurant` and `deletingOneOfTwoVisitsKeepsRestaurant`; after deletion, the `DishEntry` fetch count is 0 (Review Focus 2).
- `draftWithZeroScoreIsIncomplete`, `draftWithBlankDishNameIsIncomplete`, and `saveNewVisitThrowsInvalidDraft`.
- `dishNameSuggestionsAreDistinctAndRestaurantScoped`.
- Summary: Bella's scores (8,9,7,8,7,8) give `averageExperience == 7.833…` (displayed as "7.8"); Sakura gives `visitCount 1`, `average 5.0`, and best dish California Roll.

---

## Phase 3: Journal Home

**Goal:** The Journal tab shows real visits newest first, with empty and populated states and the privacy line.

**Scope**
- `Features/Journal/Views/JournalView.swift`: hero header (date eyebrow, "My journal" large serif title, lock + "Private on this iPhone"), a **New Log** button (it opens a placeholder sheet until Phase 4), the "Recent visits — Newest first" section, and `@Query(sort: \Visit.date, order: .reverse)`. Use `List` with plain style and rule separators, or `LazyVStack`.
- `JournalVisitRow`: photo circle or initials placeholder, "Today · Dine-in", serif restaurant name, a dish summary ("California Roll · Would order again" for a single dish, otherwise comma-joined names), and a compact `ExperienceStampView`.
- `JournalViewModel` (`ObservableObject`) holds the toast message and builds row display strings through `JournalRowFormatter`, a pure struct.
- Empty state: "No visits yet" with a New Log call to action.
- Tapping a row pushes `RestaurantRoute(id:)`, which shows a placeholder destination until Phase 5.

**Figma references:** `Journal`, `.journal-hero`, `.new-log`, `.visit-row`, `.photo-placeholder`, `.experience-compact`, `.section-heading`, `.private-line`.

**Definition of Done**
- [ ] With preview or seed data, the Journal matches the Figma layout. Without data, the empty state shows.
- [ ] Rows support Dynamic Type `.accessibility3` and an 80-character restaurant name without overlap (Review Focus 3).
- [ ] Tests pass.

**Verification**
- `JournalRowFormatterTests`: initials "Bella Italia" → "BI" and "Sakura" → "S"; the subtitle for one dish with again=true is "California Roll · Would order again"; for two dishes it is "Spaghetti Carbonara, Calzone"; the date line for a visit today with take-out is "Today · Take-out".
- Previews: empty, populated, no-photo, and long name at accessibility size.
- Manual: launch on a fresh install and see the empty state.

---

## Phase 4: New Visit Flow and Add Dish (no photos yet)

**Goal:** A user can log a full visit with one or more dishes in under a minute, and it appears at the top of the Journal.

**Scope**
- `NewVisitSheet` (presented from Journal), a three-step sheet with a "Step n of 3" label and a progress track. The bottom primary button reads **Continue** or **Save Log** and is disabled until the step is valid. Cancel/Back are top-left.
  - Step 1 `ChooseRestaurantStep`: search field. Empty query shows "Recently visited". Typing shows matches with "Area · n visits" and an **Add “X”** row. An exact existing match is selected instead of a duplicate.
  - Step 2 `VisitDetailsStep`: Area field (only for a new restaurant), date `DatePicker` (≤ today), Dine-in/Take-out segmented `Picker`, `ScoreSliderView("Restaurant experience")`, and an optional note "What should future you remember?".
  - Step 3 `AddDishesStep`: added dishes as rows (name + `ScorePairView` + Edit), an **Add Dish** outline button, and the disabled reason "Add at least one complete dish to save this visit."
- `DishEditorSheet` (nested sheet, used for both add and edit): name field with suggestion chips from `dishNameSuggestions`, a "Dish scores — Taste and value stay separate" `ScoreSliderView` stack, a "Would order again" `Toggle`, and an optional note. **Done** is disabled until the draft is complete. Ordered-by, tags and photo are **not** in this phase.
- `NewVisitViewModel` (`ObservableObject`) owns a `VisitDraft`, `currentStep`, `canAdvance`, `hasUnsavedContent`, and `func save() throws`. It is injected with `JournalStoreProtocol`.
- Cancel on step 1 with content shows the "Discard this draft?" alert; with no content it dismisses directly.
- On save: dismiss, then the Journal shows the toast "Visit saved to your journal" for 2.6 s.

**Figma references:** `NewVisit` (steps 1–3), `AddDish` (name, suggestions, `.score-stack`, `Toggle`, note), `Confirm` "Discard this draft?", `.step-track`, `.search-results`, `.suggestions`, `.added-dish`, `.disabled-reason`, `.success-toast`.

**Definition of Done**
- [ ] Every flow step validates as specified, the draft can be discarded, and saved visits persist across relaunch.
- [ ] Logging Max's scenario (Sakura Sushi, Dine-in, 5, note, California Roll 7/9) takes ≤ 8 taps plus text entry.
- [ ] Tests pass.

**Verification**
- `NewVisitViewModelTests` with a `MockJournalStore`:
  - `canAdvance` is false on step 1 with no restaurant, false on step 2 with experience 0, and false on step 3 with zero dishes.
  - `save` calls `saveNewVisit` once with the expected draft.
  - `hasUnsavedContent` is false initially and true after typing a name.
  - Editing a dish at index 0 replaces it rather than appending.
- `DishDraftTests`: name "   " → incomplete.
- UI test `LogVisitUITests.testLogMealAppearsAtTopOfJournal` (XCTest): drives the whole flow and asserts the first Journal cell contains "Sakura Sushi".
- Manual: VoiceOver can adjust the sliders, and the keyboard doesn't cover the Continue button.

---

## Phase 5: Restaurant Detail, Dish Detail, Edit and Delete

**Goal:** Users can look back (Journal → Restaurant → Dish) and edit or delete any visit or dish entry. This completes MVP1 apart from photos.

**Scope**
- `RestaurantDetailView` (via `navigationDestination(for: RestaurantRoute.self)`): area eyebrow, serif name, `SummaryStripView` (Visits · Avg. experience · Last visited), a placeholder slot for the Heads-up banner (filled in Phase 7), "Experience history" (latest `ExperienceStampView` + "Not enough visits yet" for now), "Dishes — Best first" (latest instance per dish name with `ScorePairView` and a ✓ Would order again line), the visit list (stamp + note, tap to edit), and "Edit or delete this visit".
- `DishDetailView` (via `DishRoute`): restaurant eyebrow, serif name, large `ScorePairView`, the would-order-again line, `SummaryStripView` (Avg. taste · Avg. value · Last ordered), and a list of every instance at this restaurant (date, taste, value, note), with "Delete this dish entry".
- Edit: a toolbar **Edit** button on Restaurant Detail opens `NewVisitSheet` in edit mode for the selected visit, starting at step 2 and calling `updateVisit`. On Dish Detail, Edit opens `DishEditorSheet` prefilled.
- Delete alerts use the Figma copy. After deleting the only visit, pop to the Journal.
- `RestaurantDetailViewModel` and `DishDetailViewModel` compute display state through `RestaurantStatsCalculator`.

**Figma references:** `RestaurantDetail`, `DishDetail`, `.summary-strip`, `.dish-row`, `.visit-note`, `.delete-button`, `.order-again`, `.note-quote`, and the `Confirm` delete-visit and delete-dish copy.

**Definition of Done**
- [ ] Journal → Restaurant → Dish navigation works with value-based routes.
- [ ] Edits persist, and deletes behave per §4.2 and Open Question 7.
- [ ] Previews: 1 visit, 6 visits, and a long note at accessibility size.
- [ ] Tests pass.

**Verification**
- `RestaurantDetailViewModelTests`: Bella's summary shows "7.8", 6 visits, and dish ordering per Open Question 6 (taste desc, then value desc, then recency).
- `DishDetailViewModelTests`: averages across two instances at the *same* restaurant (7/9 and 8/6 → 7.5 / 7.5), and ignores the Tokyo House instance; last ordered is the max date.
- `JournalStoreTests.updateVisitChangesScoreAndKeepsDishes`.
- UI test `DeleteVisitUITests.testDeletingOnlyVisitReturnsToJournalAndRemovesRow`.

---

## Phase 6: Dish Photos (Camera and Photo Library)

**Goal:** Users can attach a photo to a dish entry and see it in the Journal row, the restaurant dish row and the Dish Detail hero. **This completes MVP1.**

**Scope**
- `DishEditorSheet` gets a photo control. Empty state: a camera tile labelled "Camera or Photo Library", which opens a `Menu` with "Take Photo" (`CameraPicker`) and "Choose from Library" (`PhotosPicker`). Attached state: a thumbnail labelled "Change photo", with a Remove option.
- `Core/Services/CameraPicker.swift`: a `UIViewControllerRepresentable` around `UIImagePickerController`. This is the only UIKit use, justified because SwiftUI has no camera picker. Hide "Take Photo" when the camera is unavailable (Simulator).
- `PhotoProcessor` (`actor`): `func downsampledJPEG(from data: Data, maxPixelLength: Int = 1600) throws -> Data` and `func thumbnail(from data: Data, pointSize: CGFloat, scale: CGFloat) throws -> CGImage`, using ImageIO, off the main actor. It throws `PhotoError: LocalizedError`.
- `DishDraft.photoData: Data?`; `JournalStore` saves it.
- Display: the Journal row uses the first dish photo that exists; `.dish-row` uses an arched thumbnail; Dish Detail uses a full-width hero (`containerRelativeFrame`, no `GeometryReader`).
- Add `NSCameraUsageDescription` ("Take a photo of your dish for your private journal."). The photo library needs no key because `PhotosPicker` is out-of-process. Update `PrivacyInfo.xcprivacy` if any required-reason API is touched.

**Figma references:** `AddDish` `.photo-control` (attached and empty), `.visit-row img`, `.dish-row img`, `.dish-hero`, `.added-dish img`.

**Definition of Done**
- [ ] Photos attach from the library (simulator) and camera (device), survive relaunch, and are stored ≤ 1600 px.
- [ ] Scrolling a Journal with 50 photo visits stays smooth because thumbnails are downsampled.
- [ ] A permission denial shows an explanatory message instead of failing silently.
- [ ] Tests pass.

**Verification**
- `PhotoProcessorTests`: a 4000×3000 generated image comes back with a long edge of 1600, the aspect ratio is preserved, and invalid data throws `PhotoError.unreadableImage`.
- `JournalStoreTests.photoDataPersistsAndIsRemovedWithDish`.
- Manual on a device: take a photo, then check the Journal thumbnail and the Dish hero. Profile memory with the Instruments Allocations template while scrolling.

---

## Phase 7: Diners, Dietary Tags and Heads-up (MVP2)

**Goal:** Dishes carry dietary tags and an "Ordered by" diner. Tags can be marked as a problem for diners, and the restaurant page and New Visit flow show the resulting Heads-up.

**Scope**
- Models (lightweight migration, additive): `Diner { id, name, dietaryProfile: String, isOwner: Bool, dishes: [DishEntry]? (nullify) }`, `DietaryFlag { tag: String, problemFor: [Diner]?, dish: DishEntry? }`, and on `DishEntry`: `orderedBy: Diner?`, `flags: [DietaryFlag]? (cascade)`.
- `DietaryTag` enum with presets: Contains gluten, Contains dairy, Contains nuts, Contains shellfish, Contains egg, Contains meat, Vegetarian, Vegan, Spicy. Custom tags are stored as free text.
- Seed the owner diner "Me" (`isOwner = true`) on first launch, idempotently.
- **Settings tab:** `SettingsView` with the privacy card and a Journal → **Diners** row. The Your-data rows are added in Phase 10. `DinersView` lists diners ("Me" shows "Phone owner · Can’t be deleted"), has an add sheet (name + optional dietary profile), an edit sheet, and swipe-to-delete with confirmation (Open Question 5).
- `DishEditorSheet` adds an **Ordered by** `Picker` (default Me), dietary tag chips (presets + "+ Custom"), and a "Problem for" multi-select per selected tag. Show the helper "Tagged, but not marked as a problem for a diner. No Heads-up will be created." when applicable. If a diner's profile text mentions a selected tag's keyword (for example, "gluten"), show a *suggestion*. Never auto-add a flag.
- `HeadsUpCalculator.items(for dishes: [DishSnapshot]) -> [HeadsUpItem]`, where `HeadsUpItem { dishName, tag, dinerNames: [String] }`. Items are deduplicated by dish name + tag and sorted by dish name.
- `HeadsUpBannerView` appears on Restaurant Detail (warning, or the "Heads-up: none" variant) and in New Visit step 2 as soon as a restaurant with flags is chosen.
- Restaurant Detail dish filter chips: "All dishes", each diner who ordered here, and each tag used here.

**Figma references:** `AddDish` (Ordered by, Dietary tags, `.tag-wrap`, `.tag-note`), `Settings`, `Diners` + New Diner sheet (`.mini-sheet`, `.diner-row`, `.avatar`), `.heads-up` / `.heads-up.none`, `NewVisit` step 2 Heads-up, and the `RestaurantDetail` `.filter-scroll`.

**Definition of Done**
- [ ] The Liam & Eliza scenario works end to end: starting a new log at Bella Italia shows "Calzone — contains gluten (Eliza)".
- [ ] Existing MVP1 data migrates without loss.
- [ ] "Me" can't be deleted.
- [ ] Tests pass.

**Verification**
- `HeadsUpCalculatorTests`:
  - `tagWithoutProblemForProducesNoItem`, which covers the Sakura shellfish case (Review Focus 4).
  - `calzoneGlutenForElizaProducesOneItem`.
  - `sameFlagOnTwoVisitsIsDeduplicated`.
  - `twoDinersMergeIntoOneItem`.
- `DinerStoreTests`: `ownerSeededOnce` (two launches leave 1 "Me"), `deletingOwnerThrows`, and `deletingDinerNullifiesOrderedBy`.
- `RestaurantDishFilterTests`: filtering by Eliza returns only her dishes; filtering by "Contains gluten" returns only Calzone.
- Migration check: install the Phase 6 build, log a visit, install the Phase 7 build, and confirm the visit is still present.

---

## Phase 8: History Tab — Search, Filters, Sort and "Been a While" (MVP3, part 1)

**Goal:** Users can ask their journal "what do I love that I haven't had lately?" and get an answer.

**Scope**
- `Core/Insights/HistoryQueryEngine`: `static func results(restaurants: [RestaurantSnapshot], dishes: [DishSnapshot], filter: HistoryFilter, now: Date) -> [HistoryResult]`.
  - `HistoryFilter { segment (.restaurants/.dishes), searchText, minimumAverage: Int?, scoreType (.experience/.taste/.value), lastVisitedOlderThan (.oneWeek/.threeWeeks/.threeMonths)?, visitType?, tag?, dinerID?, wouldOrderAgainOnly, sort (.score/.recency/.visits) }`.
  - Search matches restaurant name, dish name or note text, case- and diacritic-insensitive.
  - For restaurants, the taste/value score types use the averages of that restaurant's dishes (design assumption A4).
- `HistoryView`: a `.searchable` field ("Restaurant, dish, or note"), a Restaurants/Dishes segmented picker, removable active-filter chips, an "n results" heading with the sort label, ranked `HistoryRow`s (rank, serif name, "5 visits · Last visited 3 weeks ago", average in cobalt), and a "No matches" empty state. The `TrendBadgeView` slot is wired in Phase 9.
- `FilterSheet`: Cancel / Filters / Apply, a minimum-average slider (1–10), score type, last-visited check rows, Visit type / Dietary tag / Diner pushed pickers, a would-order-again toggle, sort, and "Reset all filters".
- `HistoryViewModel` owns the `HistoryFilter`. The snapshot build and query run in a `nonisolated` async function so large journals stay responsive.
- `BeenAWhileFinder.suggestions(restaurants:now:limit: 2)`: average experience ≥ 8.0 **and** last visit ≥ 21 days ago, sorted by average descending. The Journal shows these as the ink "Been a while" card(s) above Recent visits.

**Figma references:** `History`, `FilterSheet`, `.active-chips`, `.history-row`, `.rank`, `.average`, `.empty-state`, `.check-row`, and `Journal` `.while-card`.

**Definition of Done**
- [ ] Grace's scenario works: History → Filter → 8+ and > 3 weeks lists Hearthside Steakhouse (8.6, 5 visits, 3 weeks ago), and tapping it opens Restaurant Detail.
- [ ] The Journal shows the Hearthside card from seed data.
- [ ] Tests pass.

**Verification**
- `HistoryQueryEngineTests` (fixtures from `PreviewData`):
  - `minimumAverageEightAndThreeWeeksReturnsHearthsideOnly`.
  - `searchMatchesNoteText` ("take-out" finds Sakura).
  - `sortByVisitsPutsBellaFirst`.
  - `dishSegmentFiltersByTag`.
  - `wouldOrderAgainOnlyExcludesCalzone`.
  - `emptyJournalReturnsNoResults`.
- `BeenAWhileFinderTests`: an average of exactly 8.0 at 21 days is included; an average of 7.9 is excluded; 20 days is excluded; at most 2 results.
- Manual: with 500 generated visits (DEBUG seed), typing in search doesn't stutter.

---

## Phase 9: Score Charts, Trends and Dish Comparison (MVP3, part 2)

**Goal:** Users can see how restaurants and dishes change over time, and compare the same dish across restaurants.

**Scope**
- `TrendCalculator.trend(for scoresOldestFirst: [Int]) -> Trend?`:
  - Return `nil` when there are fewer than 3 scores.
  - Let `h = count / 2`. Compare `mean(first h)` with `mean(last h)`; for odd counts the middle score is excluded.
  - A difference greater than +0.5 is `.improving`, less than −0.5 is `.slipping`, and otherwise `.steady`.
- `ScoreChartView` (Swift Charts): a `LineMark` + `PointMark` of the **actual** scores (no smoothing or interpolation), each point annotated with its value, a y-axis fixed at 0…10 with 0/5/10 gridlines, and the x-axis showing visit dates. It accepts a series colour so the same view serves experience (tomato) and taste/value (cobalt; value dashed).
- Restaurant Detail "Experience history": with ≥ 2 visits, show the chart; with 1 visit, the stamp + "Not enough visits yet". `TrendBadgeView` appears when a trend exists. History rows also get trend badges.
- Dish Detail "At this restaurant": a taste and value chart across instances, with the trend badge.
- `DishComparison.rows(for dishName: String, currentRestaurantID: UUID, dishes: [DishSnapshot]) -> [ComparisonRow]`: matches on trimmed, case-insensitive dish name, takes the latest instance per restaurant, and orders by last ordered date. Dish Detail shows a **Compare** table (Restaurant/date · Taste · Value) with the current restaurant's row highlighted in `cobaltSoft`.

**Figma references:** `Chart`, `Trend`, `RestaurantDetail` "Experience history" / `.not-enough`, and `DishDetail` "At this restaurant", "Compare", `.compare-head`, `.compare-row.current`.

**Definition of Done**
- [ ] Bella shows a chart of 8 → 9 → 7 → 8 → 7 → 8 labelled **Steady**. A 9, 8, 6, 5 fixture shows **Slipping**.
- [ ] The California Roll Compare table lists Tokyo House (8/6, 12 Oct 2026) and Sakura Sushi (7/9, current).
- [ ] The chart has an accessibility label listing the scores. Tests pass.

**Verification**
- `TrendCalculatorTests` (parameterised, Review Focus 5):
  - `[8,9,7,8,7,8]` → `.steady`
  - `[9,8,6,5]` → `.slipping`
  - `[5,6,8,9]` → `.improving`
  - `[7,7]` → `nil`
  - `[9,1,5]` → compare 9 with 5 → `.slipping`
  - `[7,8,7,7]` → 7.5 vs 7.0, a difference of −0.5, which is **not** less than −0.5 → `.steady` (boundary)
- `DishComparisonTests`: "california roll " matches "California Roll"; only the latest instance per restaurant is used; a restaurant with no match gives an empty array.
- Previews: chart with 2, 6 and 20 points, in dark mode.

---

## Phase 10: Backup & Sync, Export, and Privacy & Insights (MVP4)

**Goal:** Users can keep their journal across devices, export a personal copy, and make an informed opt-in choice, all without compromising privacy.

**Scope**
- **Settings → Your data** group: Backup & Sync ("Off" / "Synced just now"), Export ("CSV or PDF"), and Privacy & Insights ("Contribution off/on"). The Journal and Settings privacy line switches to "Private, synced with iCloud" when sync is on.
- **Backup & Sync** (`BackupView`, `BackupViewModel`):
  - `@AppStorage("iCloudSyncEnabled")`.
  - `ModelContainerFactory` builds the container with `cloudKitDatabase: .automatic` or `.none`. The App rebuilds the container when the preference changes.
  - `SyncStatusMonitor` maps `NSPersistentCloudKitContainer.eventChangedNotification` to `.off / .syncing / .synced(Date) / .failed(SyncError)`.
  - Add the iCloud and CloudKit capability and container, plus the Remote Notifications background mode. See Open Question 2 for the fallback when no team exists.
- **Export** (`ExportView`, `ExportViewModel`):
  - `JournalExporter` with `func csv(from snapshot: JournalSnapshot) -> Data` (one row per dish entry: restaurant, area, date, visit type, experience, dish, taste, value, would order again, ordered by, tags, problem for, visit note, dish note; RFC 4180 quoting) and `@MainActor func pdf(from snapshot: JournalSnapshot, includePhotos: Bool) throws -> Data` (one section per restaurant, rendered with `ImageRenderer`).
  - Save with `.fileExporter`. Show the "Generating…" and "Export ready" states. The summary line reads "n restaurants · n visits · Photos included / No photos".
- **Privacy & Insights** (`PrivacyInsightsView`):
  - Show the "May be contributed" and "Never contributed" cards, and a `@AppStorage("insightsOptIn")` toggle that defaults to **false**.
  - Turning it off shows a confirmation ("No further data will be shared…").
  - No networking (Open Question 3).

**Figma references:** `Settings` (Your data group, `.privacy-card`, `.settings-row`), `Backup` (`.feature-icon`, `.sync-status`, `.info-block`), `ExportScreen` (`.export-summary`, `.success-panel`), and `Privacy` (`.share-columns`, the turn-off `Confirm`).

**Definition of Done**
- [ ] With an iCloud account on two simulators or devices, a visit logged on one appears on the other.
- [ ] With sync off, no CloudKit traffic occurs.
- [ ] A CSV export opens correctly in Numbers. A PDF export includes photos only when the toggle is on.
- [ ] Insights is off on a fresh install, turning it off requires confirmation, and the app makes no network requests (verify with the Instruments Network template).
- [ ] `PrivacyInfo.xcprivacy` is up to date. The full test suite passes, and the app builds for Release.

**Verification**
- `JournalExporterTests`:
  - The CSV header matches the column order exactly.
  - A note containing a comma, quote and newline is quoted correctly.
  - One row per dish entry, and tags are joined with "; ".
  - An empty journal gives a header-only file.
- `BackupViewModelTests`: the status text for each `SyncStatus` matches the Figma copy ("Syncing…", "Last synced just now", "Your journal currently stays private on this iPhone.").
- `PrivacyInsightsViewModelTests`: the default is off; `requestTurnOff()` sets `isConfirmingTurnOff` without changing the value until it is confirmed.
- Schema check: `ModelContainerFactory.make(cloudKit: true)` initialises against the development container without the "CloudKit integration requires…" error, confirming the Phase 2 constraints held.
- Manual: export both formats to Files, and sign out of iCloud to see the `.failed` status message.

---

## Phase → MVP Coverage

| MVP task (description §6) | Phase |
|---|---|
| MVP1 1–3 visit, dishes, would order again | 2, 4 |
| MVP1 4 private, on-device, no account | 1, 2 (no networking) |
| MVP1 5 photos | 6 |
| MVP1 6 add restaurant by name/area | 4 |
| MVP1 7 browse Journal → Restaurant → Dish | 3, 5 |
| MVP1 8 edit/delete | 5 |
| MVP2 1–5 tags, diners, ordered by, Heads-up, filter by diner/tag | 7 |
| MVP3 1, 6, 7 filter, search, sort; 5 Been a while | 8 |
| MVP3 2–4 charts, trends, compare | 9 |
| MVP4 1–4 sync, export, privacy opt-in/out | 10 |
