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
    @IBOutlet weak var SawmillPrice: UILabel!
    @IBOutlet weak var SawmillsOwned: UILabel!
    @IBOutlet weak var QuarryPrice: UILabel!
    @IBOutlet weak var QuarriesOwned: UILabel!
    @IBOutlet weak var MonumentPrice: UILabel!
    @IBOutlet weak var MonumentsOwned: UILabel!
    
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
         //let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        
        // Refer to which building was purchased here
        // TODO: Even consider finding a way to make this more succinct. There should be a way to generalize
        // building type + cost + resource availability
        switch button.tag {
        case 1: // House
            let goldCost = 7500 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750

            if(resourceManager.gold - goldCost >= 0)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: Int(-goldCost))
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
            let goldCost = 25000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill) * 5000
            
            print("Building cost: \(goldCost)")
            if(resourceManager.gold - goldCost >= 0)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: Int(-goldCost))
                bankManager.AddBuilding(buildingType: BUILDING.sawmill)
                
                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are resource-wise
                print("Can't afford")
            }
            break
        case 4:
            let goldCost = 50000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 10000
            let woodCost = 450 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 125)
            
            print("Building cost: \(goldCost)")
            if( resourceManager.gold >= goldCost && resourceManager.wood >= woodCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -goldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: -woodCost)
                bankManager.AddBuilding(buildingType: BUILDING.quarry)

                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are resource-wise
                print("Can't afford")
            }
            break
        case 4:
            let goldCost = 100000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 25000
            let stoneCost = 500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 150)
            
            print("Building cost: \(goldCost)")
            if( resourceManager.gold >= goldCost && resourceManager.stone >= stoneCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -goldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: -stoneCost)
                bankManager.AddBuilding(buildingType: BUILDING.monument)
                
                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are resource-wise
                print("Can't afford")
            }
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

        let sawmillGoldCost = 25000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill) * 5000
        
        let quarryGoldCost = 50000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 10000
        let quarryWoodCost = 450 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 125)

        let monumentGoldCost = 100000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 25000
        let monumentStoneCost = 500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 150)

        
        GoldLabel.text = String(resourceManager.gold)

        HousePrice.text = String("\(houseGoldCost)G")
        HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))
        
        FarmPrice.text = String("\(farmGoldCost)G, \(farmWoodCost)W")
        FarmsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm))

        SawmillPrice.text = String("\(sawmillGoldCost)G")
        SawmillsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill))

        QuarryPrice.text = String("\(quarryGoldCost)G, \(quarryWoodCost)W")
        QuarriesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry))

        MonumentPrice.text = String("\(monumentGoldCost)G, \(monumentStoneCost)S")
        MonumentsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument))

    }
}
