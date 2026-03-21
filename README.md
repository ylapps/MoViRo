# Moviro

**Model-View-Router** design pattern for iOS.

Moviro is a lightweight Swift framework that brings a clean, router-driven architecture to SwiftUI (and UIKit) apps. It separates navigation logic from views and business logic, giving you a composable tree of routers that own the entire navigation state.

## Requirements

- iOS 17+
- Swift 5.9+

## Installation

### Swift Package Manager

Add Moviro to your project via Xcode or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ylapps/Moviro.git", from: "1.0.0")
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
│   │   └── AnySplitRouter       Two-column NavigationSplitView
│   ├── AnyTabBarRouter          UITabBarController-style tabs
│   └── AnyModalSwitchRouter     Swap modal content without dismissing
└── AnyPushRouter                Push navigation via navigationDestination
    └── AnyPushSwitchRouter      Swap pushed content in-place
```

### Concrete Types (you subclass these)

| Type | Use For |
|---|---|
| `PushRouter<V>` | A screen inside a navigation stack |
| `ModalRouter<V>` | A screen presented as a modal |
| `NavigationStackRouter` | Wrapping a push flow in `NavigationStack` |
| `TabBarRouter` | Tab-based root navigation |

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
        stack?.presented = SheetRouter()
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

Present modals through the navigation stack's `presented` property. The modal transition is defined at the router level:

```swift
// Sheet
final class SheetRouter: ModalRouter<SheetView>, ClosableRouter {
    init() {
        super.init(transition: .sheet)
    }
    // ...
}

// Full screen
final class FullScreenRouter: ModalRouter<FullScreenView>, ClosableRouter {
    init() {
        super.init(transition: .fullScreen)
    }
    // ...
}

// Popover
final class PopoverRouter: ModalRouter<PopoverView>, ClosableRouter {
    init() {
        super.init(transition: .popover)
    }
    // ...
}
```

Present from any push router:

```swift
func presentSheet() {
    stack?.presented = SheetRouter()
}
```

### Dismissing (ClosableRouter)

Conform to `ClosableRouter` to get a `close()` method that works for both push and modal contexts:

```swift
final class DetailRouter: PushRouter<DetailView>, ClosableRouter {
    // close() pops from the navigation stack
}

final class SheetRouter: ModalRouter<SheetView>, ClosableRouter {
    // close() dismisses the modal
}
```

### Alerts

Present data-driven alerts through `AlertState`:

```swift
func showAlert() {
    presentAlert(
        title: "Delete Item?",
        message: "This action cannot be undone.",
        actions: [
            .init(title: "Cancel", role: .cancel),
            .init(title: "Delete", role: .destructive) {
                self.deleteItem()
            }
        ]
    )
}
```

### Tab Bar

Use `TabBarRouter` (typealias for `AnyTabBarRouter`) to create tab-based navigation:

```swift
final class AppRouter: AnyTabBarRouter {
    init() {
        super.init(tabs: [
            .init(
                router: HomeNavigationStackRouter(),
                title: "Home",
                image: UIImage(systemName: "house")!
            ),
            .init(
                router: SettingsNavigationStackRouter(),
                title: "Settings",
                image: UIImage(systemName: "gear")!
            )
        ])
    }
}
```

### Split View

Use `AnySplitRouter` for two-column iPad layouts:

```swift
final class MySplitRouter: AnySplitRouter {
    init() {
        super.init(
            style: .balanced,
            root: SidebarRouter(),
            transition: .fullScreen
        )
        defaultDetailsView = {
            AnyView(Text("Select an item"))
        }
    }
}
```

The sidebar's `pushed` property controls what appears in the detail column.

### Switch Routers

Swap content without navigation transitions:

**Modal switch** -- replace modal content in-place:

```swift
final class MySwitchRouter: AnyModalSwitchRouter, ClosableRouter {
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

## UIKit Support

Moviro includes bridging types for UIKit integration, so you can use UIKit view controllers within the router tree.

### ViewController

A `UIViewController` subclass conforming to `ModelHolding`, with structured lifecycle hooks:

```swift
class ProfileViewController: ViewController<ProfileModel> {
    override func setupHierarchy() { /* add subviews */ }
    override func setupLayout()    { /* add constraints */ }
    override func setupViews()     { /* configure views */ }
    override func setupBinding()   { /* bind to model */ }
}
```

### CollectionViewController

Same pattern for `UICollectionViewController`, with a customizable layout:

```swift
class ListViewController: CollectionViewController<ListModel> {
    override func makeCollectionViewLayout() -> UICollectionViewLayout {
        // Return your compositional layout
    }
}
```

### UIKitContent

Bridges any `UIViewController & ModelHolding` into SwiftUI so it works as a `BaseView`:

```swift
// Use a UIKit VC anywhere a BaseView is expected
typealias ProfileView = UIKitContent<ProfileViewController>

final class ProfileRouter: PushRouter<ProfileView> {
    override func makeModel() -> ProfileModel {
        ProfileModel(router: self)
    }
}
```

### CollectionViewCell & CollectionSupplementaryView

Generic `UICollectionViewCell` and `UICollectionReusableView` subclasses that render any `BaseView` via `UIHostingConfiguration`. Set the `model` property and the cell handles the rest:

```swift
class MyCell: CollectionViewCell<MyCellView> {}

// In your data source:
cell.model = cellModel
cell.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
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
│   ├── AlertState.swift
│   ├── AnyModel.swift
│   ├── AnyRouter.swift
│   ├── AnyModalRouter.swift
│   ├── AnyModalSwitchRouter.swift
│   ├── AnyNavigationStackRouter.swift
│   ├── AnyPushRouter.swift
│   ├── AnyPushSwitchRouter.swift
│   ├── AnySplitRouter.swift
│   └── AnyTabBarRouter.swift
├── BaseTypes/             # Concrete types you subclass
│   ├── BaseView.swift
│   ├── ClosableRouter.swift
│   ├── Model.swift
│   ├── ModelComposer.swift
│   ├── ModalPreviewRouter.swift
│   ├── ModalRouter.swift
│   └── PushRouter.swift
├── UIKitSupport/          # UIKit bridging
│   ├── CollectionSupplementaryView.swift
│   ├── CollectionViewCell.swift
│   ├── CollectionViewController.swift
│   ├── UIKitContent.swift
│   └── ViewController.swift
├── Sample/                # Working sample app
│   ├── SampleAppRouter.swift
│   ├── Home/
│   ├── Detail/
│   ├── Modals/
│   ├── Split/
│   └── Switch/
└── Export.swift
```

## License

Moviro is released under the [MIT License](LICENSE).
