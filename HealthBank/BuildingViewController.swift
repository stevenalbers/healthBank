//
//  BuildingViewController.swift
//  HealthBank
//
//  Created by Steven Albers on 5/28/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import UIKit
import HealthKit
import RealmSwift

class BuildingViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance
    let bankManager = StepBankManager()
    
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func PurchaseBuilding(_ sender: Any) {
        
        let currentGold = bankManager.GetStepBankValue()
        let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Building cost: \(buildingCost)")
        
        if(Double(currentGold) - buildingCost >= 0)
        {
            bankManager.AddGoldToBank(updatedGold: Int(buildingCost) * -1)
            bankManager.AddBuilding()
        }
        else
        {
            print("Can't afford")
        }
        
    }
}
