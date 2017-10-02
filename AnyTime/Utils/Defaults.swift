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
    UserDefaults.standard.register(defaults:[
        "favorites": [
        "GMT",
        "Asia/Shanghai",
        "Asia/Tokyo",
        "America/New_York",
        "America/Los_Angeles",
        "America/Chicago"
    ],
        "format": "HH:mm MMM d yyyy"
    ])
}

enum AnyTimeKey: String {
    case favorites
    case format
}

extension DefaultsKeys {
    static let favorites = DefaultsKey<[String]>(AnyTimeKey.favorites.rawValue)
    static let format = DefaultsKey<String>(AnyTimeKey.format.rawValue)
}

extension TimeZoneItem {
    static func get(ids: [String]) -> [TimeZoneItem] {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "vvvv"
        var dict = [String: String]()
        for (key, value) in TimeZone.abbreviationDictionary {
            dict[value] = key
        }
        let items = ids.map { identifier -> TimeZoneItem in
            let timezone = TimeZone(identifier: identifier)!
            formatter.timeZone = timezone
             var abbr = "GMT"
            if let val = dict[identifier] {
                abbr = val
            } else if let _abbr = timezone.abbreviation() {
                if _abbr.hasPrefix("GMT") {
                    let array = formatter.string(from: date)
                        .split(separator: " ")
                    if array.count > 2 {
                        abbr = array.map { String($0.prefix(1)) }
                            .joined()
                    }
                }
            }
            return TimeZoneItem(abbr: abbr, title: identifier,
                                timezone: timezone)
        }
        return items.filter {$0.abbr.length > 0}
    }
}
