//
//  WithoutAnimation.swift
//  WorkoutTimer
//
//  Created by Yevhenii Lytvynenko on 06.06.2025.
//

import SwiftUI
import UIKit

@MainActor
public func withoutAnimation(_ action: () -> Void) {
    UIView.setAnimationsEnabled(false)
    defer { UIView.setAnimationsEnabled(true) }
    var transaction = Transaction(animation: .easeIn(duration: 0))
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        action()
    }
}
