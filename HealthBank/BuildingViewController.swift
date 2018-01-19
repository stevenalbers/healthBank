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
    
    // Building costs
    var houseCost: Int!
    
    @IBOutlet weak var HouseCost: UILabel!
    @IBOutlet weak var HousePrice: UILabel!
    @IBOutlet weak var HousesOwned: UILabel!
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UpdateAllLabels()
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
            let buildingCost = 7500.0 + Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750)

            print("Building cost: \(buildingCost)")
            if(Double(currentGold) - buildingCost >= 0)
            {
                bankManager.AddGoldToBank(updatedGold: Int(buildingCost) * -1)
                bankManager.AddBuilding(buildingType: BUILDING.house)
                
                resourceManager.population = bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 2

                UpdateAllLabels()
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
    
    func UpdateAllLabels()
    {
        UpdateResourceBar()
        UpdateBuildingLabels()
    }
    
    func UpdateResourceBar()
    {
        // Resource bar
        GoldLabel.text = String(resourceManager.gold)
        PopulationLabel.text = String(resourceManager.population)
    }
    
    func UpdateBuildingLabels()
    {
        let houseCost = Int(7500.0 + Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750))
        
        GoldLabel.text = String(resourceManager.gold)

        HousePrice.text = String("\(houseCost)G")
        HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))

    }
}
