//
//  SidebarRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Router

/// Push router for the sidebar. Pushes detail items within the split view.
final class SidebarRouter: PushRouter<SidebarView> {

    override func makeModel() -> SidebarModel {
        SidebarModel(router: self)
    }

    func pushDetail(title: String) {
        pushed = SidebarDetailRouter(title: title)
    }
}
