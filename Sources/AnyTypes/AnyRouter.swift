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

    public let id: UUID = UUID() // Use UUID directly instead of String for better performance

    // MARK: Initialization

    init() { 
        MoviroLogger.logInit(Self.self, category: .router)
    }
    
    deinit { 
        MoviroLogger.logDeinit(Self.self, category: .router)
    }

    // MARK: Makers

    func makeContentView() -> AnyView {
        fatalError("makeContentView() must be overridden in subclass")
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
