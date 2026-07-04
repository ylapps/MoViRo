//
//  AnyNavigationStackRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyNavigationStackRouter")
@MainActor
struct AnyNavigationStackRouterTests {

    @Test func initSetsStackOnRoot() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(root.stack === navStack)
    }

    @Test func stackPropagatesFromRootToPushChain() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        root.pushed = b
        #expect(b.stack === navStack)
    }

    @Test func stackPropagatesFromRootToPushChainOnInit() {
        let root = StubPushRouter()
        let b = StubPushRouter()
        root.pushed = b
        // Create nav stack after the push chain exists
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(root.stack === navStack)
        #expect(b.stack === navStack)
    }

    @Test func presentedOnNavStackInheritsModalChain() {
        let root = StubPushRouter()
        let child = StubModalRouter(transition: .sheet)
        let navStack = AnyNavigationStackRouter(root: root, transition: .fullScreen)
        navStack.presented = child
        #expect(navStack.presented === child)
        #expect(child.presenting === navStack)
    }

    @Test func navStackIsModalRouter() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        navStack.presented = presented
        #expect(presented.presenting === navStack)
    }

    @Test func settingPresentedAfterInit() {
        let root = StubPushRouter()
        let child = StubModalRouter(transition: .sheet)
        let navStack = AnyNavigationStackRouter(root: root, transition: .fullScreen)
        navStack.presented = child
        #expect(child.presenting === navStack)
        #expect(navStack.presented === child)
    }

    @Test func rootPropertyIsAccessible() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(navStack.root === root)
    }

    @Test func navStackInheritsTransition() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .fullScreen)
        #expect(navStack.transition == .fullScreen)
    }

    @Test func deepPushChainGetsStackOnInit() {
        // Build a deep push chain first, then wrap in nav stack
        let root = StubPushRouter()
        let b = StubPushRouter()
        let c = StubPushRouter()
        root.pushed = b
        b.pushed = c
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(root.stack === navStack)
        #expect(b.stack === navStack)
        #expect(c.stack === navStack)
    }
}
