//
//  AnyModelTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyModel Lifecycle")
@MainActor
struct AnyModelTests {

    @Test func initialState() {
        let model = SpyModel()
        #expect(model.isAppeared == false)
        #expect(model.onAppearCount == 0)
        #expect(model.onDisappearCount == 0)
    }

    @Test func singleAppear() {
        let model = SpyModel()
        model.isAppeared = true
        #expect(model.onAppearCount == 1)
    }

    @Test func multipleAppearCallsOnlyTriggerOnAppearOnce() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = true
        model.isAppeared = true
        #expect(model.onAppearCount == 1)
    }

    @Test func balancedAppearDisappear() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = false
        #expect(model.onAppearCount == 1)
        #expect(model.onDisappearCount == 1)
    }

    @Test func multipleAppearsRequireMatchingDisappears() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = true
        model.isAppeared = true
        // Three appears → need three disappears to trigger onDisappear
        model.isAppeared = false
        #expect(model.onDisappearCount == 0)
        model.isAppeared = false
        #expect(model.onDisappearCount == 0)
        model.isAppeared = false
        #expect(model.onDisappearCount == 1)
        #expect(model.onAppearCount == 1)
    }

    @Test func partialDisappearDoesNotTriggerOnDisappear() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = true
        // Only one disappear — count goes from 2 to 1, not 0
        model.isAppeared = false
        #expect(model.onDisappearCount == 0)
    }

    @Test func disappearWhenNeverAppeared() {
        let model = SpyModel()
        // Guard prevents negative count
        model.isAppeared = false
        #expect(model.onDisappearCount == 0)
        // Doing it multiple times should still be safe
        model.isAppeared = false
        model.isAppeared = false
        #expect(model.onDisappearCount == 0)
    }

    @Test func rapidAppearDisappearAppear() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = false
        model.isAppeared = true
        #expect(model.onAppearCount == 2)
        #expect(model.onDisappearCount == 1)
    }

    @Test func multipleCycles() {
        let model = SpyModel()
        model.isAppeared = true
        model.isAppeared = false
        model.isAppeared = true
        model.isAppeared = false
        #expect(model.onAppearCount == 2)
        #expect(model.onDisappearCount == 2)
    }
}
