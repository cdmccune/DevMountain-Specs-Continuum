//
//  PostError.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation

enum PostError: LocalizedError {
    case ckError(Error)
    case noPost
    case noComment
    
    var localizedDescription : String {
        switch self {
        case .ckError(let error):
            return "Error from cloudkit: \(error)"
        case .noPost:
            return "The post was not found"
        case .noComment:
            return "The comment was not found"
        }
    }
}
