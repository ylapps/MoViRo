//
//  Model.swift
//  Moviro
//

import Foundation

// MARK: - Model

open class Model<Router>: AnyModel {

    public let id = UUID()
    private var routerWrapper: WeakAnySemanticWrapper<Router>?
    public var router: Router? { routerWrapper?.wrapped }

    // MARK: Initialization

    public init(router: Router?) {
        if let router {
            self.routerWrapper = .init(wrapped: router)
        }
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

// MARK: - WeakAnySemanticWrapper

/// Holds a class router weakly and a value router strongly. `Router` is
/// almost always a protocol existential (`any HomeRouterInterface`), and a
/// class-bound existential does not satisfy `Router: AnyObject` as a generic
/// constraint, so the weak reference has to be untyped and the read a cast —
/// one conformance lookup per router type, cached by the runtime after that.
private struct WeakAnySemanticWrapper<T> {

    private weak var object: AnyObject?
    private var value: T?

    var wrapped: T? {
        value ?? object as? T
    }

    init(wrapped: T) {
        if type(of: wrapped as Any) is AnyObject.Type {
            object = wrapped as AnyObject
        } else {
            value = wrapped
        }
    }
}
