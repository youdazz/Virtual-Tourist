//
//  ErrorResponse.swift
//  Virtual Tourist
//
//  Created by Youda Zhou on 7/6/24.
//

import Foundation
struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
