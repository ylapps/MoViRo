//
//  AppearsAnimatedTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

/// `appearsAnimated` is a router's own say on how it is shown. The wiring
/// around it is what a router-level test can see; whether SwiftUI animates
/// is not.
@Suite("appearsAnimated")
@MainActor
struct AppearsAnimatedTests {

    @Test func routersAnimateByDefault() {
        #expect(StubModalRouter(transition: .sheet).appearsAnimated)
        #expect(StubPushRouter().appearsAnimated)
        #expect(NavigationStackRouter(root: StubPushRouter(), transition: .sheet).appearsAnimated)
        #expect(AlertRouter(config: .init(title: "Hi")).appearsAnimated)
    }

    @Test func anUnanimatedPresentationIsWiredLikeAnyOther() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubModalRouter(transition: .fullScreen)
        child.appearsAnimated = false
        parent.presented = child
        #expect(parent.presented === child)
        #expect(child.presenting === parent)
        #expect(parent.fullScreen === child)
        parent.presented = nil
        #expect(child.presenting == nil)
    }

    @Test func anUnanimatedPushIsWiredLikeAnyOther() {
        let root = StubPushRouter()
        let stack = NavigationStackRouter(root: root, transition: .fullScreen)
        let pushed = StubPushRouter()
        pushed.appearsAnimated = false
        root.pushed = pushed
        #expect(root.pushed === pushed)
        #expect(pushed.pushing === root)
        #expect(pushed.stack === stack)
        root.pushed = nil
        #expect(pushed.pushing == nil)
        #expect(pushed.stack == nil)
    }

    /// A preset chain with the flag off everywhere but at the end keeps its
    /// shape; the flag changes nothing about who holds whom.
    @Test func aChainKeepsItsShape() {
        let root = StubPushRouter()
        let stack = NavigationStackRouter(root: root, transition: .fullScreen)
        let first = StubPushRouter()
        let sheet = StubModalRouter(transition: .sheet)
        let last = StubModalRouter(transition: .sheet)
        first.appearsAnimated = false
        sheet.appearsAnimated = false
        root.pushed = first
        first.presented = sheet
        sheet.presented = last
        #expect(root.pushed === first)
        #expect(stack.presented === sheet)
        #expect(sheet.presented === last)
        #expect(last.appearsAnimated)
    }
}
