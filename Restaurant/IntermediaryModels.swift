//
//  IntermediaryModels.swift
//  Restaurant
//
//  Created by Kiki van Rongen on 07-05-18.
//  Copyright © 2018 Kiki van Rongen. All rights reserved.
//

import Foundation

struct Categories: Codable {
    let categories: [String]
}

struct PreparationTime: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}
