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
        setupPresentationObserver()
    }
    
    private func setupPresentationObserver() {
        // Observe presentation changes to manage model appearance state
        isPresentedSub = $presented
            .removeDuplicates { $0?.id == $1?.id }
            .sink { [weak self] presented in
                guard let self = self else { return }
                
                if let presented = presented {
                    // If presenting a full screen modal, hide current model
                    if presented.transition == .fullScreen {
                        self.model.isAppeared = false
                    }
                } else if !self.model.isAppeared {
                    // If dismissing and model is not appeared, show it again
                    self.model.isAppeared = true
                }
            }
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("makeModel() must be overridden in subclass")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
