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
    case monument
}

class BuildingViewController: UIViewController {
    let healthKitManager = HealthKitManager.sharedInstance
    let resourceManager = ResourceManager.sharedInstance

    let bankManager = StepBankManager()
    
    @IBOutlet weak var HouseCost: UILabel!
    @IBOutlet weak var HousesOwned: UILabel!
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoldLabel.text = String(resourceManager.gold)
        HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UpdateResourceBar()
    }

    
    // Link all building purchase taps here, and add the appropriate building
    @IBAction func PurchaseBuilding(sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        let currentGold = bankManager.GetStepBankValue()
        //let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        
        // Refer to which building was purchased here
        switch button.tag {
        case 1: // House
            let buildingCost = 7500.0

            print("Building cost: \(buildingCost)")
            if(Double(currentGold) - buildingCost >= 0)
            {
                bankManager.AddGoldToBank(updatedGold: Int(buildingCost) * -1)
                bankManager.AddBuilding(buildingType: BUILDING.house)
                GoldLabel.text = String(resourceManager.gold)
                HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))
            }
            else
            {
                print("Can't afford")
            }
            break
        case 2:
            print("Farm not implemented.")
            break
        case 3:
            print("Sawmill not implemented.")
            break
        case 4:
            print("Quarry not implemented.")
            break
        case 4:
            print("Monument not implemented.")
            break
        default: // Failure
            print("Unknown building")
            break
        }
        
        
    }
    
    func UpdateResourceBar()
    {
        // Resource bar
        GoldLabel.text = String(resourceManager.gold)
        PopulationLabel.text = String(resourceManager.population)
    }
}
