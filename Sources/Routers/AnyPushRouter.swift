//
//  AnyPushRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyPushRouter: AnyRouter {

    /// Router pushed by this router
    public var pushed: AnyPushRouter? {
        willSet {
            pushed?.pushing = nil
            pushed?.updateStack(with: nil)
            newValue?.pushing = self
            newValue?.updateStack(with: stack)
        }
    }

    /// A push router presents through its stack, so a sheet survives the
    /// screen that asked for it being popped.
    @ObservationIgnored
    public var presented: AnyModalRouter? {
        get { stack?.presented }
        set { stack?.presented = newValue }
    }

    /// Router that pushed this router. Nil means self is root on navigation stack.
    @ObservationIgnored
    weak var pushing: AnyPushRouter?

    @ObservationIgnored
    weak var stack: AnyNavigationStackRouter?

    func updateStack(with newStack: AnyNavigationStackRouter?) {
        stack = newStack
        pushed?.updateStack(with: newStack)
    }
}
