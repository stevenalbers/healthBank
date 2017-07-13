//
//  HealthKitManager.swift
//  HealthBank
//
//  Created by Steven Albers on 1/4/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import HealthKit

class HealthKitManager {
    
    class var sharedInstance: HealthKitManager {
        struct Singleton {
            static let instance = HealthKitManager()
        }
        
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let stepCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
    
    let goldUnit = HKUnit.count()
}
