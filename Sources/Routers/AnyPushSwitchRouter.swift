//
//  AnyPushSwitchRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyPushSwitchRouter: AnyPushRouter {

    public var current: AnyPushRouter {
        willSet {
            current.pushing = nil
            current.updateStack(with: nil)
            newValue.pushing = pushing
            newValue.updateStack(with: stack)
        }
    }

    public override var pushed: AnyPushRouter? {
        get { current.pushed }
        set { current.pushed = newValue }
    }

    public init(current: AnyPushRouter) {
        self.current = current
        super.init()
    }

    override func updateStack(with newStack: AnyNavigationStackRouter?) {
        super.updateStack(with: newStack)
        current.updateStack(with: newStack)
    }

    // MARK: Screen

    /// The current router's screen, destination included; `pushed` forwards
    /// to `current`, so that one destination is the switch's too.
    var screen: some View {
        current.makeView()
    }

    override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}
