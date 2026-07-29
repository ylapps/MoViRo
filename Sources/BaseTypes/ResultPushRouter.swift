//
//  ResultPushRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 13.05.2026.
//

import SwiftUI

open class PushRouterWithCloseReason<ViewType: BaseView, CloseReason>: AnyPushRouter {

    public typealias ReasonHandler = (CloseReason?) -> Void

    // MARK: State

    @ObservationIgnored
    public private(set) lazy var model = makeModel()

    /// Called with the result value just before the router closes.
    /// Set by the presenting router when creating this router.
    private let onWillClose: ReasonHandler?

    // MARK: Initialization

    public init(onWillCloseWithReason: ReasonHandler?) {
        self.onWillClose = onWillCloseWithReason
        super.init()
    }

    public init(onWillClose: (() -> Void)? = nil) where CloseReason == Never {
        self.onWillClose = { _ in onWillClose?() }
        super.init()
    }

    // MARK: Result Closing

    /// Delivers the result to `onClose` if set; otherwise dismisses this router.
    public func requestClose(with reason: CloseReason? = nil) {
        onWillClose?(reason)
        if pushing?.pushed == self {
            pushing?.pushed = nil
        } else if stack?.root == self {
            stack?.presenting?.presented = nil
        }
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    final override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
