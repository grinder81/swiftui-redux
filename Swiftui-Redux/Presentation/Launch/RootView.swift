//
//  LaunchView.swift
//  Swiftui-Redux
//
//  Created by MD AL Mamun on 2020-01-28.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import SwiftUI
import Combine

enum RootState: String, Codable {
    case launching
    case onBoarding
    case signedIn
}

struct RootView: View {
    @EnvironmentObject var store: Store<AppState, AppAction>

    private var onboarding: Binding<OnboardingState?> {
        store.binding(for: \.onboarding) { .changeOnboarding(state: $0) }
    }
    
    var body: some View {
        VStack {
            makeView()
        }.onAppear {
            self.store.load { (result) in
                switch result {
                case .success:
                    self.store.send(.stateRestored)
                    break
                case .failure:
                    self.store.send(.changeRoot(path: .onBoarding))
                    break
                }
            }
        }
    }
    
    private func makeView() -> AnyView {
        switch store.state.path {
        case .launching:
            return Text("Loading").eraseToAnyView()
        case .onBoarding:
            return OnboardingView(state: self.onboarding).eraseToAnyView()
        case .signedIn:
            return Text("App Running").eraseToAnyView()
        }
    }
    
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
