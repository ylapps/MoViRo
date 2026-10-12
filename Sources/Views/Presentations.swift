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
    /// A presentation set before the view is on screen waits for the
    /// transition that brings the view in to finish, so a chain of them set
    /// up front — a deep link — lands one level after another.
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
            .background {
                // Readiness is UIKit's `viewDidAppear`, not SwiftUI's `onAppear`:
                // the latter fires while this view's own presentation is still
                // animating, and a presentation asked for then — the next level
                // of a deep link, three modals deep — is built but never reaches
                // the window. `viewDidAppear` fires once the transition is over.
                PresentationReadiness(onDidAppear: becomeReadyToPresent)
                    .frame(width: 0, height: 0)
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

// MARK: - Readiness

/// Reports the UIKit appearance of the view it sits in: the hosting
/// controller's `viewDidAppear`, forwarded to this child, fires once the
/// presentation transition that brought the view in has finished.
private struct PresentationReadiness: UIViewControllerRepresentable {

    let onDidAppear: () -> Void

    func makeUIViewController(context: Context) -> PresentationReadinessController {
        PresentationReadinessController(onDidAppear: onDidAppear)
    }

    func updateUIViewController(_ controller: PresentationReadinessController, context: Context) {
        controller.onDidAppear = onDidAppear
    }
}

private final class PresentationReadinessController: UIViewController {

    var onDidAppear: () -> Void

    init(onDidAppear: @escaping () -> Void) {
        self.onDidAppear = onDidAppear
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onDidAppear()
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
