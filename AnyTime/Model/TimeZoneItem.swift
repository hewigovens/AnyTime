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

extension TimeZoneItem {
    var area: Area {
        let array: [String] = self.title.split(separator: "/").map {$0.replacingOccurrences(of: "_", with: " ")}
        if array.count > 2 {
            return Area(continent: String(array[0]), country: String(array[1]), city: String(array[2]))
        } else if array.count == 2 {
            return Area(continent: String(array[0]), country: "", city: String(array[1]))
        }
        return Area(continent: String(array[0]), country: String(array[0]), city: String(array[0]))
    }
}
