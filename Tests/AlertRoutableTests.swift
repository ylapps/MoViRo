//
//  AlertRoutableTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AlertRoutable")
@MainActor
struct AlertRoutableTests {

    // MARK: - Push Router

    @Test func pushRouterShowsAlert() {
        let router = StubAlertRoutablePushRouter()
        let navStack = AnyNavigationStackRouter(root: router, transition: .sheet)
        let config = AlertRouter.Config(title: "Test", message: "Hello")
        router.showAlert(config: config)
        #expect(navStack.presented is AlertRouter)
        #expect((navStack.presented as? AlertRouter)?.config.title == "Test")
        #expect((navStack.presented as? AlertRouter)?.config.message == "Hello")
    }

    @Test func pushRouterDismissesAlert() {
        let router = StubAlertRoutablePushRouter()
        let navStack = AnyNavigationStackRouter(root: router, transition: .sheet)
        router.showAlert(config: .init(title: "Alert"))
        #expect(navStack.isAlertPresented)
        navStack.isAlertPresented = false
        #expect(navStack.presented == nil)
    }

    // MARK: - Modal Router

    @Test func modalRouterShowsAlert() {
        let router = StubAlertRoutableModalRouter(transition: .sheet)
        let config = AlertRouter.Config(title: "Warning", message: "Danger")
        router.showAlert(config: config)
        #expect(router.presented is AlertRouter)
        #expect((router.presented as? AlertRouter)?.config.title == "Warning")
    }

    @Test func modalRouterDismissesAlert() {
        let router = StubAlertRoutableModalRouter(transition: .sheet)
        router.showAlert(config: .init(title: "Alert"))
        #expect(router.isAlertPresented)
        router.isAlertPresented = false
        #expect(router.presented == nil)
    }

    @Test func modalRouterReplacesExistingPresentation() {
        let router = StubAlertRoutableModalRouter(transition: .sheet)
        let child = StubModalRouter(transition: .sheet)
        router.presented = child
        router.showAlert(config: .init(title: "Alert"))
        #expect(router.presented is AlertRouter)
        #expect(child.presenting == nil)
    }
}

// MARK: - Stubs

private final class StubAlertRoutablePushRouter: AnyPushRouter, AlertRoutable {
    override func makeContentView() -> AnyView { AnyView(EmptyView()) }
}

private final class StubAlertRoutableModalRouter: AnyModalRouter, AlertRoutable {
    override func makeContentView() -> AnyView { AnyView(EmptyView()) }
}
