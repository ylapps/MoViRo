//
//  AnyNavigationStackRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyNavigationStackRouter: AnyModalRouter {

    public var root: AnyPushRouter {
        willSet {
            root.updateStack(with: nil)
            newValue.updateStack(with: self)
        }
    }

    public init(root: AnyPushRouter, transition: Transition) {
        self.root = root
        super.init(transition: transition)
        root.updateStack(with: self)
    }

    // MARK: Screen

    /// The stack's presentations sit outside the `NavigationStack`, which is
    /// where a sheet asked for by any pushed screen is shown from.
    var screen: some View {
        NavigationStack {
            root.makeView()
        }
        .presentations(of: self)
    }

    override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}
