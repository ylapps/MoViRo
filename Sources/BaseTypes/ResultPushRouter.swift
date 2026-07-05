//
//  ResultPushRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 13.05.2026.
//

import SwiftUI

open class ResultPushRouter<ViewType: BaseView, ClosingResult>: AnyPushRouter {

    // MARK: State

    @ObservationIgnored
    public private(set) lazy var model = makeModel()

    /// Called with the result value just before the router closes.
    /// Set by the presenting router when creating this router.
    private let onClose: ((ClosingResult) -> Void)?

    // MARK: Initialization

    public init(onClose: ((ClosingResult) -> Void)? = nil) {
        self.onClose = onClose
        super.init()
    }

    // MARK: Result Closing

    /// Delivers the result to `onClose` if set; otherwise dismisses this router.
    public func requestClose(with result: ClosingResult) {
        if let onClose {
            onClose(result)
        } else {
            guard let pushing else {
                stack?.presenting?.presented = nil
                return
            }
            pushing.pushed = nil
        }
    }

    /// Delivers the result to `onClose` if set; otherwise dismisses this router.
    public func requestClose() where ClosingResult == Void {
        requestClose(with: ())
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    final override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
