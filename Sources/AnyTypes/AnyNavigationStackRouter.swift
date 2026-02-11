//
//  AnyNavigationStackRouter.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyNavigationStackRouter: AnyModalRouter {

    public var root: AnyPushRouter

    public init(root: AnyPushRouter, transition: Transition, presented: AnyModalRouter? = nil) {
        self.root = root
        super.init(transition: transition, presented: presented)
        root.updateStack(with: self)
    }

    override func makeContentView() -> AnyView {
        .init(AnyNavigationStackView(router: self))
    }
}

// MARK: - View

private struct AnyNavigationStackView: View {

    @State var router: AnyNavigationStackRouter

    var body: some View {
        NavigationStack {
            router.root.makeView()
        }
    }
}
