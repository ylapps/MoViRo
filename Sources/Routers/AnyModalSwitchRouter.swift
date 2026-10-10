//
//  AnyModalSwitchRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyModalSwitchRouter: AnyModalRouter {

    public var current: AnyModalRouter {
        willSet {
            current.presenting = nil
            newValue.presenting = self
        }
    }

    public override var presented: AnyModalRouter? {
        get { current.presented }
        set { current.presented = newValue }
    }

    public init(current: AnyModalRouter, transition: Transition) {
        self.current = current
        super.init(transition: transition)
    }

    // MARK: Screen

    /// The current router's screen, and nothing else: `presented` forwards to
    /// `current`, whose own screen carries the presentations, so a second set
    /// here would bind the same sheet twice.
    var screen: some View {
        current.makeView()
    }

    override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}
