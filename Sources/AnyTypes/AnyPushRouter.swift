//
//  AnyPushRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
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

    public final func makeView() -> some View {
        AnyPushView(router: self)
    }

    func updateStack(with newStack: AnyNavigationStackRouter?) {
        stack = newStack
        pushed?.updateStack(with: newStack)
    }
}

// MARK: - View

private struct AnyPushView: View {

    @State var router: AnyPushRouter

    var body: some View {
        router.makeContentView()
            .navigationDestination(item: $router.pushed) { pushed in
                pushed.makeView()
            }
    }
}
