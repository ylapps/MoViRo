//
//  SampleAppRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - App Entry Point

/// Root router of the sample app. Demonstrates `TabBarRouter` with two tabs.
final class SampleAppRouter: AnyTabBarRouter {

    init() {
        let homeStack = HomeNavigationStackRouter()
        let splitTab = SampleSplitRouter()

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

#Preview {
    SampleRootView()
}
