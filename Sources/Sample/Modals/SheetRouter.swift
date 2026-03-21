//
//  SheetRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Model

@Observable
final class SheetModel: Model<SheetRouter> {}

// MARK: - Router

/// Modal router using `.sheet` transition. Conforms to `ClosableRouter`.
final class SheetRouter: ModalRouter<SheetView>, ClosableRouter {

    init() {
        super.init(transition: .sheet)
    }

    override func makeModel() -> SheetModel {
        SheetModel(router: self)
    }
}
