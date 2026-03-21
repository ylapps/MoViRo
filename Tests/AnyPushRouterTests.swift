//
//  AnyPushRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyPushRouter Graph Wiring")
@MainActor
struct AnyPushRouterTests {

    @Test func initialState() {
        let router = StubPushRouter()
        #expect(router.pushed == nil)
        #expect(router.pushing == nil)
        #expect(router.stack == nil)
        #expect(router.split == nil)
    }

    @Test func initWithPushed() {
        let b = StubPushRouter()
        let a = StubPushRouter(pushed: b)
        #expect(a.pushed === b)
        #expect(b.pushing === a)
    }

    @Test func settingPushedEstablishesPushingReference() {
        let a = StubPushRouter()
        let b = StubPushRouter()
        a.pushed = b
        #expect(b.pushing === a)
        #expect(a.pushed === b)
    }

    @Test func replacingPushedClearsOldPushingReference() {
        let a = StubPushRouter()
        let b = StubPushRouter()
        let c = StubPushRouter()
        a.pushed = b
        a.pushed = c
        #expect(b.pushing == nil)
        #expect(c.pushing === a)
        #expect(a.pushed === c)
    }

    @Test func replacingPushedClearsOldStack() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        root.pushed = b
        #expect(b.stack === navStack)
        let c = StubPushRouter()
        root.pushed = c
        #expect(b.stack == nil)
        #expect(c.stack === navStack)
    }

    @Test func settingPushedToNilClearsReferences() {
        let a = StubPushRouter()
        let b = StubPushRouter()
        a.pushed = b
        a.pushed = nil
        #expect(b.pushing == nil)
        #expect(b.stack == nil)
    }

    @Test func pushChain() {
        let a = StubPushRouter()
        let b = StubPushRouter()
        let c = StubPushRouter()
        a.pushed = b
        b.pushed = c
        #expect(b.pushing === a)
        #expect(c.pushing === b)
        #expect(a.pushed === b)
        #expect(b.pushed === c)
    }

    @Test func stackPropagationThroughPushChain() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        let c = StubPushRouter()
        root.pushed = b
        b.pushed = c
        #expect(root.stack === navStack)
        #expect(b.stack === navStack)
        #expect(c.stack === navStack)
    }

    @Test func stackClearedOnDetach() {
        let root = StubPushRouter()
        let _ = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        let c = StubPushRouter()
        root.pushed = b
        b.pushed = c
        // Detach b (and transitively c)
        root.pushed = nil
        #expect(b.stack == nil)
        #expect(c.stack == nil)
    }

    @Test func splitReturnsNilWhenStackIsNotSplit() {
        let root = StubPushRouter()
        let _ = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(root.split == nil)
    }

    @Test func splitReturnsRouterWhenStackIsSplit() {
        let root = StubPushRouter()
        let splitRouter = AnySplitRouter(root: root)
        #expect(root.split === splitRouter)
    }

    @Test func deepChainStackDetachCascades() {
        let root = StubPushRouter()
        let _ = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        let c = StubPushRouter()
        let d = StubPushRouter()
        root.pushed = b
        b.pushed = c
        c.pushed = d
        // Detach b — c and d should also lose stack
        root.pushed = nil
        #expect(b.stack == nil)
        #expect(c.stack == nil)
        #expect(d.stack == nil)
        // But the push chain b→c→d should remain intact
        #expect(b.pushed === c)
        #expect(c.pushed === d)
    }

    @Test func initPushedInheritsStackFromParent() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let b = StubPushRouter()
        root.pushed = b
        // b should inherit root's stack
        #expect(b.stack === navStack)
    }

    @Test func replacingPushedDoesNotAffectDeepChain() {
        // A→B→C, then A.pushed = D — B and C become detached
        let a = StubPushRouter()
        let b = StubPushRouter()
        let c = StubPushRouter()
        let d = StubPushRouter()
        a.pushed = b
        b.pushed = c
        a.pushed = d
        #expect(b.pushing == nil)
        #expect(d.pushing === a)
        // B→C chain remains intact, just detached from A
        #expect(b.pushed === c)
        #expect(c.pushing === b)
    }
}
