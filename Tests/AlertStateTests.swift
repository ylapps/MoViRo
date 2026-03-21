//
//  AlertStateTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AlertState")
@MainActor
struct AlertStateTests {

    @Test func alertInitiallyNil() {
        let router = StubModalRouter(transition: .sheet)
        #expect(router.alert == nil)
    }

    @Test func presentAlert() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(title: "Title", message: "Message")
        #expect(router.alert != nil)
        #expect(router.alert?.message != nil)
    }

    @Test func dismissAlert() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(title: "Title")
        router.dismissAlert()
        #expect(router.alert == nil)
    }

    @Test func dismissAlertWhenNone() {
        let router = StubModalRouter(transition: .sheet)
        router.dismissAlert() // should not crash
        #expect(router.alert == nil)
    }

    @Test func replaceAlert() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(title: "First")
        router.presentAlert(title: "Second")
        #expect(router.alert != nil)
    }

    @Test func alertOnModalRouter() {
        let router = StubModalRouter(transition: .fullScreen)
        router.presentAlert(title: "Modal Alert")
        #expect(router.alert != nil)
    }

    @Test func alertOnPushRouter() {
        let router = StubPushRouter()
        router.presentAlert(title: "Push Alert")
        #expect(router.alert != nil)
    }

    @Test func alertWithActions() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(
            title: "Alert",
            actions: [
                .init(title: "Cancel", role: .cancel),
                .init(title: "Delete", role: .destructive),
                .init(title: "OK")
            ]
        )
        #expect(router.alert?.actions.count == 3)
        #expect(router.alert?.actions[0].role == .cancel)
        #expect(router.alert?.actions[1].role == .destructive)
        #expect(router.alert?.actions[2].role == nil)
    }

    @Test func alertWithNoActions() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(title: "Simple")
        #expect(router.alert?.actions.isEmpty == true)
    }

    @Test func alertActionHandler() {
        var handlerCalled = false
        let action = AlertState.Action(title: "OK") {
            handlerCalled = true
        }
        action.handler?()
        #expect(handlerCalled)
    }

    @Test func alertActionWithNilHandler() {
        let action = AlertState.Action(title: "OK")
        #expect(action.handler == nil)
        #expect(action.role == nil)
        // Calling handler?() should be safe
        action.handler?()
    }

    @Test func alertWithMessageNil() {
        let router = StubModalRouter(transition: .sheet)
        router.presentAlert(title: "Title")
        #expect(router.alert?.message == nil)
    }

    @Test func alertOnPushRouterViaBaseClass() {
        // Alert is on AnyRouter, so push routers should also work
        let push = StubPushRouter()
        push.presentAlert(title: "Push Alert", message: "Details")
        #expect(push.alert != nil)
        #expect(push.alert?.message != nil)
        push.dismissAlert()
        #expect(push.alert == nil)
    }
}
