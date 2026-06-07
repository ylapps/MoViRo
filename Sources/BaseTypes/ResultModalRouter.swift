//
//  ResultModalRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 13.05.2026.
//

import SwiftUI

open class ResultModalRouter<ViewType: BaseView, ClosingResult>: AnyModalRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    /// Called with the result value just before the router closes.
    /// Set by the presenting router when creating this router.
    @ObservationIgnored
    public var onClose: ((ClosingResult) -> Void)?

    // MARK: Initialization

    public override init(transition: Transition, presented: AnyModalRouter? = nil) {
        super.init(transition: transition, presented: presented)
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

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}

// MARK: - Void Convenience

public extension ResultModalRouter where ClosingResult == Void {

    func requestClose() {
        requestClose(with: ())
    }
}
