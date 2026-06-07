//
//  PopoverRouter.swift
//  Moviro
//

import SwiftUI

// MARK: - Routable

@MainActor
protocol PopoverRoutable {
    func showPopover()
}

extension PopoverRoutable where Self: AnyModalRouter {
    func showPopover() {
        presented = PopoverRouter()
    }
}

extension PopoverRoutable where Self: AnyPushRouter {
    func showPopover() {
        stack?.presented = PopoverRouter()
    }
}

// MARK: - Model

@Observable
final class PopoverModel: Model<PopoverRouter> {}

// MARK: - Router

/// Modal router using `.popover` transition.
final class PopoverRouter: ModalRouter<PopoverView> {

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
