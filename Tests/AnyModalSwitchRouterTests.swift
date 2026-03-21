//
//  AnyModalSwitchRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyModalSwitchRouter")
@MainActor
struct AnyModalSwitchRouterTests {

    @Test func initDoesNotSetPresentingOnCurrent() {
        // willSet does NOT fire during stored property initialization
        let contentA = StubModalRouter(transition: .sheet)
        let _ = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        // Note: presenting is NOT set during init because willSet doesn't fire for stored property init
        #expect(contentA.presenting == nil)
    }

    @Test func switchingCurrentClearsOldPresenting() {
        let contentA = StubModalRouter(transition: .sheet)
        let contentB = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        switchRouter.current = contentB
        #expect(contentA.presenting == nil)
        #expect(contentB.presenting === switchRouter)
    }

    @Test func switchingCurrentMultipleTimes() {
        let contentA = StubModalRouter(transition: .sheet)
        let contentB = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        switchRouter.current = contentB
        switchRouter.current = contentA
        #expect(contentA.presenting === switchRouter)
        #expect(contentB.presenting == nil)
    }

    @Test func presentedDelegatesToCurrent() {
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        switchRouter.presented = presented
        #expect(contentA.presented === presented)
    }

    @Test func presentedGetDelegatesToCurrent() {
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        contentA.presented = presented
        #expect(switchRouter.presented === presented)
    }

    @Test func settingPresentedOnSwitchGoesToCurrent() {
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        switchRouter.presented = presented
        // Back-reference on presented points to current, not switch
        #expect(presented.presenting === contentA)
    }

    @Test func switchingCurrentWithActivePresentedOnOld() {
        let contentA = StubModalRouter(transition: .sheet)
        let contentB = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        switchRouter.presented = presented
        #expect(contentA.presented === presented)
        // Switch to B
        switchRouter.current = contentB
        // A's presented remains — it's on A
        #expect(contentA.presented === presented)
        // switchRouter.presented now reads B's presented (nil)
        #expect(switchRouter.presented == nil)
    }

    @Test func switchRouterInheritsTransition() {
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .fullScreen)
        #expect(switchRouter.transition == .fullScreen)
    }

    @Test func switchRouterCanBePresentedFromParent() {
        let parent = StubModalRouter(transition: .sheet)
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        parent.presented = switchRouter
        #expect(switchRouter.presenting === parent)
    }

    @Test func nillingPresentedOnSwitchNillsOnCurrent() {
        let contentA = StubModalRouter(transition: .sheet)
        let switchRouter = AnyModalSwitchRouter(current: contentA, transition: .sheet)
        let presented = StubModalRouter(transition: .sheet)
        switchRouter.presented = presented
        #expect(contentA.presented === presented)
        switchRouter.presented = nil
        #expect(contentA.presented == nil)
    }
}
