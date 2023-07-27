//
//  String+Insert.swift
//  AppsPanelSDK
//
//  Created by Pierre Grimault on 06/03/2019.
//  Copyright © 2019 Apps Panel. All rights reserved.
//

extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert(separator: Self, every n: Int) {
        for index in indices.reversed() where index != startIndex &&
            distance(from: startIndex, to: index) % n == 0 {
                insert(contentsOf: separator, at: index)
        }
    }
    
    func inserting(separator: Self, every n: Int) -> Self {
        var string = self
        string.insert(separator: separator, every: n)
        return string
    }
}
