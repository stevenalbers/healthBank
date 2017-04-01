//
//  UserDefaults.swift
//  HealthBank
//
//  Created by Steven Albers on 1/15/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import Foundation
import UIKit

private var firstLaunch : Bool = false

extension UIApplication {
    
    static func isFirstLaunch() -> Bool {
        let firstLaunchFlag = "LotFirstLaunchFlag"
        let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
        if (isFirstLaunch) {
            firstLaunch = isFirstLaunch
            UserDefaults.standard.set("false", forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        return firstLaunch || isFirstLaunch
    }
}
