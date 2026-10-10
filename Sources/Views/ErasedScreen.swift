//
//  ErasedScreen.swift
//  Moviro
//

import SwiftUI

/// The one type-erased view in Moviro.
///
/// A router tree is open: a parent holds its children as `AnyPushRouter` /
/// `AnyModalRouter`, and `.sheet(item:)` / `.navigationDestination(item:)`
/// need a single view type for whatever child turns up. That type is this one.
/// Everything *around* the erasure — the presentation and push-destination
/// modifiers, the appearance tracking, the `NavigationStack` — is statically
/// typed; only the hand-off from a router to the screen it describes is not.
///
/// The erasure is applied once per screen, and the dynamic type behind it never
/// changes for a given router, so SwiftUI keeps the screen's identity and state
/// across updates (an `AnyView` rebuilds its hierarchy only when the type it
/// wraps changes).
struct ErasedScreen: View {

    private let screen: AnyView

    init(_ screen: some View) {
        self.screen = AnyView(screen)
    }

    var body: some View {
        screen
    }
}

/// Asks the router for its screen. Equatable by router identity, so a parent
/// re-evaluating its body with the same router does not rebuild the screen —
/// only the router's own observed changes (a switch router's `current`, a
/// stack's `root`) re-run this body.
struct RouterScreen: View, Equatable {

    let router: AnyRouter

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.router === rhs.router
    }

    var body: some View {
        router.makeScreen()
    }
}
