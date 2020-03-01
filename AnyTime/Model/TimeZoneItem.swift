//
//  TimeZoneItem.swift
//  AnyTime
//
//  Created by Tao Xu on 9/25/17.
//  Copyright © 2017 Tao Xu. All rights reserved.
//

import Foundation

struct TimeZoneItem: Equatable, Hashable {
    let abbr: String
    let title: String
    let timezone: TimeZone
}
