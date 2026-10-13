//
//  Presentations.swift
//  Moviro
//

import SwiftUI

public extension View {

    /// Hangs the sheet, full-screen cover, popover and alert that `router`
    /// presents off this view. Moviro applies it to every modal router's own
    /// screen; apply it yourself when a modal router's content is hosted
    /// somewhere Moviro does not build — a `UIHostingController` of your own,
    /// for instance.
    ///
    /// A presentation set before the view is on screen is asked for one turn
    /// after the view appears, which lets it wait for the transition that
    /// brought the view in, so a chain of them set up front — a deep link —
    /// lands one level after another.
    func presentations(of router: AnyModalRouter) -> some View {
        modifier(Presentations(router: router))
    }
}

/// `@State` for the readiness gate, nothing else: the content this is applied
/// to is built by whoever built the view, so a change of `presented` re-runs
/// this body alone and leaves the screen's own view value untouched.
struct Presentations: ViewModifier {

    let router: AnyModalRouter

    @State private var isReadyToPresent = false

    func body(content: Content) -> some View {
        content
            .sheet(item: presentation(\.sheet)) { $0.makeView() }
            .fullScreenCover(item: presentation(\.fullScreen)) { CoverContent(router: $0) }
            .popover(
                item: presentation(\.popover),
                attachmentAnchor: router.popover?.transition.popoverAttachmentAnchor ?? .rect(.bounds),
                arrowEdge: router.popover?.transition.popoverArrowEdge
            ) { $0.makeView() }
            .alert(router.presentedAlert?.config.title ?? "", isPresented: alertPresentation) {
                if let alert = router.presentedAlert {
                    ForEach(alert.config.actions) { action in
                        Button(action.title, role: action.role) {
                            action.handler()
                        }
                    }
                }
            } message: {
                if let message = router.presentedAlert?.config.message {
                    Text(message)
                }
            }
            .onAppear {
                // One turn later, not inside `onAppear` itself. Asked for from
                // within `onAppear`, a presentation goes out in the same
                // transaction as the one that brought this view in, and iOS 26
                // drops the fourth modal nested that way (the sample's deep-link
                // builder: push·push·sheet·popover·cover+stack·push·push·sheet
                // stopped at the seventh step, sheet·sheet·sheet·sheet at the
                // fourth, every run; iOS 27 copes). A turn later the request
                // waits for the transition in flight, and every level lands on
                // both — at the same pace as waiting for UIKit's
                // `viewDidAppear`, which this replaces, and with no UIKit.
                DispatchQueue.main.async(execute: becomeReadyToPresent)
            }
    }

    /// A cover with a transition of its own is presented by this flip when it
    /// was set before the view appeared, and it must not slide in then either.
    private func becomeReadyToPresent() {
        guard router.fullScreen?.transition.coverTransition != nil else {
            isReadyToPresent = true
            return
        }
        withTransaction(\.disablesAnimations, true) {
            isReadyToPresent = true
        }
    }

    private func presentation(
        _ keyPath: ReferenceWritableKeyPath<AnyModalRouter, AnyModalRouter?>
    ) -> Binding<AnyModalRouter?> {
        Binding(
            get: { isReadyToPresent ? router[keyPath: keyPath] : nil },
            set: { router[keyPath: keyPath] = $0 }
        )
    }

    private var alertPresentation: Binding<Bool> {
        Binding(
            get: { isReadyToPresent && router.isAlertPresented },
            set: { router.isAlertPresented = $0 }
        )
    }
}

// MARK: - Cover content

/// A full-screen cover's content: the router's screen, or, for a cover with a
/// transition of its own, that screen inserted and removed with the transition
/// over a clear background. Such a cover is put up and taken down without
/// animation (see `AnyModalRouter.presented`); what the user sees move is this.
private struct CoverContent: View {

    let router: AnyModalRouter

    var body: some View {
        if let cover = router.transition.coverTransition {
            TransitionedCoverContent(router: router, cover: cover)
        } else {
            router.makeView()
        }
    }
}

/// Internal so the tests can host it: the test window presents no covers.
struct TransitionedCoverContent: View {

    let router: AnyModalRouter
    let cover: AnyModalRouter.CoverTransition

    var body: some View {
        // The container reaches past the safe area, not the content: a view
        // in the middle of a transition is drawn inside its layout frame, so
        // a background of the content that ignores the safe area would be cut
        // at the safe area while it transitions and jump to the edges once it
        // has. The container is therefore full-bleed, and the content gets
        // the safe area back as padding — which its own `ignoresSafeArea()`
        // sees through at every point of the transition.
        GeometryReader { proxy in
            ZStack {
                Color.clear
                if router.isCoverContentShown {
                    router.makeView()
                        .safeAreaPadding(proxy.safeAreaInsets)
                        .transition(cover.transition)
                }
            }
            .ignoresSafeArea()
        }
        .presentationBackground(.clear)
        .onAppear {
            withAnimation(cover.insertion) {
                router.isCoverContentShown = true
            }
        }
    }
}

// MARK: - Presentation slots

extension AnyModalRouter {

    var sheet: AnyModalRouter? {
        get { presented?.transition == .sheet ? presented : nil }
        set { presented = newValue }
    }

    var fullScreen: AnyModalRouter? {
        get {
            guard !isAlertPresented, presented?.transition.isFullScreen == true else { return nil }
            return presented
        }
        set { presented = newValue }
    }

    var popover: AnyModalRouter? {
        get { presented?.transition.isPopover == true ? presented : nil }
        set { presented = newValue }
    }
}
