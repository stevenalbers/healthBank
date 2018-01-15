//
//  ResourceManager.swift
//  HealthBank
//
//  Created by Steven Albers on 5/28/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import Foundation

class ResourceManager
{
    var gold: Int = 0
    var food: Int = 0
    var wood: Int = 0
    var stone: Int = 0
    var population: Int = 0

    static let sharedInstance = ResourceManager()
}
