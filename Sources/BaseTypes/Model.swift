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
        self.routerWrapper = router.map { .init(wrapped: $0) }
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

private struct WeakAnySemanticWrapper<T> {
    private weak var object: AnyObject?
    private let value: T?

    var wrapped: T? {
        if let object = object {
            return object as? T
        }
        return value
    }

    init(wrapped: T) {
        if type(of: wrapped as Any) is AnyClass {
            self.object = wrapped as AnyObject
            self.value = nil
        } else {
            self.object = nil
            self.value = wrapped
        }
    }
}
