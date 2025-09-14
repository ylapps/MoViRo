//
//  AnyPushSwitchRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 12.03.2025.
//

import SwiftUI
import Observation

@Observable
open class AnyPushSwitchRouter: AnyPushRouter {

    public var current: AnyPushRouter {
        willSet {
            current.pushing = nil
            current.stack = nil
            newValue.pushing = pushing
            newValue.stack = stack
        }
    }

    public override var pushed: AnyPushRouter? {
        get { current.pushed }
        set { current.pushed = newValue }
    }

    public init(current: AnyPushRouter) {
        self.current = current
        super.init()
    }

    override func makeContentView() -> AnyView {
        .init(AnyPushSwitchView(router: self))
    }
}

private struct AnyPushSwitchView: View {

    @Bindable var router: AnyPushSwitchRouter

    var body: some View {
        router.current.makeView()
    }
}
