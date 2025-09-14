//
//  Export.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 16.07.2024.
//

@_exported import SwiftUI

// MARK: - Public API Exports

// Core Types
public typealias MoviroModel = Model
public typealias MoviroBaseView = BaseView

// Router Types
public typealias MoviroRouter = AnyRouter
public typealias MoviroPushRouter = AnyPushRouter
public typealias MoviroModalRouter = AnyModalRouter
public typealias MoviroNavigationStackRouter = AnyNavigationStackRouter
public typealias MoviroTabBarRouter = AnyTabBarRouter
public typealias MoviroSplitRouter = AnySplitRouter

// Switch Routers
public typealias MoviroModalSwitchRouter = AnyModalSwitchRouter
public typealias MoviroPushSwitchRouter = AnyPushSwitchRouter

// Utilities
public typealias MoviroLogger = MoviroLogger
