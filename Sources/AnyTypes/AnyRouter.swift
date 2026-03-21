//
//  AnyRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI

@Observable
@MainActor
open class AnyRouter: Identifiable {

    // MARK: <Identifiable>

    public let id = UUID()

    // MARK: Alert

    /// Set to a non-nil value to present an alert on this router's view.
    public var alert: AlertState?

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

    // MARK: Alert Convenience

    /// Presents an alert with the given title, optional message, and actions.
    public func presentAlert(
        title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        actions: [AlertState.Action] = []
    ) {
        alert = AlertState(title: title, message: message, actions: actions)
    }

    /// Dismisses the currently presented alert.
    public func dismissAlert() {
        alert = nil
    }

    // MARK: Makers

    func makeContentView() -> AnyView {
        fatalError("Should be overriden")
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
