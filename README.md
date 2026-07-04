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
    .package(url: "https://github.com/ylapps/MoViRo.git", from: "1.1.0")
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

### Concrete Types (you subclass these)

| Type | Use For |
|---|---|
| `PushRouter<V>` | A screen inside a navigation stack |
| `ModalRouter<V>` | A screen presented as a modal |
| `NavigationStackRouter` | Wrapping a push flow in `NavigationStack` |
| `ResultModalRouter<V, R>` | Modal that returns a typed result |
| `ResultPushRouter<V, R>` | Push screen that returns a typed result |

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

### Dismissing

Call `requestClose()` on any router to dismiss it. It works for both push and modal contexts:

```swift
// From a push router — pops from the navigation stack
model.router?.requestClose()

// From a modal router — dismisses the modal
model.router?.requestClose()
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

### Result Routers

Use `ResultModalRouter` or `ResultPushRouter` when a screen needs to return a typed result to its caller. The `onClose` callback is injected at construction time:

```swift
final class ColorPickerRouter: ResultModalRouter<ColorPickerView, Color> {
    init(onClose: ((Color) -> Void)? = nil) {
        super.init(transition: .sheet, onClose: onClose)
    }

    override func makeModel() -> ColorPickerModel {
        ColorPickerModel(router: self)
    }
}

// Present and handle the result
let picker = ColorPickerRouter { color in
    self.selectedColor = color
}
stack?.presented = picker
```

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
├── AnyTypes/              # Base observable classes (type-erased layer)
│   ├── AnyModel.swift
│   ├── AnyRouter.swift
│   ├── AnyModalRouter.swift
│   ├── AnyModalSwitchRouter.swift
│   ├── AnyNavigationStackRouter.swift
│   ├── AnyPushRouter.swift
│   └── AnyPushSwitchRouter.swift
├── BaseTypes/             # Concrete types you subclass
│   ├── BaseView.swift
│   ├── Model.swift
│   ├── ModelComposer.swift
│   ├── ModalPreviewRouter.swift
│   ├── ModalRouter.swift
│   ├── PushRouter.swift
│   ├── ResultModalRouter.swift
│   └── ResultPushRouter.swift
└── Export.swift
```

> A full working sample app is available in the [Moviro Sample](https://github.com/ylapps/MoViRo-Sample) repository.

## License

Moviro is released under the [MIT License](LICENSE).
