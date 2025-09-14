//
//  WithoutAnimation.swift
//  WorkoutTimer
//
//  Created by Yevhenii Lytvynenko on 06.06.2025.
//

import SwiftUI
import UIKit

func withoutAnimation(action: @escaping () -> Void) {
    UIView.setAnimationsEnabled(false)
    var transaction = Transaction(animation: .easeIn(duration: 0))
    transaction.disablesAnimations = true
    withTransaction(transaction) {
        action()
        UIView.setAnimationsEnabled(true)
    }
}
