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

enum BUILDING : String {
    case house
    case farm
    case sawmill
    case quarry
}

class BuildingViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance
    let bankManager = StepBankManager()
    
    @IBOutlet weak var GoldLabel: UILabel!
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoldLabel.text = String(bankManager.GetStepBankValue())
    }
    
    // Link all building purchase taps here, and add the appropriate building
    @IBAction func PurchaseBuilding(sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let currentGold = bankManager.GetStepBankValue()
        let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        
        // Refer to which building was purchased here
        switch button.tag {
        case 1: // House
            print("Building cost: \(buildingCost)")
            if(Double(currentGold) - buildingCost >= 0)
            {
                bankManager.AddGoldToBank(updatedGold: Int(buildingCost) * -1)
                bankManager.AddBuilding(buildingType: BUILDING.house)
                GoldLabel.text = String(bankManager.GetStepBankValue())
            }
            else
            {
                print("Can't afford")
            }        default: // Failure
            print("Unknown building")
            return
        }
        
        
    }
}
