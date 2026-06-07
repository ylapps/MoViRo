//
//  ClosableRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("RequestClose")
@MainActor
struct ClosableRouterTests {

    @Test func requestCloseModalRouter() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubVoidResultModalRouter()
        parent.presented = child
        child.requestClose()
        #expect(parent.presented == nil)
    }

    @Test func requestCloseModalRouterWhenNoPresenting() {
        let child = StubVoidResultModalRouter()
        // No presenting — requestClose() is a no-op (nil?.presented = nil)
        child.requestClose()
        #expect(child.presenting == nil)
    }

    @Test func requestClosePushRouter() {
        let a = StubPushRouter()
        let b = StubVoidResultPushRouter()
        a.pushed = b
        b.requestClose()
        #expect(a.pushed == nil)
    }

    @Test func requestClosePushRouterWhenRoot() {
        // Root push router inside a nav stack that is presented modally.
        // requestClose() should dismiss the modal.
        let presenter = StubModalRouter(transition: .sheet)
        let root = StubVoidResultPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        presenter.presented = navStack
        root.requestClose()
        #expect(presenter.presented == nil)
    }

    @Test func requestClosePushRouterWhenRootAndNoStack() {
        let root = StubVoidResultPushRouter()
        // No stack, no pushing — requestClose() is a no-op
        root.requestClose()
        #expect(root.pushing == nil)
        #expect(root.stack == nil)
    }

    @Test func requestCloseMiddleOfPushChain() {
        let a = StubPushRouter()
        let b = StubVoidResultPushRouter()
        let c = StubPushRouter()
        a.pushed = b
        b.pushed = c
        b.requestClose()
        #expect(a.pushed == nil)
        // C remains as b's pushed — b is just detached from a
        #expect(b.pushed === c)
    }

    @Test func requestClosePushRouterWhenRootDismissesNavStack() {
        // Root push router inside a nav stack with a deep push chain.
        // Closing root should dismiss the entire nav stack modal.
        let presenter = StubModalRouter(transition: .sheet)
        let root = StubVoidResultPushRouter()
        let b = StubPushRouter()
        root.pushed = b
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        presenter.presented = navStack
        root.requestClose()
        #expect(presenter.presented == nil)
    }

    @Test func requestCloseModalRouterBreaksBackReference() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubVoidResultModalRouter()
        parent.presented = child
        #expect(child.presenting === parent)
        child.requestClose()
        #expect(child.presenting == nil)
        #expect(parent.presented == nil)
    }
}
