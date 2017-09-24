//
//  Defaults.swift
//  AnyTime
//
//  Created by Tao Xu on 9/24/17.
//  Copyright © 2017 Tao Xu. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

public func registerDefaults() {
    UserDefaults.standard.register(defaults: ["favorites": [
        "UTC",
        "GMT",
        "HKT",
        "JST",
        "CST",
        "PDT"
    ]])
}

extension DefaultsKeys {
    static let favorites = DefaultsKey<[String]>("favorites")
}
