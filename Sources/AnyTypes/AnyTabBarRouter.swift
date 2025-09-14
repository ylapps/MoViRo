//
//  AnyTabBarRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 27.05.2025.
//

import SwiftUI
import UIKit

// MARK: - Router

@Observable
open class AnyTabBarRouter: AnyModalRouter {

    public struct Tab: Equatable {
        public let router: AnyModalRouter
        public let title: LocalizedStringKey
        public let image: UIImage

        public init(router: AnyModalRouter, title: LocalizedStringKey, image: UIImage) {
            self.router = router
            self.title = title
            self.image = image
        }
    }

    public var tabs: [Tab]
    public var selectedTabIndex: Int

    public init(tabs: [Tab], selectedTabIndex: Int = 0, transition: Transition = .fullScreen, presented: AnyModalRouter? = nil) {
        self.tabs = tabs
        self.selectedTabIndex = selectedTabIndex
        super.init(transition: transition, presented: presented)
    }

    override func makeContentView() -> AnyView {
        .init(AnyTabBarView(router: self))
    }
}

// MARK: - View

private struct AnyTabBarView: View {

    @State var router: AnyTabBarRouter

    var body: some View {
        TabView(selection: $router.selectedTabIndex) {
            ForEach(router.tabs.indices, id: \.self) { idx in
                let tab = router.tabs[idx]
                tab.router.makeView()
                    .tabItem({
                        Text(tab.title)
                        Image(uiImage: tab.image)
                    })
                    .tag(idx)
            }
        }
    }
}
