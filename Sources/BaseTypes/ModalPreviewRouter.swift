//
//  ModalPreviewRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 27.05.2025.
//

import SwiftUI
import Observation

@Observable
public final class ModalPreviewRouter: AnyModalRouter {

    let needsAnimation: Bool
    let presentedProvider: () -> AnyModalRouter

    public init(needsAnimation: Bool = true, presentedProvider: @escaping () -> AnyModalRouter) {
        self.needsAnimation = needsAnimation
        self.presentedProvider = presentedProvider
        super.init(transition: .fullScreen)
    }

    override func makeContentView() -> AnyView {
        .init(ModalPreviewView(router: self))
    }
}

private struct ModalPreviewView: View {

    @Bindable var router: ModalPreviewRouter

    var body: some View {
        Text("Modal Preview")
        Button("Present") {
            if router.needsAnimation {
                router.presented = router.presentedProvider()
            } else {
                var transaction = Transaction(animation: .easeIn(duration: 0))
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    router.presented = router.presentedProvider()
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
