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
        content.navigationDestination(item: $router.pushed) { PushedScreen(router: $0) }
    }
}

/// The pushed router's screen, with the navigation transition its router asks
/// for. The namespace comes from the stack's screen; outside one — a push
/// router hosted in a `NavigationStack` of your own — there is none, and the
/// zoom falls back to the system push.
private struct PushedScreen: View {

    let router: AnyPushRouter

    @Environment(\.stackNamespace) private var namespace

    var body: some View {
        if #available(iOS 18.0, *), case .zoom(let sourceID) = router.transition, let namespace {
            router.makeView()
                .navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            router.makeView()
        }
    }
}
