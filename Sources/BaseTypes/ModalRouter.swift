//
//  ModalRouter.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI
import Combine

open class ModalRouter<ViewType: BaseView>: AnyModalRouter {

    // MARK: State

    private var isPresentedSub: AnyCancellable?
    public private(set) lazy var model = makeModel()

    // MARK: Initialization

    public override init(
        transition: AnyModalRouter.Transition,
        presented: AnyModalRouter? = nil
    ) {
        super.init(transition: transition, presented: presented)
//        isPresentedSub = $presented
//            .removeDuplicates()
//            .sink { [unowned self] presented in
//                if let presented {
//                    if presented.transition == .fullScreen {
//                        model.isAppeared = false
//                    }
//                } else if !model.isAppeared {
//                    model.isAppeared = true
//                }
//            }
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
