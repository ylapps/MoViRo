//
//  SampleAppRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - App Entry Point

/// Root router of the sample app. Demonstrates `TabBarRouter` with two tabs.
final class SampleAppRouter: AnyTabBarRouter {

    let homeStack: HomeNavigationStackRouter

    init() {
        let homeStack = HomeNavigationStackRouter()
        let splitTab = SampleSplitRouter()
        self.homeStack = homeStack

        super.init(tabs: [
            .init(
                router: homeStack,
                title: "Home",
                image: UIImage(systemName: "house")!
            ),
            .init(
                router: splitTab,
                title: "Split",
                image: UIImage(systemName: "sidebar.left")!
            )
        ])
    }
}

/// Convenience view for embedding the sample flow in a SwiftUI app or preview.
struct SampleRootView: View {

    @State private var router = SampleAppRouter()

    var body: some View {
        router.makeView()
    }
}

/// Convenience scene for embedding the sample flow with window support.
///
/// Use in your `App.body`:
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         SampleRootScene()
///     }
/// }
/// ```
struct SampleRootScene: Scene {

    @State private var router = SampleWindowRouter()

    var body: some Scene {
        router.makeScene()
    }
}

#Preview("Sample App") {
    SampleRootView()
}

#Preview("Sample App (Window Router)") {
    SampleWindowRouter().makeView()
}

