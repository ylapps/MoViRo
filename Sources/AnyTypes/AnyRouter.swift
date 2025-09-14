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

    public let id: String = UUID().uuidString

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

    func makeContentView() -> AnyView {
        fatalError("Should be overriden")
    }
}

extension AnyRouter: Equatable {
    @inlinable
    nonisolated public static func == (lhs: AnyRouter, rhs: AnyRouter) -> Bool {
        lhs.id == rhs.id
    }
}

extension AnyRouter: Hashable {

    @inlinable
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
