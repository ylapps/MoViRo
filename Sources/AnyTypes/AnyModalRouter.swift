//
//  AnyModalRouter.swift
//  SUISimpleRouting
//
//  Created by Yevhenii Lytvynenko on 15.11.2024.
//

import SwiftUI
import Observation

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
    public var presented: AnyModalRouter? = nil {
        willSet {
            presented?.presenting = nil
            newValue?.presenting = self
        }
    }

    // MARK: Initialization

    init(transition: Transition, presented: AnyModalRouter? = nil) {
        self.transition = transition
        super.init()
        self.presented = presented
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
}

public extension AnyModalRouter {

    enum Transition: Hashable, Sendable {
        case sheet
        case fullScreen
        case popover
    }
}

// MARK: - View

struct AnyModalView: View {

    @Bindable var router: AnyModalRouter
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
            } else {
                router.makeContentView()
            }
        }
        .onAppear { isReadyToPresent = true }
    }
}
