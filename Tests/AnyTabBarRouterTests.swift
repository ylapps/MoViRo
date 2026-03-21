//
//  AnyTabBarRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import UIKit
import Testing

@Suite("AnyTabBarRouter")
@MainActor
struct AnyTabBarRouterTests {

    private func makeTabs(count: Int) -> [AnyTabBarRouter.Tab] {
        (0..<count).map { i in
            AnyTabBarRouter.Tab(
                router: StubModalRouter(transition: .sheet),
                title: "Tab \(i)",
                image: UIImage(systemName: "star")!
            )
        }
    }

    @Test func initWithTabs() {
        let tabs = makeTabs(count: 3)
        let tabBar = AnyTabBarRouter(tabs: tabs)
        #expect(tabBar.tabs.count == 3)
        #expect(tabBar.selectedTabIndex == 0)
    }

    @Test func selectedTabIndex() {
        let tabs = makeTabs(count: 3)
        let tabBar = AnyTabBarRouter(tabs: tabs, selectedTabIndex: 1)
        #expect(tabBar.selectedTabIndex == 1)
        tabBar.selectedTabIndex = 2
        #expect(tabBar.selectedTabIndex == 2)
    }

    @Test func tabBarIsModalRouter() {
        let tabs = makeTabs(count: 2)
        let tabBar = AnyTabBarRouter(tabs: tabs)
        let presented = StubModalRouter(transition: .sheet)
        tabBar.presented = presented
        #expect(presented.presenting === tabBar)
    }

    @Test func tabRoutersIndependent() {
        let tabs = makeTabs(count: 2)
        let tabBar = AnyTabBarRouter(tabs: tabs)
        let tab0Router = tabBar.tabs[0].router
        let tab1Router = tabBar.tabs[1].router
        #expect(tab0Router.id != tab1Router.id)
        // Presenting on one tab doesn't affect the other
        let child = StubModalRouter(transition: .sheet)
        tab0Router.presented = child
        #expect(tab0Router.presented === child)
        #expect(tab1Router.presented == nil)
    }

    @Test func tabEquality() {
        let router = StubModalRouter(transition: .sheet)
        let image = UIImage(systemName: "star")!
        let tab1 = AnyTabBarRouter.Tab(router: router, title: "Tab", image: image)
        let tab2 = AnyTabBarRouter.Tab(router: router, title: "Tab", image: image)
        #expect(tab1 == tab2)
    }

    @Test func tabInequalityDifferentRouter() {
        let router1 = StubModalRouter(transition: .sheet)
        let router2 = StubModalRouter(transition: .sheet)
        let image = UIImage(systemName: "star")!
        let tab1 = AnyTabBarRouter.Tab(router: router1, title: "Tab", image: image)
        let tab2 = AnyTabBarRouter.Tab(router: router2, title: "Tab", image: image)
        #expect(tab1 != tab2)
    }

    @Test func defaultTransitionIsFullScreen() {
        let tabs = makeTabs(count: 1)
        let tabBar = AnyTabBarRouter(tabs: tabs)
        #expect(tabBar.transition == .fullScreen)
    }

}
