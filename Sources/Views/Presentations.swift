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
    /// A presentation set before the view is on screen waits for it to appear.
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
            .onAppear(perform: becomeReadyToPresent)
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
        ZStack {
            Color.clear
            if router.isCoverContentShown {
                router.makeView()
                    .transition(cover.transition)
            }
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
