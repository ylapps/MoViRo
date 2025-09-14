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

    @inlinable
    nonisolated public static func == (lhs: Model<Router>, rhs: Model<Router>) -> Bool {
        lhs.id == rhs.id
    }
}

extension Model: Hashable {

    @inlinable
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private struct WeakAnySemanticWrapper<T> {
    private weak var object: AnyObject?
    private var value: T?

    @inlinable
    var wrapped: T? {
        value ?? (object as? T)
    }

    // Value-semantic initializer (structs/enums)
    @inlinable
    init(wrapped: T) {
        self.value = wrapped
    }
}

private extension WeakAnySemanticWrapper where T: AnyObject {

    // Reference-semantic initializer (classes)
    @inlinable
    init(wrapped: T) {
        self.object = wrapped
    }
}
