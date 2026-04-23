//
//  SheetRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol SheetRoutable {
    func showSheet()
}

extension SheetRoutable where Self: AnyModalRouter {
    func showSheet() {
        presented = SheetRouter()
    }
}

extension SheetRoutable where Self: AnyPushRouter {
    func showSheet() {
        stack?.presented = SheetRouter()
    }
}

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
