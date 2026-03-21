//
//  FullScreenRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Model

@Observable
final class FullScreenModel: Model<FullScreenRouter> {}

// MARK: - Router

/// Modal router using `.fullScreen` transition. Conforms to `ClosableRouter`.
final class FullScreenRouter: ModalRouter<FullScreenView>, ClosableRouter {

    init() {
        super.init(transition: .fullScreen)
    }

    override func makeModel() -> FullScreenModel {
        FullScreenModel(router: self)
    }
}
