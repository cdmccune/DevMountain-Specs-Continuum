//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Curt McCune on 6/15/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
