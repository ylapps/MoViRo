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
        StackScreen(router: self)
            .presentations(of: self)
    }

    override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}

/// The `NavigationStack` and the namespace its zoom push transitions are
/// matched in — a `@Namespace` lives only in a view, which is why the stack
/// is built here rather than in the router's `screen` directly.
private struct StackScreen: View {

    let router: AnyNavigationStackRouter

    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            router.root.makeView()
        }
        .environment(\.stackNamespace, namespace)
    }
}
