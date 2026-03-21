//
//  PopoverRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Model

@Observable
final class PopoverModel: Model<PopoverRouter> {}

// MARK: - Router

/// Modal router using `.popover` transition. Conforms to `ClosableRouter`.
final class PopoverRouter: ModalRouter<PopoverView>, ClosableRouter {

    init(
        attachmentAnchor: PopoverAttachmentAnchor = .point(.center),
        arrowEdge: Edge? = .top
    ) {
        super.init(transition: .popover(attachmentAnchor: attachmentAnchor, arrowEdge: arrowEdge))
    }

    override func makeModel() -> PopoverModel {
        PopoverModel(router: self)
    }
}
