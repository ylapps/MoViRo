//
//  HomeRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Interface

@MainActor
protocol HomeRouterInterface:
    DetailRoutable,
    PushSwitchRoutable,
    SheetRoutable,
    FullScreenRoutable,
    ModalSwitchRoutable,
    WindowAlertRoutable,
    WindowToastRoutable {}

// MARK: - Router

/// Push router for the home screen. Coordinates all navigation from the home view.
final class HomeRouter: PushRouter<HomeView>, HomeRouterInterface {

    @ObservationIgnored
    weak var windowRouter: SampleWindowRouter?

    override func makeModel() -> HomeModel {
        HomeModel(router: self)
    }
}

// MARK: - Navigation Stack

/// Wraps the home push flow in a `NavigationStack`.
final class HomeNavigationStackRouter: NavigationStackRouter {

    let homeRouter: HomeRouter

    init() {
        let homeRouter = HomeRouter()
        self.homeRouter = homeRouter
        super.init(root: homeRouter, transition: .fullScreen)
    }
}
