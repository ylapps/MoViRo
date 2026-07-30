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

// MARK: - Result Router Stubs

struct StubResultView: BaseView {
    @State var model: StubResultModel
    init(model: StubResultModel) { self.model = model }
    var body: some View { EmptyView() }
}

@Observable
final class StubResultModel: Model<Never> {}

final class StubResultPushRouter: PushRouterWithCloseReason<StubResultView, String> {
    override init(onWillCloseWithReason: ReasonHandler? = nil) { super.init(onWillCloseWithReason: onWillCloseWithReason) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubVoidResultPushRouter: PushRouter<StubResultView> {
    override init(onWillClose: (() -> Void)? = nil) { super.init(onWillClose: onWillClose) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubResultModalRouter: ModalRouterWithCloseReason<StubResultView, Int> {
    init(onWillCloseWithReason: ReasonHandler? = nil) { super.init(transition: .sheet, onWillCloseWithReason: onWillCloseWithReason) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubVoidResultModalRouter: ModalRouter<StubResultView> {
    init(onWillClose: (() -> Void)? = nil) { super.init(transition: .sheet, onWillClose: onWillClose) }
    override func makeModel() -> StubResultModel { StubResultModel() }
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
