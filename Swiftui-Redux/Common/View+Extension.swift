//
//  View+Extension.swift
//  Swiftui-Redux
//
//  Created by MD AL Mamun on 2020-01-29.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import SwiftUI

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
