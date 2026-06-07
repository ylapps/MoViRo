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

final class StubResultPushRouter: ResultPushRouter<StubResultView, String> {
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubVoidResultPushRouter: ResultPushRouter<StubResultView, Void> {
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubResultModalRouter: ResultModalRouter<StubResultView, Int> {
    init() { super.init(transition: .sheet) }
    override func makeModel() -> StubResultModel { StubResultModel() }
}

final class StubVoidResultModalRouter: ResultModalRouter<StubResultView, Void> {
    init() { super.init(transition: .sheet) }
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
