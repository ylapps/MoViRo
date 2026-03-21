//
//  SidebarDetailRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Model

@Observable
final class SidebarDetailModel: Model<SidebarDetailRouter> {

    let title: String

    init(router: SidebarDetailRouter, title: String) {
        self.title = title
        super.init(router: router)
    }
}

// MARK: - Router

/// Push router for split view detail items.
final class SidebarDetailRouter: PushRouter<SidebarDetailView> {

    let title: String

    init(title: String) {
        self.title = title
        super.init()
    }

    override func makeModel() -> SidebarDetailModel {
        SidebarDetailModel(router: self, title: title)
    }
}
