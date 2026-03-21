//
//  AnyModalRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI

// MARK: - Router

@Observable
open class AnyModalRouter: AnyRouter {

    // MARK: State
    
    /// Current modal transition
    public let transition: Transition
    
    /// Router which presents this router.
    @ObservationIgnored
    public internal(set) weak var presenting: AnyModalRouter?

    /// Router presented from this router.
    public var presented: AnyModalRouter? {
        willSet {
            presented?.presenting = nil
            newValue?.presenting = self
        }
    }

    // MARK: Initialization

    public init(transition: Transition, presented: AnyModalRouter? = nil) {
        self.transition = transition
        self._presented = presented
        super.init()
        presented?.presenting = self
    }

    // MARK: Makers

    public final func makeView() -> some View {
        AnyModalView(router: self)
    }
}

private extension AnyModalRouter {

    var sheet: AnyModalRouter? {
        get { presented?.transition == .sheet ? presented : nil }
        set { presented = newValue }
    }

    var fullScreen: AnyModalRouter? {
        get { presented?.transition == .fullScreen ? presented : nil }
        set { presented = newValue }
    }

    var popover: AnyModalRouter? {
        get { presented?.transition.isPopover == true ? presented : nil }
        set { presented = newValue }
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
}

// MARK: - View

struct AnyModalView: View {

    @State var router: AnyModalRouter
    @State private var isReadyToPresent = false

    var body: some View {
        Group {
            if isReadyToPresent {
                router.makeContentView()
                    .routerAlert($router.alert)
                    .sheet(
                        item: $router.sheet,
                        content: { $0.makeView() }
                    )
                    .fullScreenCover(
                        item: $router.fullScreen,
                        content: { $0.makeView() }
                    )
                    .popover(
                        item: $router.popover,
                        attachmentAnchor: router.popover?.transition.popoverAttachmentAnchor ?? .rect(.bounds),
                        arrowEdge: router.popover?.transition.popoverArrowEdge,
                        content: { $0.makeView() }
                    )
            } else {
                router.makeContentView()
            }
        }
        .onAppear { isReadyToPresent = true }
    }
}
