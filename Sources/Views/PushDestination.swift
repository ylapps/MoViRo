//
//  PushDestination.swift
//  Moviro
//

import SwiftUI

public extension View {

    /// Hangs the screen that `router` pushes off this view, through
    /// `navigationDestination(item:)`. Moviro applies it to every push router's
    /// own screen, which is what lets a parent pop a whole chain by clearing
    /// one `pushed`.
    func pushDestination(of router: AnyPushRouter) -> some View {
        modifier(PushDestination(router: router))
    }
}

struct PushDestination: ViewModifier {

    @Bindable var router: AnyPushRouter

    func body(content: Content) -> some View {
        content.navigationDestination(item: $router.pushed) { $0.makeView() }
    }
}
