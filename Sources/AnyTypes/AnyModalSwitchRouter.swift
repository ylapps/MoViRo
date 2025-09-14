//
//  AnySwitchModalRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 28.11.2024.
//

import SwiftUI
import Observation

@Observable
open class AnyModalSwitchRouter: AnyModalRouter {

    public var current: AnyModalRouter {
        willSet {
            current.presenting = nil
            newValue.presenting = self
        }
    }

    public override var presented: AnyModalRouter? {
        get { current.presented }
        set { current.presented = newValue }
    }

    public init(current: AnyModalRouter, transition: Transition) {
        self.current = current
        super.init(transition: transition)
    }

    override final func makeContentView() -> AnyView {
        .init(AnyModalSwitchView(router: self))
    }
}

private struct AnyModalSwitchView: View {

    @Bindable var router: AnyModalSwitchRouter

    var body: some View {
        router.current.makeView()
    }
}
