//
//  AnyPushSwitchRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 12.03.2025.
//

import SwiftUI
import Combine

@Observable
open class AnyPushSwitchRouter: AnyPushRouter {

    public var current: AnyPushRouter {
        willSet {
            current.pushing = nil
            current.updateStack(with: nil)
            newValue.pushing = pushing
            newValue.updateStack(with: stack)
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
        .init(AnyPushSwitchContentView(router: self))
    }

    override func updateStack(with newStack: AnyNavigationStackRouter?) {
        super.updateStack(with: newStack)
        current.updateStack(with: newStack)
    }
}

private struct AnyPushSwitchContentView: View {

    @State var router: AnyPushSwitchRouter

    var body: some View {
        router.current.makeContentView()
    }
}
