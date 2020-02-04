//
//  SessionService.swift
//  Swiftui-Redux
//
//  Created by MD AL Mamun on 2020-01-29.
//  Copyright © 2020 MD AL Mamun. All rights reserved.
//

import Foundation

struct UserSession: Codable {
    var accessToken: String
}

extension UserSession: Equatable {
    static func == (_ lhs: UserSession,_ rhs: UserSession) -> Bool {
        return lhs.accessToken == rhs.accessToken
    }
}
