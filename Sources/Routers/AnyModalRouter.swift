//
//  AnyModalRouter.swift
//  Moviro
//

import SwiftUI

@Observable
open class AnyModalRouter: AnyRouter {

    // MARK: State

    /// Current modal transition
    public let transition: Transition

    /// Router which presents this router.
    @ObservationIgnored
    weak var presenting: AnyModalRouter?

    /// Router presented from this router.
    ///
    /// Setting it presents the new router and dismisses the old one. A cover
    /// with a transition of its own (`.fullScreen(transition:)`) is dismissed
    /// in two steps: its content leaves with that transition first, and the
    /// cover goes once the content has — so the value read here changes only
    /// then, and whatever was set last while the content was leaving wins.
    public var presented: AnyModalRouter? {
        get { presentedStorage }
        set { setPresented(newValue) }
    }

    private var presentedStorage: AnyModalRouter?

    /// For a cover with a transition of its own: whether its content is in
    /// the view. The cover sets it once it is on screen, which inserts the
    /// content with the transition; the presenting router clears it ahead of
    /// the cover's own dismissal, which removes the content the same way.
    var isCoverContentShown = false

    /// What `presented` becomes once the leaving cover's content has gone.
    @ObservationIgnored
    private var pendingPresented: PendingPresentation?

    // MARK: Initialization

    init(transition: Transition) {
        self.transition = transition
        super.init()
    }

    // MARK: Presenting

    private func setPresented(_ newValue: AnyModalRouter?) {
        if pendingPresented != nil {
            // The current cover's content is already leaving; this is what
            // lands once it has gone.
            pendingPresented = PendingPresentation(router: newValue)
            return
        }
        if let leaving = presentedStorage, let cover = leaving.transition.coverTransition, leaving.isCoverContentShown {
            pendingPresented = PendingPresentation(router: newValue)
            withAnimation(cover.removal) {
                leaving.isCoverContentShown = false
            } completion: { [weak self] in
                guard let self, let pending = pendingPresented else { return }
                pendingPresented = nil
                commitPresented(pending.router)
            }
            return
        }
        commitPresented(newValue)
    }

    private func commitPresented(_ newValue: AnyModalRouter?) {
        let leaving = presentedStorage
        leaving?.presenting = nil
        newValue?.presenting = self
        guard leaving?.transition.coverTransition != nil || newValue?.transition.coverTransition != nil else {
            presentedStorage = newValue
            return
        }
        // The cover itself never slides: it is put up over a clear background
        // for its content to transition into, and by the time it is taken
        // down its content has already left.
        withTransaction(\.disablesAnimations, true) {
            presentedStorage = newValue
        }
    }

    private struct PendingPresentation {
        let router: AnyModalRouter?
    }
}

public extension AnyModalRouter {

    enum Transition: Hashable {
        case sheet
        case fullScreen
        case popover(
            attachmentAnchor: PopoverAttachmentAnchor = .rect(.bounds),
            arrowEdge: Edge? = nil
        )
        /// A full-screen cover with a transition of its own; made with
        /// `fullScreen(transition:animation:removal:)`.
        case transitionedFullScreen(CoverTransition)

        /// A full-screen cover whose content enters and leaves with
        /// `transition` instead of the system's slide.
        ///
        /// The cover is put up without animation over a clear presentation
        /// background, and once it is on screen the router's screen is
        /// inserted with `transition` under `animation`. Dismissing the router
        /// — `requestClose()`, `close()`, or the presenting router's
        /// `presented` changing — removes the screen with the same transition
        /// under `removal` (`animation` when nil) and takes the cover down,
        /// again without animation, once that has finished. The screen's own
        /// background therefore shows the presenting screen through wherever
        /// the transition leaves it clear, which is what a fade over the
        /// previous screen needs.
        public static func fullScreen(
            transition: AnyTransition,
            animation: Animation = .default,
            removal: Animation? = nil
        ) -> Transition {
            .transitionedFullScreen(
                CoverTransition(transition: transition, insertion: animation, removal: removal ?? animation)
            )
        }

        /// Both kinds of full-screen cover.
        var isFullScreen: Bool {
            switch self {
            case .fullScreen, .transitionedFullScreen: return true
            case .sheet, .popover: return false
            }
        }

        var coverTransition: CoverTransition? {
            if case .transitionedFullScreen(let cover) = self { return cover }
            return nil
        }

        var isPopover: Bool {
            if case .popover = self { return true }
            return false
        }

        var popoverAttachmentAnchor: PopoverAttachmentAnchor {
            if case .popover(let anchor, _) = self { return anchor }
            return .rect(.bounds)
        }

        var popoverArrowEdge: Edge? {
            if case .popover(_, let edge) = self { return edge }
            return nil
        }

        // MARK: Hashable

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .sheet: hasher.combine(0)
            case .fullScreen: hasher.combine(1)
            case .popover: hasher.combine(2)
            case .transitionedFullScreen: hasher.combine(3)
            }
        }

        // MARK: Equatable

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.sheet, .sheet), (.fullScreen, .fullScreen), (.popover, .popover),
                 (.transitionedFullScreen, .transitionedFullScreen):
                return true
            default:
                return false
            }
        }
    }

    /// How a `.fullScreen(transition:)` cover's content comes and goes.
    struct CoverTransition {
        public let transition: AnyTransition
        public let insertion: Animation
        public let removal: Animation
    }

    var isAlertPresented: Bool {
        get { presentedAlert != nil }
        set {
            guard !newValue else { return }
            presented = nil
        }
    }

    var presentedAlert: AlertRouter? {
        presented as? AlertRouter
    }
}
