//
//  AlertRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing
import SwiftUI

@Suite("AlertRouter")
@MainActor
struct AlertRouterTests {

    // MARK: - Initialization

    @Test func initSetsConfig() {
        let config = AlertRouter.Config(title: "Title", message: "Message")
        let router = AlertRouter(config: config)
        #expect(router.config.title == "Title")
        #expect(router.config.message == "Message")
    }

    @Test func initUsesFullScreenTransition() {
        let router = AlertRouter(config: .init())
        #expect(router.transition == .fullScreen)
    }

    @Test func presentedIsNilByDefault() {
        let router = AlertRouter(config: .init())
        #expect(router.presented == nil)
        #expect(router.presenting == nil)
    }

    // MARK: - Config

    @Test func configDefaults() {
        let config = AlertRouter.Config()
        #expect(config.title == nil)
        #expect(config.message == nil)
        #expect(config.actions.isEmpty)
    }

    @Test func configWithAllFields() {
        let action = AlertRouter.Config.Action(title: "OK", role: .destructive)
        let config = AlertRouter.Config(title: "Alert", message: "Something happened", actions: [action])
        #expect(config.title == "Alert")
        #expect(config.message == "Something happened")
        #expect(config.actions.count == 1)
        #expect(config.actions.first?.title == "OK")
    }

    // MARK: - Action

    @Test func actionDefaults() {
        let action = AlertRouter.Config.Action(title: "Cancel")
        #expect(action.title == "Cancel")
        #expect(action.role == nil)
    }

    @Test func actionWithDestructiveRole() {
        let action = AlertRouter.Config.Action(title: "Delete", role: .destructive)
        #expect(action.title == "Delete")
        #expect(action.role == .destructive)
    }

    @Test func actionHandlerIsCalled() {
        nonisolated(unsafe) var called = false
        let action = AlertRouter.Config.Action(title: "OK") { called = true }
        action.handler()
        #expect(called)
    }

    @Test func actionIdentifiableUniqueness() {
        let a = AlertRouter.Config.Action(title: "A")
        let b = AlertRouter.Config.Action(title: "B")
        #expect(a.id != b.id)
    }

    @Test func multipleActions() {
        let actions = [
            AlertRouter.Config.Action(title: "Cancel", role: .cancel),
            AlertRouter.Config.Action(title: "Delete", role: .destructive),
        ]
        let config = AlertRouter.Config(title: "Confirm", actions: actions)
        #expect(config.actions.count == 2)
        #expect(config.actions[0].role == .cancel)
        #expect(config.actions[1].role == .destructive)
    }
}
