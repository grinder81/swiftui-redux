//
//  Redux.swift
//  Swiftui-Redux
//
//  Created by MD AL Mamun on 2020-01-28.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum ApplicationError: Error {
    case saveStoreFailed
    case loadStoreFailed
}

typealias Reducer<State, Action> = (inout State, Action) -> Void

func combine<State, Action>(_ reducers: Reducer<State, Action>...) -> Reducer<State, Action> {
    return { state, action in
        reducers.forEach { $0(&state, action) }
    }
}

func lift<ViewState, State, ViewAction, Action>(
    _ reducer: @escaping Reducer<ViewState, ViewAction>,
    keyPath: WritableKeyPath<State, ViewState>,
    transform: @escaping (Action) -> ViewAction?
) -> Reducer<State, Action> {
    return { state, action in
        if let localAction = transform(action) {
            reducer(&state[keyPath: keyPath], localAction)
        }
    }
}

final class Store<State, Action>: ObservableObject {
    typealias Effect = AnyPublisher<Action, Never>

    @Published private(set) var state: State

    private let reducer: Reducer<State, Action>
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellable: AnyCancellable?

    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }

    var statePublisher: AnyPublisher<State, Never> {
        return $state.eraseToAnyPublisher()
    }
    
    func send(_ action: Action) {
        reducer(&state, action)
    }

    func send(_ effect: Effect){
        var didComplete = false
        var cancellable: AnyCancellable?
        cancellable = effect
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                didComplete = true
                if let cancellable = cancellable {
                    self?.cancellables.remove(cancellable)
                }
            }, receiveValue: send)
        if !didComplete, let cancellable = cancellable {
            cancellables.insert(cancellable)
        }
    }
}

extension Store {
    func view<ViewState, ViewAction>(
        state toLocalState: @escaping (State) -> ViewState,
        action toGlobalAction: @escaping (ViewAction) -> Action
    ) -> Store<ViewState, ViewAction> {
        let viewStore = Store<ViewState, ViewAction>(
            initialState: toLocalState(state)
        ) { state, action in
            self.send(toGlobalAction(action))
        }
        viewStore.viewCancellable = $state
            .map(toLocalState)
            .assign(to: \.state, on: viewStore)
        return viewStore
    }
}

extension Store {
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        _ action: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(action($0)) }
        )
    }
}

extension Store where State: Codable {
    func save(_ handler: @escaping (Result<Void, Error>) -> Void ) {
        DispatchQueue.global(qos: .utility).async {
            let files = FileManager.default
            guard
                let documentsURL = files.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
                let data = try? JSONEncoder().encode(self.state)
                else {
                    DispatchQueue.main.async {
                        handler(.failure(ApplicationError.saveStoreFailed))
                    }
                    return
                }

            try? files.createDirectory(
                at: documentsURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            let stateURL = documentsURL.appendingPathComponent("state.json")

            if files.fileExists(atPath: stateURL.absoluteString) {
                try? files.removeItem(at: stateURL)
            }

            try? data.write(to: stateURL, options: .atomic)
            DispatchQueue.main.async {
                handler(.success(()))
            }
        }
    }

    func load(_ handler: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let files = FileManager.default
            guard
                let documentsURL = files.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
                let data = try? Data(contentsOf: documentsURL.appendingPathComponent("state.json")),
                let state = try? JSONDecoder().decode(State.self, from: data)
                else {
                    DispatchQueue.main.async {
                        handler(.failure(ApplicationError.loadStoreFailed))
                    }
                    return
                }

            DispatchQueue.main.async {
                self.state = state
                handler(.success(()))
            }
        }
    }
}


enum AppAction {
    case stateRestored
    case changeRoot(path: RootState)
    case changeOnboarding(state: OnboardingState?)
}

struct AppState: Codable {
    var path: RootState = .launching
    var onboarding: OnboardingState?
    var session: UserSession?
}

extension AppState {
    static func makeState() -> AppState {
        return AppState()
    }
}

func appReducer(state: inout AppState, action: AppAction) {
    switch action {
    case .changeRoot(let path):
        state.path = path
    case .changeOnboarding(let onboardingState):
        state.onboarding = onboardingState
    case .stateRestored:
        if let _ = state.session {
            state.path = .signedIn
        } else {
            state.path = .onBoarding
        }
    }
}
