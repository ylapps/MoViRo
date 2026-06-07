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
        let child = StubResultPushRouter()
        parent.pushed = child
        var receivedResult: String?
        child.onClose = { receivedResult = $0 }
        child.requestClose(with: "done")
        #expect(receivedResult == "done")
    }

    @Test func requestClose_parentDismissesChild() {
        let parent = StubPushRouter()
        let child = StubResultPushRouter()
        parent.pushed = child
        child.onClose = { _ in parent.pushed = nil }
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
        let child = StubResultPushRouter()
        parent.pushed = child
        child.onClose = { _ in /* parent decides not to dismiss */ }
        child.requestClose(with: "done")
        #expect(parent.pushed != nil)
    }

    @Test func requestCloseVoid_pushRouter() {
        let parent = StubPushRouter()
        let child = StubVoidResultPushRouter()
        parent.pushed = child
        var closeCalled = false
        child.onClose = { closeCalled = true }
        child.requestClose()
        #expect(closeCalled)
    }

    // MARK: - Modal Router

    @Test func requestClose_modal_callsOnClose() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter()
        parent.presented = child
        var receivedResult: Int?
        child.onClose = { receivedResult = $0 }
        child.requestClose(with: 42)
        #expect(receivedResult == 42)
    }

    @Test func requestClose_modal_parentDismissesChild() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubResultModalRouter()
        parent.presented = child
        child.onClose = { _ in parent.presented = nil }
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
        let child = StubResultModalRouter()
        parent.presented = child
        child.onClose = { _ in /* parent decides not to dismiss */ }
        child.requestClose(with: 42)
        #expect(parent.presented != nil)
    }

    @Test func requestCloseVoid_modalRouter() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubVoidResultModalRouter()
        parent.presented = child
        var closeCalled = false
        child.onClose = { closeCalled = true }
        child.requestClose()
        #expect(closeCalled)
    }
}
