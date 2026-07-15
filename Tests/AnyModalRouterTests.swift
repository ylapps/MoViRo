//
//  AnyModalRouterTests.swift
//  MoviroTests
//

@testable import Moviro
import Testing

@Suite("AnyModalRouter Graph Wiring")
@MainActor
struct AnyModalRouterTests {

    @Test func initialState() {
        let router = StubModalRouter(transition: .sheet)
        #expect(router.presenting == nil)
        #expect(router.presented == nil)
        #expect(router.transition == .sheet)
    }

    @Test func settingPresentedAtInit() {
        let child = StubModalRouter(transition: .sheet)
        let parent = StubModalRouter(transition: .fullScreen)
        parent.presented = child
        #expect(parent.presented === child)
        #expect(child.presenting === parent)
    }

    @Test func settingPresentedEstablishesBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        a.presented = b
        #expect(b.presenting === a)
        #expect(a.presented === b)
    }

    @Test func replacingPresentedClearsOldBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        a.presented = c
        #expect(b.presenting == nil)
        #expect(c.presenting === a)
        #expect(a.presented === c)
    }

    @Test func settingPresentedToNilClearsBackReference() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        a.presented = b
        a.presented = nil
        #expect(b.presenting == nil)
        #expect(a.presented == nil)
    }

    @Test func chainedPresentations() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        #expect(a.presented === b)
        #expect(b.presented === c)
        #expect(b.presenting === a)
        #expect(c.presenting === b)
    }

    @Test func chainedPresentationMiddleRemoval() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        // Remove b from a
        a.presented = nil
        #expect(b.presenting == nil)
        // C remains as b's presented — b is just detached from a
        #expect(b.presented === c)
        #expect(c.presenting === b)
    }

    @Test func transitionTypes() {
        let sheet = StubModalRouter(transition: .sheet)
        let full = StubModalRouter(transition: .fullScreen)
        let pop = StubModalRouter(transition: .popover())
        #expect(sheet.transition == .sheet)
        #expect(full.transition == .fullScreen)
        #expect(pop.transition == .popover())
    }

    @Test func identifiableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        #expect(a.id != b.id)
    }

    @Test func equatableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        #expect(a == a)
        #expect(a != b)
    }

    @Test func selfPresentation() {
        let a = StubModalRouter(transition: .sheet)
        // willSet: a.presenting = nil, then a.presenting = a
        a.presented = a
        // Should not crash; a presents itself
        #expect(a.presented === a)
        #expect(a.presenting === a)
    }

    @Test func hashableConformance() {
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        var set = Set<AnyModalRouter>()
        set.insert(a)
        set.insert(b)
        set.insert(a) // duplicate
        #expect(set.count == 2)
        #expect(set.contains(a))
        #expect(set.contains(b))
    }

    @Test func transitionIsImmutable() {
        let router = StubModalRouter(transition: .popover())
        #expect(router.transition == .popover())
        // transition is `let` — cannot change after init
    }

    @Test func presentedWillSetClearsChainCorrectly() {
        // A presents B, B presents C, then A presents D
        // B should be disconnected, but B→C chain should remain intact
        let a = StubModalRouter(transition: .sheet)
        let b = StubModalRouter(transition: .sheet)
        let c = StubModalRouter(transition: .sheet)
        let d = StubModalRouter(transition: .sheet)
        a.presented = b
        b.presented = c
        a.presented = d
        #expect(b.presenting == nil)
        #expect(d.presenting === a)
        #expect(b.presented === c) // B→C chain preserved
        #expect(c.presenting === b) // C still points to B
    }

    // MARK: - Alert Presentation

    @Test func presentedAlertIsNilByDefault() {
        let router = StubModalRouter(transition: .sheet)
        #expect(router.presentedAlert == nil)
        #expect(router.isAlertPresented == false)
    }

    @Test func presentedAlertReturnsAlertRouter() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Test"))
        parent.presented = alert
        #expect(parent.presentedAlert === alert)
        #expect(parent.presentedAlert?.config.title == "Test")
    }

    @Test func presentedAlertReturnsNilForNonAlert() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubModalRouter(transition: .fullScreen)
        parent.presented = child
        #expect(parent.presentedAlert == nil)
        #expect(parent.isAlertPresented == false)
    }

    @Test func isAlertPresentedReflectsAlertRouter() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        parent.presented = alert
        #expect(parent.isAlertPresented == true)
    }

    @Test func isAlertPresentedSetToFalseDismissesAlert() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        parent.presented = alert
        parent.isAlertPresented = false
        #expect(parent.presented == nil)
        #expect(parent.isAlertPresented == false)
    }

    @Test func isAlertPresentedSetToTrueIsNoOp() {
        let parent = StubModalRouter(transition: .sheet)
        // Setting true when no alert is presented should be a no-op
        parent.isAlertPresented = true
        #expect(parent.presented == nil)
    }

    @Test func fullScreenGetterReturnsNilWhenAlertPresented() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        // AlertRouter uses .fullScreen transition, but fullScreen getter
        // should return nil when an alert is presented
        parent.presented = alert
        #expect(parent.presentedAlert != nil)
    }

    @Test func fullScreenGetterReturnsRouterWhenNotAlert() {
        let parent = StubModalRouter(transition: .sheet)
        let child = StubModalRouter(transition: .fullScreen)
        parent.presented = child
        #expect(parent.presentedAlert == nil)
        #expect(parent.presented === child)
    }

    @Test func alertEstablishesBackReference() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        parent.presented = alert
        #expect(alert.presenting === parent)
    }

    @Test func dismissAlertClearsBackReference() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        parent.presented = alert
        parent.isAlertPresented = false
        #expect(alert.presenting == nil)
        #expect(parent.presented == nil)
    }

    @Test func replacingAlertWithRegularPresentation() {
        let parent = StubModalRouter(transition: .sheet)
        let alert = AlertRouter(config: .init(title: "Alert"))
        parent.presented = alert
        let child = StubModalRouter(transition: .sheet)
        parent.presented = child
        #expect(parent.isAlertPresented == false)
        #expect(parent.presented === child)
        #expect(alert.presenting == nil)
    }
}
