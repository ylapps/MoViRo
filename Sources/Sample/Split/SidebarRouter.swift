//
//  SidebarRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Interface

@MainActor
protocol SidebarRouterInterface: SidebarDetailRoutable {}

// MARK: - Router

/// Push router for the sidebar. Pushes detail items within the split view.
final class SidebarRouter: PushRouter<SidebarView>, SidebarRouterInterface {

    override func makeModel() -> SidebarModel {
        SidebarModel(router: self)
    }
}
