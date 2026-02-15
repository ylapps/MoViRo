//
//  AnyRouter.swift
//  SUISimpleRouting
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI

@MainActor
open class AnyRouter: Identifiable {

    // MARK: <Identifiable>

    public let id = UUID()

    // MARK: Initialization

    init() { debugLog("🧩 [ROUTER] \(Self.self) init") }
    deinit { debugLog("☠️ [ROUTER] \(Self.self) deinit") }

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
