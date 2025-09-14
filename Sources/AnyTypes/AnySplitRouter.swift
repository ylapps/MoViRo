//
//  AnySplitRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 18.02.2025.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnySplitRouter: AnyNavigationStackRouter {

    public enum Style: Hashable {
        case automatic
        case balanced
        case prominentDetail
    }

    public var columnVisibility: NavigationSplitViewVisibility
    public var preferredCompactColumn: NavigationSplitViewColumn
    public let defaultDetailsView: (() -> AnyView)?

    @ObservationIgnored
    public var style: Style

    public init(
        columnVisibility: NavigationSplitViewVisibility = .all,
        preferredCompactColumn: NavigationSplitViewColumn = .sidebar,
        defaultDetailsView: (() -> AnyView)? = nil,
        style: Style = .automatic,
        root: AnyPushRouter,
        transition: Transition = .fullScreen,
        presented: AnyModalRouter? = nil
    ) {
        self.columnVisibility = columnVisibility
        self.preferredCompactColumn = preferredCompactColumn
        self.defaultDetailsView = defaultDetailsView
        self.style = style
        super.init(root: root, transition: transition, presented: presented)
    }

    override func makeContentView() -> AnyView {
        .init(AnySplitView(router: self))
    }
}

// MARK: - View

private struct AnySplitView: View {

    @State var router: AnySplitRouter

    var body: some View {
        NavigationSplitView(
            columnVisibility: $router.columnVisibility,
            preferredCompactColumn: $router.preferredCompactColumn,
            sidebar: {
                router.root.makeView()
            },
            detail: {
                if let defaultDetailsView = router.defaultDetailsView {
                    defaultDetailsView()
                }
            }
        )
        .withSplitStyle(router.style)
    }
}

private extension View {

    @ViewBuilder
    @inline(__always)
    func withSplitStyle(_ style: AnySplitRouter.Style) -> some View {
        switch style {
        case .automatic:
            navigationSplitViewStyle(.automatic)
        case .balanced:
            navigationSplitViewStyle(.balanced)
        case .prominentDetail:
            navigationSplitViewStyle(.prominentDetail)
        }
    }
}
