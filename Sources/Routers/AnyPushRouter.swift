//
//  AnyPushRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyPushRouter: AnyRouter {

    /// How this router's screen is pushed; see `Transition`.
    public let transition: Transition

    /// Router pushed by this router. A router that asks not to animate its
    /// appearance (`appearsAnimated`) is pushed without the slide.
    public var pushed: AnyPushRouter? {
        get { pushedStorage }
        set {
            pushedStorage?.pushing = nil
            pushedStorage?.updateStack(with: nil)
            newValue?.pushing = self
            newValue?.updateStack(with: stack)
            guard newValue?.appearsAnimated == false else {
                pushedStorage = newValue
                return
            }
            withTransaction(\.disablesAnimations, true) {
                pushedStorage = newValue
            }
        }
    }

    private var pushedStorage: AnyPushRouter?

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

    init(transition: Transition = .automatic) {
        self.transition = transition
        super.init()
    }

    func updateStack(with newStack: AnyNavigationStackRouter?) {
        stack = newStack
        pushed?.updateStack(with: newStack)
    }
}

public extension AnyPushRouter {

    enum Transition: Hashable {
        /// The system push.
        case automatic
        /// The screen grows out of the view marked `zoomTransitionSource(id:)`
        /// with the same id in the same stack, and shrinks back into it when
        /// popped — on iOS 18 and later; before that, the system push. Fixed
        /// at the router's creation, since the destination reads it as it is
        /// built.
        case zoom(sourceID: AnyHashable)
    }
}
