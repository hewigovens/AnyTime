//
//  String+Utils.swift
//  AnyTime
//
//  Created by Tao Xu on 10/2/17.
//  Copyright © 2017 Tao Xu. All rights reserved.
//

import Foundation

extension String {
    var length: Int {
        return self.lengthOfBytes(using: .utf8)
    }
}
