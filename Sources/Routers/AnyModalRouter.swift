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
    public var presented: AnyModalRouter? {
        willSet {
            presented?.presenting = nil
            newValue?.presenting = self
        }
    }

    // MARK: Initialization

    init(transition: Transition) {
        self.transition = transition
        super.init()
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
            }
        }

        // MARK: Equatable

        public static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.sheet, .sheet), (.fullScreen, .fullScreen), (.popover, .popover):
                return true
            default:
                return false
            }
        }
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
