//
//  ModalPreviewRouter.swift
//  Moviro
//

import SwiftUI

@Observable
public final class ModalPreviewRouter: AnyModalRouter {

    let needsAnimation: Bool
    let presentedProvider: () -> AnyModalRouter

    public init(needsAnimation: Bool = true, presentedProvider: @escaping () -> AnyModalRouter) {
        self.needsAnimation = needsAnimation
        self.presentedProvider = presentedProvider
        super.init(transition: .fullScreen)
    }

    // MARK: Screen

    var screen: some View {
        ModalPreviewView(router: self)
            .presentations(of: self)
    }

    override func makeScreen() -> ErasedScreen {
        .init(screen)
    }
}

private struct ModalPreviewView: View {

    let router: ModalPreviewRouter

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
