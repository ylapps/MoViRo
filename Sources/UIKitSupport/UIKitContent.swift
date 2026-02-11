//
//  UIKitContent.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 25.01.2026.
//

public struct UIKitContent<VC: UIViewController & ModelHolding>: UIViewControllerRepresentable {

    let model: VC.Model

    public init(model: VC.Model) {
        self.model = model
    }

    public func updateUIViewController(_ uiViewController: VC, context: Context) {}

    public func makeUIViewController(context: Context) -> VC {
        VC(model: model)
    }
}

extension UIKitContent: ModelHolding {}
extension UIKitContent: BaseView where VC.Model: AnyModel {}
