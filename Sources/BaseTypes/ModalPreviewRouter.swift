//
//  ModalPreviewRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 27.05.2025.
//

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

    @State var router: ModalPreviewRouter

    var body: some View {
        VStack(spacing: 20) {
            Text("Modal Preview")
                .font(.title2)
            
            Button("Present") {
                if router.needsAnimation {
                    router.presented = router.presentedProvider()
                } else {
                    withoutAnimation {
                        router.presented = router.presentedProvider()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
