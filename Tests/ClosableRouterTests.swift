//
//  ClosableRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("ClosableRouter")
@MainActor
struct ClosableRouterTests {

    @Test func closeModalRouter() {
        let parent = StubModalRouter(transition: .sheet)
        let child = ClosableModalRouter(transition: .sheet)
        parent.presented = child
        child.close()
        #expect(parent.presented == nil)
    }

    @Test func closeModalRouterWhenNoPresenting() {
        let child = ClosableModalRouter(transition: .sheet)
        // No presenting — close() is a no-op (nil?.presented = nil)
        child.close()
        #expect(child.presenting == nil)
    }

    @Test func closePushRouter() {
        let a = StubPushRouter()
        let b = ClosablePushRouter()
        a.pushed = b
        b.close()
        #expect(a.pushed == nil)
    }

    @Test func closePushRouterWhenRoot() {
        // Root push router inside a nav stack that is presented modally.
        // close() should dismiss the modal.
        let presenter = StubModalRouter(transition: .sheet)
        let root = ClosablePushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        presenter.presented = navStack
        root.close()
        #expect(presenter.presented == nil)
    }

    @Test func closePushRouterWhenRootAndNoStack() {
        let root = ClosablePushRouter()
        // No stack, no pushing — close() is a no-op
        root.close()
        #expect(root.pushing == nil)
        #expect(root.stack == nil)
    }

    @Test func closeMiddleOfPushChain() {
        let a = StubPushRouter()
        let b = ClosablePushRouter()
        let c = StubPushRouter()
        a.pushed = b
        b.pushed = c
        b.close()
        #expect(a.pushed == nil)
        // C remains as b's pushed — b is just detached from a
        #expect(b.pushed === c)
    }

    @Test func closePushRouterWhenRootDismissesNavStack() {
        // Root push router inside a nav stack with a deep push chain.
        // Closing root should dismiss the entire nav stack modal.
        let presenter = StubModalRouter(transition: .sheet)
        let root = ClosablePushRouter()
        let b = StubPushRouter()
        root.pushed = b
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        presenter.presented = navStack
        root.close()
        #expect(presenter.presented == nil)
    }

    @Test func closeModalRouterBreaksBackReference() {
        let parent = StubModalRouter(transition: .sheet)
        let child = ClosableModalRouter(transition: .sheet)
        parent.presented = child
        #expect(child.presenting === parent)
        child.close()
        #expect(child.presenting == nil)
        #expect(parent.presented == nil)
    }
}
