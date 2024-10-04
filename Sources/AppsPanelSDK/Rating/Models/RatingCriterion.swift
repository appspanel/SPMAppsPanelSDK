//
//  RatingCriterion.swift
//  Notation
//
//  Created by AppsPanel on 21/04/2022.
//

import Foundation

struct RatingCriterion: Decodable, Identifiable, Equatable, Hashable {
    typealias ID = Int
    
    var id: Int
    var name: String
}
