//
//  PushRouter.swift
//  Moviro
//
//  Created by Yevhenii Lytvynenko on 24.11.2024.
//

import SwiftUI

/// A push router that carries no typed closing result.
/// This is the standard base class for push-based screen routers.
public typealias PushRouter<ViewType: BaseView> = ResultPushRouter<ViewType, Void>

public typealias NavigationStackRouter = AnyNavigationStackRouter
