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

    /// Router that pushed this router. Nil means self is root on navigation stack.
    @ObservationIgnored
    public internal(set) weak var pushing: AnyPushRouter?

    @ObservationIgnored
    public internal(set) weak var stack: AnyNavigationStackRouter?

    public var split: AnySplitRouter? {
        stack as? AnySplitRouter
    }

    init(pushed: AnyPushRouter? = nil) {
        self.pushed = pushed
        super.init()
        pushed?.pushing = self
    }

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
            .routerAlert($router.alert)
            .navigationDestination(item: $router.pushed) { pushed in
                pushed.makeView()
                    .fixedSplitNavigation(pushed: pushed)
            }
    }
}

// MARK: - Fix navigation in split view issue.
// TODO: Remove when Apple will fix one

private extension View {
    func fixedSplitNavigation(pushed: AnyPushRouter) -> some View {
        modifier(SplitNavigationFixModifier(pushed: pushed))
    }
}

private struct SplitNavigationFixModifier: ViewModifier {

    @Environment(\.horizontalSizeClass) private var sizeClass
    let pushed: AnyPushRouter

    func body(content: Content) -> some View {
        if let split = pushed.split, split.root == pushed.pushing, sizeClass != .compact {
            NavigationStack {
                pushed.makeView()
            }
            .id(pushed.id)
        } else {
            pushed.makeView()
        }
    }
}
