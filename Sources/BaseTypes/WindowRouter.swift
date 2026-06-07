//
//  WindowRouter.swift
//  Moviro
//

import SwiftUI

open class WindowRouter<ModelType: AnyModel>: AnyWindowRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    // MARK: Makers

    open func makeModel() -> ModelType {
        fatalError("Should be overriden")
    }
}
