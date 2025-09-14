//
//  AnyModalRouter.swift
//  SUISimpleRouting
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

    init(transition: Transition, presented: AnyModalRouter? = nil) {
        self.transition = transition
        self._presented = presented
        super.init()
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
        get { presented?.transition == .popover ? presented : nil }
        set { presented = newValue }
    }

    var alertRouter: AnyModalRouter? {
        get { presented?.transition == .alert ? presented : nil }
        set { presented = newValue }
    }
}

public extension AnyModalRouter {

    enum Transition: Hashable, Sendable {
        case sheet
        case fullScreen
        case popover
        case alert
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
                        attachmentAnchor: .rect(.bounds), // TODO: - Pass from transition
                        arrowEdge: .bottom, // TODO: - Pass from transition
                        content: { $0.makeView() }
                    )
                    .alert(item: $router.alertRouter) { $0.makeAlert() }
            } else {
                router.makeContentView()
            }
        }
        .onAppear { isReadyToPresent = true }
    }
}

// MARK: - Default Alert Maker

public extension AnyModalRouter {

    /// Override in subclasses that support `.alert` transition to provide concrete SwiftUI `Alert` instance to display.
    @MainActor
    @inlinable
    @available(*, renamed: "override makeAlert() in alert routers")
    func makeAlert() -> Alert {
        fatalError("[AnyModalRouter] makeAlert() should be overridden in subclasses when using `.alert` transition")
    }
}
