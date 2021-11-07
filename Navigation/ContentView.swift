//
//  ContentView.swift
//  Navigation
//
//  Created by alex.huo on 2021/11/7.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable, Identifiable {
  var id = UUID()
  var first: Identified<FirstState.ID, FirstState?>?
}

enum AppAction {
  case first(FirstAction)
  case setNavigation(selection: UUID?)
}

struct AppEnvironment {
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case let .setNavigation(selection: .some(navigatedId)):
      state.first = Identified(FirstState(), id: navigatedId)
    case .setNavigation(selection: .none):
      state.first = nil
    default:
      ()
    }
    return .none
  },
  firstReducer
    .optional()
    .pullback(state: \Identified.value, action: .self, environment: { $0 })
    .optional()
    .pullback(
      state: \AppState.first,
      action: /AppAction.first,
      environment: { $0 }
    )
)

struct ContentView: View {
  let store: Store<AppState, AppAction>

  var body: some View {
    NavigationView {
      WithViewStore(store) { viewStore in
        VStack {
          Text(viewStore.id.uuidString.prefix(5))
          NavigationLink(
            tag: viewStore.id,
            selection: viewStore.binding(
              get: \.first?.id,
              send: AppAction.setNavigation(selection:))
          ) {
            IfLetStore(store.scope(
              state: \.first?.value,
              action: AppAction.first
            ), then: FirstView.init(store:))
          } label: {
            Text("Push")
          }
        }
        .navigationTitle("Root View")
      }
    }
  }
}

struct FirstState: Equatable, Identifiable {
  var id = UUID()
  var second: Identified<SecondState.ID, SecondState?>?
}

enum FirstAction {
  case second(SecondAction)
  case setNavigation(selection: UUID?)
}

let firstReducer = Reducer<FirstState, FirstAction, AppEnvironment>.combine(
  Reducer { state, action, env in
    switch action {
    case let .setNavigation(selection: .some(navigatedId)):
      state.second = Identified(SecondState(), id: navigatedId)
    case .setNavigation(selection: .none):
      state.second = nil
    default:
      ()
    }
    return .none
  },
  secondReducer
    .optional()
    .pullback(state: \Identified.value, action: .self, environment: { $0 })
    .optional()
    .pullback(
      state: \FirstState.second,
      action: /FirstAction.second,
      environment: { $0 }
    )
)

struct FirstView: View {
  let store: Store<FirstState, FirstAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text(viewStore.id.uuidString.prefix(5))
        NavigationLink(
          tag: viewStore.id,
          selection: viewStore.binding(
            get: \.second?.id,
            send: FirstAction.setNavigation(selection:))
        ) {
          IfLetStore(store.scope(
            state: \.second?.value,
            action: FirstAction.second
          ), then: SecondView.init(store:))
        } label: {
          Text("Push")
        }
      }
    }
    .navigationTitle("First View")
  }
}


struct SecondState: Equatable, Identifiable {
  var id = UUID()
}

enum SecondAction {
  case setNavigation(selection: UUID?)
}

let secondReducer = Reducer<SecondState, SecondAction, AppEnvironment> { state, action, env in
  return .none
}

struct SecondView: View {
  let store: Store<SecondState, SecondAction>

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text(viewStore.id.uuidString.prefix(5))
      }
      .navigationTitle("Second View")
    }
  }
}
