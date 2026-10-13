//
//  AnyRouter.swift
//  Moviro
//

import SwiftUI

@Observable
@MainActor
open class AnyRouter: Identifiable {

    // MARK: <Identifiable>

    public let id = UUID()

    // MARK: State

    /// Whether the screen moves into place when it is shown — the push
    /// slides, the sheet rises, the cover comes up. Off, the screen is simply
    /// there. Read when the router is pushed or presented, and when a
    /// presentation set before its presenter was on screen is shown by the
    /// presenter's appearance. Turn it off on every router of a deep link's
    /// chain but the last, and the link lands at once with only its last
    /// screen moving. Leaving the screen animates as usual.
    @ObservationIgnored
    public var appearsAnimated = true

    // MARK: Initialization

    init() {
        #if DEBUG
        print("🧩 [ROUTER] \(Self.self) init")
        #endif
    }
    deinit {
        #if DEBUG
        print("☠️ [ROUTER] \(Self.self) deinit")
        #endif
    }

    // MARK: Makers

    /// The router's screen, for whoever holds the router as an `AnyRouter`.
    /// Identified by the router, so replacing a parent's `pushed` or `presented`
    /// with another router of the same kind is a new screen with fresh state,
    /// not the old screen handed a new model.
    public final func makeView() -> some View {
        RouterScreen(router: self)
            .equatable()
            .id(id)
    }

    /// The screen, erased. Each concrete router composes its own in a
    /// statically typed `screen` and hands it over here; the bases are
    /// package-internal, so nothing outside Moviro ever implements this.
    func makeScreen() -> ErasedScreen {
        preconditionFailure("\(Self.self) must override makeScreen()")
    }
}

extension AnyRouter: Equatable {
    nonisolated public static func == (lhs: AnyRouter, rhs: AnyRouter) -> Bool {
        lhs.id == rhs.id
    }
}

extension AnyRouter: Hashable {

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
