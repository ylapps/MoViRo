//
//  PushRouter.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

open class PushRouter<ViewType: BaseView>: AnyPushRouter {

    // MARK: State

    public private(set) lazy var model = makeModel()

    // MARK: Initialization

    public override init(pushed: AnyPushRouter? = nil) {
        super.init(pushed: pushed)
    }

    // MARK: Makers

    open func makeModel() -> ViewType.Model {
        fatalError("makeModel() must be overridden in subclass")
    }

    final override func makeContentView() -> AnyView {
        .init(ViewType.with(model))
    }
}

public typealias NavigationStackRouter = AnyNavigationStackRouter
public typealias TabBarRouter = AnyTabBarRouter
