//
//  ZoomTransition.swift
//  Moviro
//

import SwiftUI

public extension View {

    /// Marks this view as the one a router pushed with
    /// `.zoom(sourceID:)` grows out of: the push zooms from this view and the
    /// pop shrinks back into it, matched by `id` (iOS 18 and later; a no-op
    /// before). The view has to be inside the stack the router is pushed on —
    /// a row, a card, a thumbnail of the thing the pushed screen shows.
    func zoomTransitionSource(id: some Hashable) -> some View {
        modifier(ZoomTransitionSource(id: AnyHashable(id)))
    }
}

struct ZoomTransitionSource: ViewModifier {

    let id: AnyHashable

    @Environment(\.stackNamespace) private var namespace

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), let namespace {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

// MARK: - Stack namespace

/// The namespace a stack's zoom transitions are matched in: set on the
/// `NavigationStack` by `AnyNavigationStackRouter`'s screen, read by every
/// pushed destination and by `zoomTransitionSource(id:)` below it.
extension EnvironmentValues {

    var stackNamespace: Namespace.ID? {
        get { self[StackNamespaceKey.self] }
        set { self[StackNamespaceKey.self] = newValue }
    }
}

private struct StackNamespaceKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}
