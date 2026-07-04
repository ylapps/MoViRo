//
//  ResultRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("ResultRouter")
@MainActor
struct ResultRouterTests {

    // MARK: - Push Router

    @Test func requestClose_callsOnClose() {
        let parent = StubPushRouter()
        var receivedResult: String?
        let child = StubResultPushRouter(onClose: { receivedResult = $0 })
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(receivedResult == "done")
    }

    @Test func requestClose_parentDismissesChild() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter(onClose: { _ in parent.pushed = nil })
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(parent.pushed == nil)
    }

    @Test func requestClose_withoutOnClose_fallsBackToDismiss() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter()
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(parent.pushed == nil)
    }

    @Test func requestClose_withOnClose_doesNotDismissAutomatically() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter(onClose: { _ in /* parent decides not to dismiss */ })
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(parent.pushed != nil)
    }

    @Test func requestCloseVoid_pushRouter() {
        let parent = StubPushRouter()
        var closeCalled = false
        let child = StubVoidResultPushRouter(onClose: { closeCalled = true })
        parent.pushed = child
        child.requestClose()
        #expect(closeCalled)
    }

    // MARK: - Push Router Presented

    @Test func presented_delegatesToStack() {
        let root = StubVoidResultPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let modal = StubModalRouter(transition: .sheet)
        root.presented = modal
        #expect(navStack.presented === modal)
        #expect(root.presented === modal)
    }

    @Test func presented_getReturnsNilWithoutStack() {
        let root = StubVoidResultPushRouter()
        #expect(root.presented == nil)
    }

    @Test func presented_setIsNoOpWithoutStack() {
        let root = StubVoidResultPushRouter()
        let modal = StubModalRouter(transition: .sheet)
        root.presented = modal
        // No stack — set is silently ignored
        #expect(root.presented == nil)
    }

    @Test func presented_nilDismissesModal() {
        let root = StubVoidResultPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let modal = StubModalRouter(transition: .sheet)
        root.presented = modal
        root.presented = nil
        #expect(navStack.presented == nil)
        #expect(root.presented == nil)
    }

    @Test func presented_worksFromPushedRouter() {
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        let child = StubVoidResultPushRouter()
        root.pushed = child
        let modal = StubModalRouter(transition: .sheet)
        child.presented = modal
        #expect(navStack.presented === modal)
        #expect(child.presented === modal)
    }

    // MARK: - Modal Router

    @Test func requestClose_modal_callsOnClose() {
        let parent = StubModalRouter(transition: .sheet)
        var receivedResult: Int?
        let child = StubResultModalRouter(onClose: { receivedResult = $0 })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(receivedResult == 42)
    }

    @Test func requestClose_modal_parentDismissesChild() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter(onClose: { _ in parent.presented = nil })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(parent.presented == nil)
    }

    @Test func requestClose_modal_withoutOnClose_fallsBackToDismiss() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter()
        parent.presented = child
        child.requestClose(with: 42)
        #expect(parent.presented == nil)
    }

    @Test func requestClose_modal_withOnClose_doesNotDismissAutomatically() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter(onClose: { _ in /* parent decides not to dismiss */ })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(parent.presented != nil)
    }

    @Test func requestCloseVoid_modalRouter() {
        let parent = StubModalRouter(transition: .sheet)
        var closeCalled = false
        let child = StubVoidResultModalRouter(onClose: { closeCalled = true })
        parent.presented = child
        child.requestClose()
        #expect(closeCalled)
    }
}
