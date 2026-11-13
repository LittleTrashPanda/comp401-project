# CLAUDE.md — iOS SwiftUI Project Standards

> Coding standards and best practices for this iOS SwiftUI project. Apply these guidelines to all code written in this codebase.

**Minimum iOS Deployment Target:** iOS 27.0+
*(Update this to match your Xcode project settings.)*

**Language mode:** Swift 6 with strict concurrency checking enabled.

---

## 1. Project Structure

Group files by **feature/module**, not by type.

```
MyApp/
├── App/
│   └── MyApp.swift
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   └── Settings/
│       ├── Views/
│       ├── ViewModels/
│       └── Models/
├── Core/
│   ├── Networking/
│   ├── Persistence/
│   └── Services/
├── Shared/
│   ├── Components/
│   ├── Extensions/
│   └── Constants/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.xcstrings
│   └── PrivacyInfo.xcprivacy
└── MyAppTests/
    └── Features/
        └── Home/
```

- Group by feature, never by type (no top-level `Views/` or `Models/` folders)
- Reusable UI components live in `Shared/Components/`
- Tests mirror the feature structure of the app target

---

## 2. Swift & SwiftUI Conventions

- **Always prefer SwiftUI over UIKit.** Only use UIKit when SwiftUI has no equivalent, wrapped in `UIViewRepresentable` / `UIViewControllerRepresentable`
- Types: `PascalCase` — Variables/functions: `camelCase` — Constants: `let`
- Avoid abbreviations: `userProfileViewModel` not `usrProfVM`
- Avoid vague names: `users` not `data`, `fetchUsers()` not `load()`
- Prefer `struct` for Views and Models; use `final class` for ViewModels
- Default to `private` — only widen access when necessary

**State and observation — when to use each:**

Choose the pattern by **how widely the ViewModel is shared**:

**Feature-scoped ViewModel** — used only inside one feature (e.g. `HomeView`, `HomeViewModel` and the Home models all live in `Features/Home/`):
- The ViewModel conforms to `ObservableObject` and exposes state with `@Published`
- The feature's root view **owns** it with `@StateObject`
- Child views in the same feature **receive** it with `@ObservedObject`
- No environment injection is needed

**Global ViewModel** — shared by multiple features across the app (auth, theme, user session):
- The ViewModel is marked `@Observable`
- Inject it once near the app root with `.environment(object)`
- Read it in any view with `@Environment(Type.self)`; use `@Bindable` locally when a binding is needed

| Tool | Use When |
|---|---|
| `@State` | Simple local value state owned by this view |
| `@Binding` | A child view needs to mutate a value owned by its parent |
| `@StateObject` | The feature's root view creates and owns a feature-scoped `ObservableObject` ViewModel |
| `@ObservedObject` | A child view in the same feature receives that ViewModel from its parent |
| `@Environment(Type.self)` | Reading a global `@Observable` ViewModel shared across features |
| `@Bindable` | Creating bindings to properties of a global `@Observable` ViewModel |

Do not use `@EnvironmentObject`; global state uses `@Observable` with `@Environment` instead.

**Setting up a global ViewModel:**
1. Mark the ViewModel `@Observable` (and `@MainActor`).
2. Create the single instance in the `App` struct with `@State`, so it is created once and lives as long as the app.
3. Inject it into the root view with `.environment(...)`. Every view below the root can then read it.
4. In any view that needs it, read it with `@Environment(Type.self)`. Wrap it in `@Bindable` inside `body` when you need bindings.

```swift
// 1. Global ViewModel
@MainActor
@Observable
final class SessionViewModel {
    var isSignedIn = false
    var displayName = ""
}

// 2–3. Create once with @State and inject at the root
@main
struct MyApp: App {
    @State private var sessionViewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(sessionViewModel)
        }
    }
}

// 4. Read it anywhere below the root
struct ProfileView: View {
    @Environment(SessionViewModel.self) private var sessionViewModel

    var body: some View {
        @Bindable var sessionViewModel = sessionViewModel
        TextField("Display name", text: $sessionViewModel.displayName)
    }
}
```

- Create global ViewModels **only** in the `App` struct — never instantiate a second copy inside a feature
- Every `#Preview` of a view that reads a global ViewModel must inject one: `.environment(SessionViewModel())`, or the preview will crash

---

## 3. Architecture (MVVM)

| Layer | Responsibility |
|---|---|
| **View** | Display state, forward user actions. Zero business logic. |
| **ViewModel** | `ObservableObject` class (feature-scoped) or `@Observable` class (global). Holds state, handles business logic, calls Services. |
| **Model** | Plain data structures. `Codable`, `Identifiable`, `Sendable` value types. |
| **Service** | Networking, persistence, device APIs. No UI concerns. Defined by a protocol. |

- Views are **dumb** — if a View contains business logic, move it to the ViewModel
- ViewModels import `Foundation` plus `Combine` (feature-scoped) or `Observation` (global), **not** SwiftUI
- Inject services into ViewModels via their initialiser, typed as protocols
- Keep ViewModel initialisers cheap — no network or disk work in `init`; start it from `.task {}`

```swift
import Combine
import Foundation

// Feature-scoped: used only inside the Home feature
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var errorMessage: String?

    private let userService: UserServiceProtocol

    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }

    func fetchUsers() async {
        do {
            users = try await userService.fetchUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
        .task {
            await viewModel.fetchUsers()
        }
    }
}
```

---

## 4. SwiftUI Best Practices

- Keep `body` short — extract into subviews if it exceeds ~30 lines
- Never put business logic or computed logic inside `body` — move it to the ViewModel
- Use `#Preview` macro for every view, with sample data covering empty, loading, and error states
- Use `.task {}` for async work tied to a view's lifecycle (not `.onAppear {}`); it is cancelled automatically when the view disappears
- Use `NavigationStack` with value-based `navigationDestination(for:)` — never `NavigationView`
- All list data must conform to `Identifiable`
- Never use `AnyView` — use `@ViewBuilder` instead
- **Don't overuse the environment for ViewModels.** Only global ViewModels shared across features go in the environment (see Section 2). A feature-scoped ViewModel is owned with `@StateObject` at the feature's root view and passed to child views with `@ObservedObject`.

```swift
// ✅ Feature-scoped ViewModel: owned at the feature root, passed down
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        HomeUserList(viewModel: viewModel)
    }
}

struct HomeUserList: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List(viewModel.users) { user in
            UserRow(user: user)
        }
    }
}

// ✅ Global ViewModel: injected once at the app root, read anywhere
@main
struct MyApp: App {
    @State private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}

// ❌ Wrong: feature-only ViewModel injected into the environment
HomeView()
    .environment(HomeViewModel())
```
- Avoid `GeometryReader` unless absolutely necessary; prefer `containerRelativeFrame`, `ViewThatFits`, and layout priorities

**Collections:**
- Use `List` for standard, system-styled lists (rows, swipe actions, selection, edit mode)
- Use `ScrollView` + `LazyVStack` / `LazyHStack` / `LazyVGrid` for custom layouts
- Never use a plain `VStack` inside a `ScrollView` for long or unbounded collections

**System design and layout:**
- Use standard system components (navigation bars, toolbars, tab views, sheets, buttons) so the app adopts Liquid Glass automatically — don't hand-roll blur or glass effects to imitate it
- iPhone apps can be resized on iOS 27 — build adaptive layouts, never hardcode screen sizes, and check previews at multiple sizes
- Use semantic colors and fonts (`.primary`, `.body`, etc.) or design tokens from `Shared/Constants/`; support Light and Dark Mode

```swift
// ✅ Preferred
.task {
    await viewModel.fetchUsers()
}

// ❌ Wrong
.onAppear {
    Task { await viewModel.fetchUsers() }
}
```

---

## 5. Concurrency & Thread Safety

- Use `async/await` for all async work — no completion handlers or `DispatchQueue` in new code
- ViewModels are `@MainActor`. If the target uses default `MainActor` isolation, this is implicit; otherwise mark them explicitly
- Move heavy work off the main actor with `nonisolated` async functions or a dedicated `actor` — avoid `Task.detached`
- Use `async let` or `TaskGroup` for parallel independent tasks
- Types that cross concurrency boundaries must be `Sendable`
- Always handle errors with `do/try/catch` — no silent failures
- Respect cancellation in long-running work: call `try Task.checkCancellation()` between steps

- Use `actor` to protect shared mutable state accessed from multiple concurrent contexts

```swift
actor DataCache {
    private var cache: [String: Data] = [:]
    func store(_ data: Data, for key: String) { cache[key] = data }
    func retrieve(for key: String) -> Data? { cache[key] }
}
```

---

## 6. Data & State Management

| Solution | Use When |
|---|---|
| `@AppStorage` | Simple user preferences (booleans, strings, numbers) |
| **SwiftData** | Local persistence |
| **Keychain** | Sensitive data — tokens, passwords |

- Keep a **single source of truth** — never duplicate state across ViewModels
- Derive values with computed properties rather than storing them separately
- Avoid global variables and singletons for state
- **SwiftData exception to "dumb views":** `@Query` may be used directly in a view for simple reads. Inserts, updates, deletes, and any filtering logic go through a ViewModel or service using `ModelContext`

---

## 7. Networking

- Use `URLSession` with `async/await`
- Define all network calls through a protocol-based `APIClient` or `NetworkService`
- Inject the `URLSession` into the client so it can be replaced in tests
- Decode responses with `Codable` and `JSONDecoder`
- Always check `HTTPURLResponse.statusCode` — never assume a response is successful
- Use `.xcconfig` for base URLs per environment — never hardcode

```swift
final class APIClient: APIClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let (data, response) = try await session.data(for: endpoint.urlRequest)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw NetworkError.invalidResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

## 8. Error Handling

- Define custom `Error` enums per domain — never throw raw `NSError`
- Errors propagate up to the ViewModel; Views display them, they don't interpret them
- Never use `try!` in production code
- Never use `try?` silently — if you suppress an error, log it
- Log with `os.Logger` (one logger per subsystem/category) — never `print()` in committed code

```swift
enum NetworkError: LocalizedError {
    case invalidResponse
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .unauthorized: return "Please sign in again."
        case .invalidResponse: return "Something went wrong. Please try again."
        }
    }
}
```

---

## 9. Clean Code Principles

- **Single Responsibility** — every type and function does one thing
- **DRY** — if you write the same logic twice, extract it
- **KISS** — write the simplest solution that works; don't over-engineer
- **YAGNI** — don't build for hypothetical future requirements
- **Meaningful names** — code should read like plain English; avoid `data`, `info`, `flag`, `manager`
- **Small functions** — target under 20–30 lines; if longer, it's doing too much
- **No deep nesting** — use `guard` and early returns to keep code flat
- **Comments explain *why*, not *what*** — if you need to explain what code does, rewrite it
- **No magic numbers** — use named constants
- **No commented-out code** — delete it; version control has the history

```swift
// ❌ Deep nesting
func process(user: User?) {
    if let user = user {
        if user.isActive {
            // do work
        }
    }
}

// ✅ Flat with guard
func process(user: User?) {
    guard let user, user.isActive else { return }
    // do work
}
```

---

## 10. Security & Privacy

- **Keychain for all sensitive data** — never store tokens or passwords in `UserDefaults`
- Never log sensitive data — no tokens, passwords, or PII; mark dynamic log values `privacy: .private` by default
- Never hardcode API keys or secrets in source code — use `.xcconfig` files kept out of version control
- Sanitise user input before processing or displaying it
- Request only the permissions and entitlements the app actually needs, with clear usage-description strings
- Keep `PrivacyInfo.xcprivacy` up to date when adding SDKs or required-reason APIs

---

## 11. Performance

- Use lazy containers for large collections (see Section 4)
- Never load full-resolution images into memory — resize and cache appropriately
- Keep heavy work (JSON parsing, database queries, image processing) off the main actor
- Keep ViewModels focused, especially global `@Observable` ones, so unrelated property changes don't re-render unrelated views
- Profile with Instruments before optimising — don't guess at bottlenecks

---

## 12. Memory Management

- Don't add manual Combine subscriptions (`sink`, `assign`) for state propagation — `@Published` with `@StateObject`/`@ObservedObject`, or `@Observable`, already handles it
- Capture `[weak self]` in escaping closures stored on reference types to avoid retain cycles
- A `Task` stored on an object and running a long loop must be cancelled when the owner goes away; prefer `.task {}` in views, which handles this automatically
- Use `weak` references for delegates

```swift
// ✅ Long-running work tied to the view's lifetime
.task {
    for await update in viewModel.updates {
        viewModel.apply(update)
    }
}
```

---

## 13. Testing

- Use **Swift Testing** (`import Testing`, `@Test`, `#expect`, `#require`) for unit tests; use XCTest only for UI tests
- Test ViewModels by injecting mock services that conform to the service protocols
- Test business logic, not SwiftUI layout; verify UI with previews and UI tests for critical flows
- Every bug fix includes a test that reproduces the bug
- The app must build and all tests must pass before a phase is considered done

```swift
import Testing
@testable import MyApp

@MainActor
struct HomeViewModelTests {
    @Test func fetchUsersPopulatesList() async {
        let viewModel = HomeViewModel(userService: MockUserService(users: [.sample]))
        await viewModel.fetchUsers()
        #expect(viewModel.users.count == 1)
    }
}
```

---

## 14. Accessibility & Localization

- Support Dynamic Type — never fix font sizes; use text styles or `@ScaledMetric`
- Give icon-only buttons and images meaningful `accessibilityLabel`s; hide decorative images
- Ensure tap targets are at least 44×44 points and color is never the only signal
- Put all user-facing strings in `Localizable.xcstrings` (String Catalog); never concatenate localized strings

---

*Keep this file updated as the project evolves.*
