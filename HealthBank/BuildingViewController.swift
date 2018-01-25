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
    
    @IBOutlet weak var HousePrice: UILabel!
    @IBOutlet weak var HousesOwned: UILabel!
    @IBOutlet weak var FarmPrice: UILabel!
    @IBOutlet weak var FarmsOwned: UILabel!
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var FoodLabel: UILabel!
    @IBOutlet weak var WoodLabel: UILabel!
    @IBOutlet weak var StoneLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    var overviewController = OverviewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bankManager.UpdateResources()
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
        // TODO: Even consider finding a way to make this more succinct. There should be a way to generalize
        // building type + cost + resource availability
        switch button.tag {
        case 1: // House
            let goldCost = 7500.0 + Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750)

            print("Building cost: \(goldCost)")
            if(Double(currentGold) - goldCost >= 0)
            {
                bankManager.AddGoldToBank(updatedGold: Int(goldCost) * -1)
                bankManager.AddBuilding(buildingType: BUILDING.house)
                
                resourceManager.population = bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 2

                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are resource-wise
                print("Can't afford")
            }
            break
        case 2: // Farm
            let goldCost = 4500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 500)
            let woodCost = 150 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 50)
            
            if( resourceManager.gold >= goldCost && resourceManager.wood >= woodCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -goldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: -woodCost)
                bankManager.AddBuilding(buildingType: BUILDING.farm)
                
                
                
                UpdateAllLabels()
            }
            else
            {
                print("Can't afford")
            }
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
        bankManager.UpdateResources()

        // Resource bar
        GoldLabel.text = String(resourceManager.gold)
        FoodLabel.text = String(resourceManager.food)
        WoodLabel.text = String(resourceManager.wood)
        StoneLabel.text = String(resourceManager.stone)
        PopulationLabel.text = String(resourceManager.population)
    }
    
    func UpdateBuildingLabels()
    {
        let houseGoldCost = Int(7500.0 + Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750))
        
        let farmGoldCost = 4500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 500)
        let farmWoodCost = 150 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 50)

        
        GoldLabel.text = String(resourceManager.gold)

        HousePrice.text = String("\(houseGoldCost)G")
        HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))
        
        FarmPrice.text = String("\(farmGoldCost)G, \(farmWoodCost)W")
        FarmsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm))


    }
}
