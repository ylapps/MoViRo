//
//  AnyPushRouter.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

@Observable
open class AnyPushRouter: AnyRouter {

    /// Router pushed by this router
    public var pushed: AnyPushRouter? {
        willSet {
            // Clean up old relationships first
            if let oldPushed = pushed {
                oldPushed.pushing = nil
                oldPushed.stack = nil
            }
            
            // Set up new relationships
            if let newPushed = newValue {
                newPushed.pushing = self
                newPushed.stack = stack
            }
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
    }

    public final func makeView() -> some View {
        AnyPushView(router: self)
    }
    
    // MARK: - Navigation Convenience Methods
    
    /// Pushes a router onto the navigation stack
    public func push(_ router: AnyPushRouter) {
        pushed = router
    }
    
    /// Pops the current router from the navigation stack
    public func pop() {
        pushed = nil
    }
    
    /// Pops to the root of the navigation stack
    public func popToRoot() {
        var current = self
        while let pushing = current.pushing {
            current = pushing
        }
        current.pushed = nil
    }
    
    /// Returns the depth of the navigation stack
    public var navigationDepth: Int {
        var depth = 0
        var current = self
        while let pushed = current.pushed {
            depth += 1
            current = pushed
        }
        return depth
    }
}

// MARK: - View

private struct AnyPushView: View {

    @State var router: AnyPushRouter

    var body: some View {
        router.makeContentView()
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

    @State var pushed: AnyPushRouter

    func body(content: Content) -> some View {
        if let split = pushed.split, split.root == pushed.pushing {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }
}
