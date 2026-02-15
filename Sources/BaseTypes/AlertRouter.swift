//
//  AlertRouter.swift
//  
//
//  Created on 14.09.2025.
//

import SwiftUI

open class AlertRouter<ViewType: BaseView>: AnyAlertRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    // MARK: Initialization

    public override init(presented: AnyAlertRouter? = nil) {
        super.init(presented: presented)
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}