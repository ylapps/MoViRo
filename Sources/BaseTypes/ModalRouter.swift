//
//  ModalRouter.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

open class ModalRouter<ViewType: BaseView>: AnyModalRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    // MARK: Initialization

    public override init(
        transition: AnyModalRouter.Transition,
        presented: AnyModalRouter? = nil
    ) {
        super.init(transition: transition, presented: presented)
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
