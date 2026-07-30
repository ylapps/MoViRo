//
//  ResultRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("CloseReason Router")
@MainActor
struct ResultRouterTests {

    // MARK: - Push Router

    @Test func requestClose_callsOnWillClose() {
        let parent = StubPushRouter()
        var receivedReason: String?
        let child = StubResultPushRouter(onWillCloseWithReason: { receivedReason = $0 })
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(receivedReason == "done")
    }

    @Test func requestClose_dismissesAfterHandler() {
        let parent = StubPushRouter()
        var handlerCalled = false
        let child = StubResultPushRouter(onWillCloseWithReason: { _ in handlerCalled = true })
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(handlerCalled)
        #expect(parent.pushed == nil)
    }

    @Test func requestClose_withoutHandler_dismisses() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter()
        parent.pushed = child
        child.requestClose(with: "done")
        #expect(parent.pushed == nil)
    }

    @Test func requestClose_handlerDismissesEarly_noDoubleDismiss() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter(onWillCloseWithReason: { _ in parent.pushed = nil })
        parent.pushed = child
        child.requestClose(with: "done")
        // Handler already dismissed — router does not crash or double-dismiss
        #expect(parent.pushed == nil)
    }

    @Test func requestClose_withNilReason() {
        let parent = StubPushRouter()
        var receivedReason: String?? = .some("initial")
        let child = StubResultPushRouter(onWillCloseWithReason: { receivedReason = $0 })
        parent.pushed = child
        child.requestClose()
        #expect(receivedReason == nil as String?)
        #expect(parent.pushed == nil)
    }

    @Test func requestCloseVoid_pushRouter() {
        let parent = StubPushRouter()
        var closeCalled = false
        let child = StubVoidResultPushRouter(onWillClose: { closeCalled = true })
        parent.pushed = child
        child.requestClose()
        #expect(closeCalled)
        #expect(parent.pushed == nil)
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

    @Test func requestClose_modal_callsOnWillClose() {
        let parent = StubModalRouter(transition: .sheet)
        var receivedReason: Int?
        let child = StubResultModalRouter(onWillCloseWithReason: { receivedReason = $0 })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(receivedReason == 42)
    }

    @Test func requestClose_modal_dismissesAfterHandler() {
        let parent = StubModalRouter(transition: .sheet)
        var handlerCalled = false
        let child = StubResultModalRouter(onWillCloseWithReason: { _ in handlerCalled = true })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(handlerCalled)
        #expect(parent.presented == nil)
    }

    @Test func requestClose_modal_withoutHandler_dismisses() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter()
        parent.presented = child
        child.requestClose(with: 42)
        #expect(parent.presented == nil)
    }

    @Test func requestClose_modal_handlerDismissesEarly_noDoubleDismiss() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter(onWillCloseWithReason: { _ in parent.presented = nil })
        parent.presented = child
        child.requestClose(with: 42)
        #expect(parent.presented == nil)
    }

    @Test func requestClose_modal_withNilReason() {
        let parent = StubModalRouter(transition: .sheet)
        var receivedReason: Int?? = .some(99)
        let child = StubResultModalRouter(onWillCloseWithReason: { receivedReason = $0 })
        parent.presented = child
        child.requestClose()
        #expect(receivedReason == nil as Int?)
        #expect(parent.presented == nil)
    }

    @Test func requestCloseVoid_modalRouter() {
        let parent = StubModalRouter(transition: .sheet)
        var closeCalled = false
        let child = StubVoidResultModalRouter(onWillClose: { closeCalled = true })
        parent.presented = child
        child.requestClose()
        #expect(closeCalled)
        #expect(parent.presented == nil)
    }
}
