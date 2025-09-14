//
//  Model.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import Foundation

open class Model<Router>: AnyModel, Identifiable {

    public let id = UUID()

    private var routerWrapper: WeakAnySemanticWrapper<Router>?

    public var router: Router? { routerWrapper?.wrapped }

    // MARK: Initialization

    public init(router: Router?) {
        if let router {
            self.routerWrapper = .init(wrapped: router)
        }
        super.init()
    }

    public init() where Router == Never {}
}

extension Model: Equatable {

    nonisolated public static func == (lhs: Model<Router>, rhs: Model<Router>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Model: Hashable {

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Convenience Methods

public extension Model {
    
    /// Safely executes a block with the router if available
    func withRouter<T>(_ block: (Router) throws -> T) rethrows -> T? {
        guard let router = router else { return nil }
        return try block(router)
    }
    
    /// Checks if the model has an active router connection
    var hasActiveRouter: Bool {
        router != nil
    }
}

private struct WeakAnySemanticWrapper<T> {
    private weak var object: AnyObject?
    private var value: T?
    private let isClass: Bool

    var wrapped: T? {
        isClass ? object as? T : value
    }

    init(wrapped: T) {
        // Cache the class check result to avoid repeated Mirror calls
        self.isClass = Mirror(reflecting: wrapped).displayStyle == .class
        if isClass {
            object = wrapped as AnyObject
        } else {
            value = wrapped
        }
    }
}
