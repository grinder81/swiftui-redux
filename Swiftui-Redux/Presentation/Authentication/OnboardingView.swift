//
//  WelcomeView.swift
//  Swiftui-Redux
//
//  Created by MD AL Mamun on 2020-02-02.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import SwiftUI

enum OnboardingState: Int, Codable {
    case welcome
    case signIn
    case signUp
}

struct OnboardingView: View {

    @Binding var state: OnboardingState?
    
    var body: some View {
        NavigationView {
            self.makeView()
        }
    }
    
    func makeView() -> AnyView {
        return VStack {
            Text("Welcome Page")
            
            NavigationLink(destination: SignInView(),
                           tag: .signIn,
                           selection: $state) {
                Text("Sign In")
            }
            
            NavigationLink(destination: SignUpView(),
                           tag: .signUp,
                           selection: $state) {
                Text("Sign Up")
            }
        }.eraseToAnyView()
    }
    
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(state: .constant(.welcome))
    }
}
