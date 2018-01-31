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
    
    // Declare building costs here
    var houseGoldCost: Int!
    
    var farmGoldCost: Int!
    var farmWoodCost: Int!
    
    var sawmillGoldCost: Int!
    
    var quarryGoldCost: Int!
    var quarryWoodCost: Int!
    
    var monumentGoldCost: Int!
    var monumentStoneCost: Int!

    
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
        
        // Refer to which building was purchased here
        // TODO: Even consider finding a way to make this more succinct. There should be a way to generalize
        // building type + cost + resource availability
        switch button.tag {
        case 1: // House
            if(resourceManager.gold - houseGoldCost >= 0)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: Int(-houseGoldCost))
                bankManager.AddBuilding(buildingType: BUILDING.house)
                
                resourceManager.population = bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 2

                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are re`source-wise
                print("Can't afford")
            }
            break
        case 2: // Farm
            if( resourceManager.gold >= farmGoldCost && resourceManager.wood >= farmWoodCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -farmGoldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: -farmWoodCost)
                bankManager.AddBuilding(buildingType: BUILDING.farm)
                
                UpdateAllLabels()
            }
            else
            {
                print("Can't afford")
            }
            break
        case 3:
            if(resourceManager.gold - sawmillGoldCost >= 0)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: Int(-sawmillGoldCost))
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
            if( resourceManager.gold >= quarryGoldCost && resourceManager.wood >= quarryWoodCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -quarryGoldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: -quarryWoodCost)
                bankManager.AddBuilding(buildingType: BUILDING.quarry)

                UpdateAllLabels()
            }
            else
            {
                // TODO: add in how short you are resource-wise
                print("Can't afford")
            }
            break
        case 5:
            if( resourceManager.gold >= monumentGoldCost && resourceManager.stone >= monumentStoneCost)
            {
                bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: -monumentGoldCost)
                bankManager.AddResourceToBank(resource: RESOURCE.stone, toAdd: -monumentStoneCost)
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
        houseGoldCost = Int(7500.0 + Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 750))
        
        farmGoldCost = 4500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 450)
        farmWoodCost = 150 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 15)

        sawmillGoldCost = 25000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill) * 2500
        
        quarryGoldCost = 50000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 5000
        quarryWoodCost = 450 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 45)

        monumentGoldCost = 100000 + bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 200000
        monumentStoneCost = 500 + (bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument) * 1000)

        
        GoldLabel.text = String(resourceManager.gold)

        HousePrice.text = String("\(houseGoldCost!)G")
        HousesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house))
        
        FarmPrice.text = String("\(farmGoldCost!)G, \(farmWoodCost!)W")
        FarmsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm))

        SawmillPrice.text = String("\(sawmillGoldCost!)G")
        SawmillsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill))

        QuarryPrice.text = String("\(quarryGoldCost!)G, \(quarryWoodCost!)W")
        QuarriesOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry))

        MonumentPrice.text = String("\(monumentGoldCost!)G, \(monumentStoneCost!)S")
        MonumentsOwned.text = String(bankManager.GetNumberOfBuildings(buildingType: BUILDING.monument))

    }
}
