//
//  SampleSplitRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Router

/// Demonstrates `AnySplitRouter` with a sidebar and a default detail placeholder.
final class SampleSplitRouter: AnySplitRouter {

    init() {
        super.init(
            style: .balanced,
            root: SidebarRouter(),
            transition: .fullScreen
        )
        defaultDetailsView = {
            AnyView(
                VStack(spacing: 16) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Select an item")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            )
        }
    }
}
