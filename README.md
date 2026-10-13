# Moviro

**Model-View-Router** design pattern for iOS.

Moviro is a lightweight Swift framework that brings a clean, router-driven architecture to SwiftUI apps. It separates navigation logic from views and business logic, giving you a composable tree of routers that own the entire navigation state.

## Requirements

- iOS 17+
- Swift 5.9+

## Installation

### Swift Package Manager

Add Moviro to your project via Xcode or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ylapps/MoViRo.git", from: "1.4.0")
]
```

Then add `"Moviro"` to the `dependencies` of any target that uses it:

```swift
.target(name: "MyApp", dependencies: ["Moviro"])
```

## Core Concepts

Moviro separates every screen into three distinct pieces:

| Layer | Responsibility | Base Type |
|---|---|---|
| **Model** | Business logic, state, data fetching | `Model<Router>` |
| **View** | UI rendering (SwiftUI `View`) | `BaseView` protocol |
| **Router** | Navigation decisions, screen composition | `PushRouter<V>`, `ModalRouter<V>` |

The **Router** owns the **Model**, the **Model** holds a weak reference back to its **Router** (for triggering navigation), and the **View** reads from the **Model**.

```
┌──────────┐  owns   ┌──────────┐
│  Router   │───────▶│  Model   │
└──────────┘         └──────────┘
      │                   │
      │ makeView()        │ @State var model
      ▼                   ▼
┌──────────────────────────────┐
│            View              │
└──────────────────────────────┘
```

## Architecture Overview

### Router Hierarchy

```
AnyRouter                        Base class for all routers
├── AnyModalRouter               Presents modals (sheet / fullScreen / popover)
│   ├── AnyNavigationStackRouter Wraps a push-based flow in NavigationStack
│   └── AnyModalSwitchRouter     Swap modal content without dismissing
├── AnyPushRouter                Push navigation via navigationDestination
│   └── AnyPushSwitchRouter      Swap pushed content in-place
```

### How a router becomes a view

`makeView()` on any router returns its screen. Each concrete router composes
that screen statically — its `BaseView`, the model's appearance tracking, and
the modifier that hangs its presentations or its push destination off it:

```swift
// PushRouter<V>
ViewType(model: model)
    .appearance(of: model)
    .pushDestination(of: self)

// ModalRouter<V>
ViewType(model: model)
    .appearance(of: model)
    .presentations(of: self)

// NavigationStackRouter
NavigationStack { root.makeView() }
    .presentations(of: self)
```

A parent holds its children as `AnyPushRouter` / `AnyModalRouter`, so the
hand-off from a router to the screen it describes is the one place a view's
type has to be erased. That happens once per screen, inside Moviro, and the
dynamic type behind it never changes for a given router — SwiftUI keeps the
screen's identity and state across updates. Everything around it is statically
typed, and `makeView()` identifies the screen by its router, so replacing a
`pushed` or `presented` router with another of the same kind is a new screen
with fresh state.

### Concrete Types (you subclass these)

| Type | Use For |
|---|---|
| `PushRouter<V>` | A screen inside a navigation stack |
| `ModalRouter<V>` | A screen presented as a modal |
| `NavigationStackRouter` | Wrapping a push flow in `NavigationStack` |
| `ModalRouterWithCloseReason<V, R>` | Modal that provides a close reason |
| `PushRouterWithCloseReason<V, R>` | Push screen that provides a close reason |

## Usage

### 1. Define a View

Conform to `BaseView`. The view receives its model via the required `init(model:)`.

```swift
struct HomeView: BaseView {
    @State var model: HomeModel

    init(model: HomeModel) {
        self.model = model
    }

    var body: some View {
        List {
            Button("Push Detail") {
                model.router?.pushDetail()
            }
            Button("Present Sheet") {
                model.router?.presentSheet()
            }
        }
        .navigationTitle("Home")
    }
}
```

### 2. Define a Model

Subclass `Model<Router>` and mark it `@Observable`. The generic parameter is the router type, giving the model type-safe access to navigation methods.

```swift
@Observable
final class HomeModel: Model<HomeRouter> {}
```

For models that don't need a router (e.g. standalone view models), use `Model<Never>`:

```swift
@Observable
final class StandaloneModel: Model<Never> {
    let title: String
    
    init(title: String) {
        self.title = title
        super.init()
    }
}
```

### 3. Define a Router

Subclass `PushRouter<ViewType>` for navigation-stack screens or `ModalRouter<ViewType>` for modals. Override `makeModel()` to provide the model, and add navigation methods.

```swift
final class HomeRouter: PushRouter<HomeView> {
    override func makeModel() -> HomeModel {
        HomeModel(router: self)
    }

    func pushDetail() {
        pushed = DetailRouter()
    }

    func presentSheet() {
        presented = SheetRouter()
    }
}
```

### 4. Wire Up the App

Create a `NavigationStackRouter` as the entry point and call `makeView()`:

```swift
final class AppNavigationStackRouter: NavigationStackRouter {
    init() {
        super.init(root: HomeRouter(), transition: .fullScreen)
    }
}

struct ContentView: View {
    @State private var router = AppNavigationStackRouter()

    var body: some View {
        router.makeView()
    }
}
```

## Navigation Patterns

### Push Navigation

Set the `pushed` property on any `PushRouter` to push a new screen:

```swift
func pushDetail() {
    pushed = DetailRouter()
}
```

### Zoom Push Transition

A push can grow out of the view that was tapped and shrink back into it on
pop — iOS 18's zoom navigation transition, matched through the stack. Create
the router with `.zoom(sourceID:)` and mark the source view with the same id:

```swift
final class DetailRouter: PushRouter<DetailView> {
    init(item: Item) {
        super.init(transition: .zoom(sourceID: item.id))
    }
    // ...
}

// In the list screen, inside the same navigation stack
ItemCard(item)
    .zoomTransitionSource(id: item.id)
    .onTapGesture { model.router?.showDetail(item) }
```

The namespace the two are matched in belongs to the `NavigationStackRouter`'s
screen, so nothing is passed around. Before iOS 18 both are no-ops and the
system push is used.

Give the source no pressed look. The system snapshots the source view at the
push, and a `Button` in the plain style is still dimmed by the press at that
moment, so the screen grows out of a washed-out card. A `ButtonStyle` whose
body is just `configuration.label` keeps the snapshot true to the card.

### Modal Presentation

Present modals through the push router's `presented` property. The modal transition is defined at the router level:

```swift
// Sheet
final class SheetRouter: ModalRouter<SheetView> {
    init() {
        super.init(transition: .sheet)
    }
    // ...
}

// Full screen
final class FullScreenRouter: ModalRouter<FullScreenView> {
    init() {
        super.init(transition: .fullScreen)
    }
    // ...
}

// Popover
final class PopoverRouter: ModalRouter<PopoverView> {
    init() {
        super.init(transition: .popover())
    }
    // ...
}
```

Present from any push router:

```swift
func presentSheet() {
    presented = SheetRouter()
}
```

### Full Screen with a Transition of Its Own

A full-screen cover normally slides up. `.fullScreen(transition:animation:removal:)`
replaces that with any `AnyTransition` on the cover's content: the cover is put
up without animation over a clear presentation background, the screen is
inserted with the transition once the cover is on screen, and on dismissal the
screen is removed with it before the cover is taken down. Wherever the
transition leaves the screen clear, the presenting screen shows through, so a
fade over the previous screen is one line:

```swift
final class RevealRouter: ModalRouter<RevealView> {
    init() {
        super.init(transition: .fullScreen(
            transition: .opacity,
            animation: .easeOut(duration: 0.45),
            removal: .easeIn(duration: 0.4)   // defaults to `animation`
        ))
    }
    // ...
}
```

Dismissal is the usual `requestClose()` / `close()` or the presenting router's
`presented = nil`; the presenting router's `presented` keeps the cover until its
content has left, and the last value set while it is leaving is the one that
lands. The transition carries no animation of its own — pass the timing through
`animation` and `removal`, which is what the cover's removal waits on.

### Dismissing

Call `requestClose()` on any router to dismiss it. It works for both push and modal contexts:

```swift
// From a push router — pops from the navigation stack
model.router?.requestClose()

// From a modal router — dismisses the modal
model.router?.requestClose()
```

Both `PushRouter` and `ModalRouter` also conform to the `ClosableRouter` protocol, which provides a `close()` method — useful when you need a protocol-based reference to dismiss a router without knowing its concrete type:

```swift
let closable: any ClosableRouter = someRouter
closable.close()
```

### Switch Routers

Swap content without navigation transitions:

**Modal switch** -- replace modal content in-place:

```swift
final class MySwitchRouter: AnyModalSwitchRouter {
    let screenA: ModalRouter<...>
    let screenB: ModalRouter<...>

    func toggle() {
        current = (current === screenA) ? screenB : screenA
    }
}
```

**Push switch** -- replace pushed content in-place:

```swift
final class MyPushSwitch: AnyPushSwitchRouter {
    func toggle() {
        current = (current === screenA) ? screenB : screenA
    }
}
```

### Close Reason Routers

Use `ModalRouterWithCloseReason` or `PushRouterWithCloseReason` when a screen needs to communicate a reason for closing to its caller. The `onWillCloseWithReason` handler is called before dismissal, then the router automatically dismisses itself if still presented:

```swift
final class ColorPickerRouter: ModalRouterWithCloseReason<ColorPickerView, Color> {
    init(onWillCloseWithReason: ReasonHandler? = nil) {
        super.init(transition: .sheet, onWillCloseWithReason: onWillCloseWithReason)
    }

    override func makeModel() -> ColorPickerModel {
        ColorPickerModel(router: self)
    }
}

// Present and handle the close reason
let picker = ColorPickerRouter { color in
    self.selectedColor = color  // color is Color? — nil if closed without picking
}
stack?.presented = picker

// Inside the picker, close with a reason
requestClose(with: .blue)

// Or close without a reason (handler receives nil)
requestClose()
```

Note: `PushRouter<V>` and `ModalRouter<V>` are typealiases for the `Never` close reason case, meaning they have no typed close reason. They use a convenience initializer that accepts an optional `onWillClose: (() -> Void)?` callback.

## Deep Links

A deep link is the router tree built up front: create every router of the
chain, link them, and hang the first one off a router that is on screen —
pushes through `pushed`, presentations through `presented`, a stack inside a
sheet through a `NavigationStackRouter`. Moviro shows each screen once the one
under it is on screen: a push as soon as its stack is, a presentation one turn
after its presenter appears — which is what lets it wait for the transition
that brought the presenter in. Chains of any depth
land this way — push → push → sheet → popover → full screen with a stack →
push → push → sheet → sheet → full screen is the one the sample app opens.

```swift
let detail = DetailRouter()
let editor = EditorRouter()            // a sheet
let picker = PickerRouter()            // a sheet from the editor
home.pushed = detail
detail.presented = editor               // through the stack
editor.presented = picker
```

Every level animates by default — a push slides, a sheet rises — so a long
chain takes a moment to land. Turn `appearsAnimated` off on every router of
the chain but the last, and the link lands at once with only its last screen
moving:

```swift
detail.appearsAnimated = false
editor.appearsAnimated = false
// picker keeps the default and rises as usual
```

`appearsAnimated` is read whenever the router is pushed or presented, whether
its presenter is already on screen or shows it on appearing; leaving the
screen animates as usual.

## Helpers

### AlertRoutable

Conform your router to `AlertRoutable` to get a `showAlert(config:)` method that presents an `AlertRouter`:

```swift
final class MyRouter: PushRouter<MyView>, AlertRoutable {
    func confirmDelete() {
        showAlert(config: .init(
            title: "Delete?",
            message: "This action cannot be undone.",
            actions: [
                .init(title: "Cancel", role: .cancel),
                .init(title: "Delete", role: .destructive) {
                    // handle deletion
                }
            ]
        ))
    }
}
```

Default implementations are provided for both `AnyPushRouter` and `AnyModalRouter` conformers.

### ClosableRouter

A protocol that provides a simple `close()` method. Both `PushRouter` and `ModalRouter` conform to it automatically, making it useful for protocol-based dismissal.

## ModelComposer

`ModelComposer` manages a collection of weakly-held view models keyed by ID -- useful for list screens where each row has its own view model:

```swift
let composer = ModelComposer<Item.ID, ItemViewModel> { itemID in
    ItemViewModel(itemID: itemID)
}

// Update the list
composer.update(items: itemIDs)

// Get or create a view model for a specific item
let vm = composer.itemViewModel(for: item.id)
```

View models are created on demand and released when no longer retained externally.

## Model Lifecycle

`AnyModel` tracks appearance with reference counting, so nested views sharing the same model work correctly:

- `onAppear()` -- called once when the view first appears
- `onDisappear()` -- called once when the view fully disappears

Override these in your model subclasses for setup/teardown logic.

## View Modifiers

Moviro's own screens are built from three public modifiers, which you can also
apply to views Moviro does not build — a child model's view, or a router's
content hosted in a `UIHostingController` of your own:

| Modifier | What it does |
|---|---|
| `.appearance(of: model)` | Runs the model's `onAppear()` / `onDisappear()` with the view's appearance. `BaseView.with(model)` is `Self(model:)` plus this |
| `.presentations(of: modalRouter)` | Hangs the sheet, full-screen cover, popover and alert the router presents off the view. A presentation set before the view is on screen is asked for one turn after the view appears, so a chain of presets — a deep link — lands one level after another |
| `.pushDestination(of: pushRouter)` | Hangs the screen the router pushes off the view, through `navigationDestination(item:)` |

```swift
struct HomeView: BaseView {
    @State var model: HomeModel

    var body: some View {
        List { /* ... */ }
            .toolbar { HomeToolbar(model: model.toolbarModel) }
            .appearance(of: model.toolbarModel)   // a ToolbarContent cannot go through BaseView.with
    }
}
```

## Debug Logging

In `DEBUG` builds, Moviro automatically logs router and model lifecycle events:

```
🧩 [ROUTER] HomeRouter init
🧩 [MODEL] HomeModel init
💡 [MODEL] HomeModel appear
🫣 [MODEL] HomeModel disappear
☠️ [MODEL] HomeModel deinit
☠️ [ROUTER] HomeRouter deinit
```

## Project Structure

```
Sources/
├── Routers/               # The router tree
│   ├── AnyRouter.swift              # Base: identity, makeView()
│   ├── AnyModalRouter.swift         # presented / presenting, Transition
│   ├── AnyModalSwitchRouter.swift
│   ├── AnyNavigationStackRouter.swift
│   ├── AnyPushRouter.swift          # pushed / pushing, stack
│   ├── AnyPushSwitchRouter.swift
│   ├── AlertRouter.swift
│   ├── ModalPreviewRouter.swift
│   ├── ModalRouter.swift            # typealias of ModalRouterWithCloseReason<V, Never>
│   ├── PushRouter.swift             # typealias of PushRouterWithCloseReason<V, Never>
│   ├── ResultModalRouter.swift      # ModalRouterWithCloseReason
│   └── ResultPushRouter.swift       # PushRouterWithCloseReason
├── Views/                 # How routers become views
│   ├── Appearance.swift             # .appearance(of:)
│   ├── BaseView.swift
│   ├── ErasedScreen.swift           # the one type-erased view
│   ├── Presentations.swift          # .presentations(of:)
│   └── PushDestination.swift        # .pushDestination(of:)
├── Models/
│   ├── AnyModel.swift
│   ├── Model.swift
│   └── ModelComposer.swift
├── Helpers/               # Protocols and extensions
│   ├── AlertRoutable.swift
│   └── ClosableRouter.swift
└── Export.swift
```

> A full working sample app is available in the [Moviro Sample](https://github.com/ylapps/MoViRo-Sample) repository.

## License

Moviro is released under the [MIT License](LICENSE).
