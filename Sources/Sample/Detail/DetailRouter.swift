//
//  DetailRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol DetailRoutable {
    func showDetail()
}

extension DetailRoutable where Self: AnyPushRouter {
    func showDetail() {
        pushed = DetailRouter()
    }
}

// MARK: - Interface

@MainActor
protocol DetailRouterInterface:
    SheetRoutable,
    FullScreenRoutable,
    PopoverRoutable {}

// MARK: - Router

/// Push router for the detail screen. Demonstrates `requestClose()` for popping
/// and presenting various modal transitions.
final class DetailRouter: PushRouter<DetailView>, DetailRouterInterface {

    override func makeModel() -> DetailModel {
        DetailModel(router: self)
    }


}
