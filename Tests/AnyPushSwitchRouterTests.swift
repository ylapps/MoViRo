//
//  AnyPushSwitchRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyPushSwitchRouter")
@MainActor
struct AnyPushSwitchRouterTests {

    @Test func initialState() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        #expect(switchRouter.pushed == nil)
    }

    @Test func switchingCurrentTransfersPushingReference() {
        let contentA = StubPushRouter()
        let contentB = StubPushRouter()
        let parent = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        // Establish pushing reference
        parent.pushed = switchRouter
        #expect(switchRouter.pushing === parent)
        // Switch current
        switchRouter.current = contentB
        // New current should get the switch's pushing
        #expect(contentB.pushing === parent)
        // Old current's pushing should be cleared
        #expect(contentA.pushing == nil)
    }

    @Test func switchingCurrentTransfersStackReference() {
        let contentA = StubPushRouter()
        let contentB = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let root = StubPushRouter()
        root.pushed = switchRouter
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        #expect(switchRouter.stack === navStack)
        #expect(contentA.stack === navStack)
        // Switch current
        switchRouter.current = contentB
        #expect(contentB.stack === navStack)
        #expect(contentA.stack == nil)
    }

    @Test func pushedDelegatesToCurrent() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let pushed = StubPushRouter()
        switchRouter.pushed = pushed
        #expect(contentA.pushed === pushed)
    }

    @Test func pushedGetDelegatesToCurrent() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let pushed = StubPushRouter()
        contentA.pushed = pushed
        #expect(switchRouter.pushed === pushed)
    }

    @Test func updateStackPropagatesToCurrent() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        switchRouter.updateStack(with: navStack)
        #expect(switchRouter.stack === navStack)
        #expect(contentA.stack === navStack)
    }

    @Test func switchingCurrentWhenPushedExists() {
        let contentA = StubPushRouter()
        let contentB = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let pushed = StubPushRouter()
        switchRouter.pushed = pushed // sets contentA.pushed
        #expect(contentA.pushed === pushed)
        // Switch to B
        switchRouter.current = contentB
        // A still has its pushed
        #expect(contentA.pushed === pushed)
        // switchRouter.pushed now reads B's pushed (nil)
        #expect(switchRouter.pushed == nil)
    }

    @Test func updateStackClearsOnNil() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let root = StubPushRouter()
        let navStack = AnyNavigationStackRouter(root: root, transition: .sheet)
        switchRouter.updateStack(with: navStack)
        #expect(contentA.stack === navStack)
        switchRouter.updateStack(with: nil)
        #expect(switchRouter.stack == nil)
        #expect(contentA.stack == nil)
    }

    @Test func switchRouterHasPushRouterProperties() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        // Verify it has push router properties
        #expect(switchRouter.pushed == nil)
        #expect(switchRouter.pushing == nil)
        #expect(switchRouter.stack == nil)
    }

    @Test func nillingPushedOnSwitchNillsOnCurrent() {
        let contentA = StubPushRouter()
        let switchRouter = AnyPushSwitchRouter(current: contentA)
        let pushed = StubPushRouter()
        switchRouter.pushed = pushed
        #expect(contentA.pushed === pushed)
        switchRouter.pushed = nil
        #expect(contentA.pushed == nil)
    }
}
