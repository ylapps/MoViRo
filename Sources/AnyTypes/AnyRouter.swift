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

    init() {}
    deinit {}

    // MARK: Makers

    func makeContentView() -> AnyView {
        fatalError("Should be overriden")
    }
}

extension AnyRouter: Equatable {
    nonisolated public static func == (lhs: AnyRouter, rhs: AnyRouter) -> Bool {
        lhs === rhs
    }
}

extension AnyRouter: Hashable {

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
