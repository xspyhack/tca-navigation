//
//  NavigationApp.swift
//  Navigation
//
//  Created by alex.huo on 2021/11/7.
//

import SwiftUI
import ComposableArchitecture

@main
struct NavigationApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
              store: Store(
                initialState: AppState(),
                reducer: appReducer,
                environment: AppEnvironment()
              )
            )
        }
    }
}
