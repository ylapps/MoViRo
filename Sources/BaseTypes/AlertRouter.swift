//
//  AlertRouter.swift
//  SUISimpleRouting
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI
import Combine

open class AlertRouter<ViewType: BaseView>: AnyAlertRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    // MARK: Initialization

    public override init(
        alertConfig: AlertConfig,
        presentedAlert: AnyAlertRouter? = nil
    ) {
        super.init(alertConfig: alertConfig, presentedAlert: presentedAlert)
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("Should be overriden")
    }

    override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}
