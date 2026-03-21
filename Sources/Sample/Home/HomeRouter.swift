//
//  HomeRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Router

/// Push router for the home screen. Coordinates all navigation from the home view.
final class HomeRouter: PushRouter<HomeView> {

    override func makeModel() -> HomeModel {
        HomeModel(router: self)
    }

    // MARK: Push Navigation

    func pushDetail() {
        pushed = DetailRouter()
    }

    func pushSwitchScreen() {
        pushed = SamplePushSwitchRouter()
    }

    // MARK: Modal Navigation

    func presentSheet() {
        stack?.presented = SheetRouter()
    }

    func presentFullScreen() {
        stack?.presented = FullScreenRouter()
    }

    func presentModalSwitch() {
        stack?.presented = SampleModalSwitchRouter()
    }
}

// MARK: - Navigation Stack

/// Wraps the home push flow in a `NavigationStack`.
final class HomeNavigationStackRouter: NavigationStackRouter {

    init() {
        super.init(root: HomeRouter(), transition: .fullScreen)
    }
}
