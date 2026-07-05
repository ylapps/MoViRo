//
//  ResultModalRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 13.05.2026.
//

import SwiftUI

open class ResultModalRouter<ViewType: BaseView, ClosingResult>: AnyModalRouter {

    // MARK: State

    @ObservationIgnored
    public private(set) lazy var model = makeModel()

    /// Called with the result value just before the router closes.
    /// Set by the presenting router when creating this router.
    private let onClose: ((ClosingResult) -> Void)?

    // MARK: Initialization

    public init(transition: Transition, onClose: ((ClosingResult) -> Void)? = nil) {
        self.onClose = onClose
        super.init(transition: transition)
    }

    // MARK: Result Closing

    /// Delivers the result to `onClose` if set; otherwise dismisses this router.
    public func requestClose(with result: ClosingResult) {
        if let onClose {
            onClose(result)
        } else {
            presenting?.presented = nil
        }
    }

    public func requestClose() where ClosingResult == Void {
        requestClose(with: ())
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
