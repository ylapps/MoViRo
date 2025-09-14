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

    init() { debugLog("🧩 [MODEL] \(Self.self) init") }
    deinit { debugLog("☠️ [MODEL] \(Self.self) deinit") }

    // MARK: Life cycle

    open func onAppear() { debugLog("💡 [MODEL] \(Self.self) appear") }
    open func onDisappear() { debugLog("🫣 [MODEL] \(Self.self) disappear") }
}
