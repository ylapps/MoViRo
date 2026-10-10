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
            .fullScreenCover(item: presentation(\.fullScreen)) { $0.makeView() }
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
            .onAppear { isReadyToPresent = true }
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

// MARK: - Presentation slots

extension AnyModalRouter {

    var sheet: AnyModalRouter? {
        get { presented?.transition == .sheet ? presented : nil }
        set { presented = newValue }
    }

    var fullScreen: AnyModalRouter? {
        get {
            guard !isAlertPresented, presented?.transition == .fullScreen else { return nil }
            return presented
        }
        set { presented = newValue }
    }

    var popover: AnyModalRouter? {
        get { presented?.transition.isPopover == true ? presented : nil }
        set { presented = newValue }
    }
}
