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
    let bankManager = StepBankManager.sharedInstance
    
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func PurchaseBuilding(_ sender: Any) {
        
        let currentSteps = bankManager.GetStepBankValue()
        let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Building cost: \(buildingCost)")
        
        if(Double(currentSteps) - buildingCost >= 0)
        {
            bankManager.AddStepsToBank(updatedSteps: Int(buildingCost) * -1)
            bankManager.AddBuilding()
            overviewController.StepLabel.text = String(bankManager.GetStepBankValue())
        }
        else
        {
            print("Can't afford")
        }
        overviewController.PurchasesMadeText.text = "Buildings Owned: \(bankManager.GetBuildingValue()) | Next Building Cost: \(buildingCost)"
        overviewController.CurrentMultiplierText.text = "Current multiplier: \(1 + (bankManager.GetBuildingValue() * 0.1))"
        
    }
}
