//
//  AnyModel.swift
//  ModalPet
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import Foundation

@MainActor
open class AnyModel {

    // MARK: State

    private var appearingCount = 0

    public internal(set) var isAppeared: Bool = false {
        didSet {
            if isAppeared {
                if appearingCount == 0 {
                    onAppear()
                }
                appearingCount += 1
            } else {
                appearingCount -= 1
                if appearingCount == 0 {
                    onDisappear()
                }
            }
        }
    }

    // MARK: Initialization

    init() { print("🧩 [MODEL] \(Self.self) init") }
    deinit { print("☠️ [MODEL] \(Self.self) deinit") }

    // MARK: Life cycle

    open func onAppear() { print("💡 [MODEL] \(Self.self) appear") }
    open func onDisappear() { print("🫣 [MODEL] \(Self.self) disappear") }
}
