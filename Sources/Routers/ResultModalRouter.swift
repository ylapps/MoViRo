//
//  ResultModalRouter.swift
//  Moviro
//

import SwiftUI

open class ModalRouterWithCloseReason<ViewType: BaseView, CloseReason>: AnyModalRouter {

    public typealias ReasonHandler = (CloseReason?) -> Void

    // MARK: State

    @ObservationIgnored
    public private(set) lazy var model = makeModel()

    /// Called with the result value just before the router closes.
    /// Set by the presenting router when creating this router.
    private let onWillClose: ReasonHandler?

    // MARK: Initialization

    public init(transition: Transition, onWillCloseWithReason: ReasonHandler?) {
        self.onWillClose = onWillCloseWithReason
        super.init(transition: transition)
    }

    public init(transition: AnyModalRouter.Transition, onWillClose: (() -> Void)? = nil) where CloseReason == Never {
        self.onWillClose = { _ in onWillClose?() }
        super.init(transition: transition)
    }

    // MARK: Result Closing

    /// Delivers the reason to `onWillClose` if set and dismisses this router if still presented after reason handling.
    public func requestClose(with reason: CloseReason? = nil) {
        onWillClose?(reason)
        /// Dismiss if still presented after handling the reason
        guard presenting?.presented == self else { return }
        presenting?.presented = nil
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    // MARK: Screen

    var screen: some View {
        ViewType(model: model)
            .appearance(of: model)
            .presentations(of: self)
    }

    final override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}
