//
//  TestHelpers.swift
//  MoviroTests
//

@testable import Moviro
import SwiftUI

// MARK: - Stub Routers

final class StubModalRouter: AnyModalRouter {
    override func makeContentView() -> AnyView {
        AnyView(EmptyView())
    }
}

final class StubPushRouter: AnyPushRouter {
    override func makeContentView() -> AnyView {
        AnyView(EmptyView())
    }
}

final class ClosableModalRouter: AnyModalRouter, ClosableRouter {
    override func makeContentView() -> AnyView {
        AnyView(EmptyView())
    }
}

final class ClosablePushRouter: AnyPushRouter, ClosableRouter {
    override func makeContentView() -> AnyView {
        AnyView(EmptyView())
    }
}

// MARK: - Spy Model

final class SpyModel: AnyModel {
    var onAppearCount = 0
    var onDisappearCount = 0

    override func onAppear() {
        onAppearCount += 1
    }
    override func onDisappear() {
        onDisappearCount += 1
    }
}

// MARK: - Stub ViewModel (for ModelComposer)

final class StubViewModel {
    let id: String
    init(id: String) {
        self.id = id
    }
}
