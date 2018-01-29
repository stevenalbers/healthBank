//
//  ViewController.swift
//  HealthBank
//
//  Created by Steven Albers on 1/3/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import UIKit
import HealthKit
import RealmSwift

class OverviewController: UIViewController {
    
    //let healthStore = HKHealthStore()
    let healthKitManager = HealthKitManager.sharedInstance
    let resourceManager = ResourceManager.sharedInstance
    let bankManager = StepBankManager()
    var stepCount: Int = 0  // TODO: Remove this if copying from healthkit is bad
    
    var goldMultiplier: Double = 1.0
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var FoodLabel: UILabel!
    @IBOutlet weak var WoodLabel: UILabel!
    @IBOutlet weak var StoneLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    @IBOutlet weak var CurrentMultiplier: UILabel!
    
    @IBOutlet weak var StepsLabel: UILabel!
    
    // Resource grid
    @IBOutlet weak var GoldGridAmount: UILabel!
    @IBOutlet weak var FoodGridAmount: UILabel!
    @IBOutlet weak var FoodGridBreakdown: UILabel!

    @IBOutlet weak var WoodGridAmount: UILabel!
    @IBOutlet weak var StoneGridAmount: UILabel!
    

    // TODO: update all resources here
    // Put this back when the system can handle it
    /*@IBAction func UpdateGold(_ sender: Any) {
        
        stepCount = QueryStepsSum(previousDate: bankManager.GetLastLogin())

        // This is terrible; use a callback instead
        // This sleep gives healthKit time to populate itself, but really this function should wait until
        // it receives some form of message from HK
        sleep(1)
        
        print("RM? steps: \(resourceManager.gold)")
        // Somehow this dumps all realm data?
        //print(bankManager.date)

        ConvertQueriedStepsToResources(stepsToAdd: stepCount)
        print("All steps: \(bankManager.GetStepBankValue())")

        GoldLabel.text = String(resourceManager.gold)
    }*/
    
    // TODO: Generalize this. Either use this for all resources or make a gatekeeper that can call this with any
    // resource as a parameter
    
    func ConvertQueriedStepsToResources(stepsToAdd: Int)
    {
        // TODO: Unify these variables so they're only computed once
        let populationGoldMultiplier = Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house)) * 0.2
        let multipliedGold = Int(Double(stepsToAdd) * (1 + (populationGoldMultiplier)))
        
        let foodToAdd = Int(((Double(stepsToAdd) / 25.0) * (Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm)) * 1.5)))
        
        let woodToAdd = Int(((Double(stepsToAdd) / 100.0) * (Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill)) * 1.5)))

        let stoneToAdd = Int(((Double(stepsToAdd) / 250.0) * (Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry)) * 1.5)))


        // Get the number of calendar days since last login. Because apparently people only eat at midnight
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: bankManager.GetLastLogin())
        let date2 = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)

        let foodToConsume = Int(components.day! * (resourceManager.population * 5))

        // Removed alongside label removal
//        let currentBuildingMultiplier = populationGoldMultiplier * 0.1
//        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Gold Added: \(multipliedGold)")
        print("Food Added: \(foodToAdd)")
        print("Food consumed: \(foodToConsume)")

        bankManager.AddResourceToBank(resource: RESOURCE.gold, toAdd: multipliedGold)

        bankManager.AddResourceToBank(resource: RESOURCE.food, toAdd: foodToAdd - foodToConsume)
        
        bankManager.AddResourceToBank(resource: RESOURCE.wood, toAdd: woodToAdd)

        bankManager.AddResourceToBank(resource: RESOURCE.stone, toAdd: stoneToAdd)


        // Update necessary labels here
        GoldGridAmount.text = String(Int(multipliedGold))
        FoodGridAmount.text = String(Int(foodToAdd))
        FoodGridBreakdown.text = String("(\(foodToAdd) - \(foodToConsume))")
        
        WoodGridAmount.text = String(Int(foodToAdd))
        StoneGridAmount.text = String(Int(foodToAdd))
        StepsLabel.text = String(stepsToAdd)
        CurrentMultiplier.text = String(1 + (populationGoldMultiplier))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.InitializeRealmData()
        
        GatherStepData()
        resourceManager.stepsQueried = QueryStepsSum(previousDate: bankManager.GetLastLogin())
        
        // This is terrible; use a callback instead
        // This sleep gives healthKit time to populate itself, but really this function should wait until
        // it receives some form of message from HK
        sleep(1)
        
        print("RM steps: \(resourceManager.stepsQueried)")
        // Somehow this dumps all realm data?
        //print(bankManager.date)
        
        ConvertQueriedStepsToResources(stepsToAdd: resourceManager.stepsQueried)
        print("All steps: \(bankManager.GetStepBankValue())")
        
        resourceManager.population = (bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 2) + 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        bankManager.UpdateResources()
        UpdateResourceBar()
    }
    
    func GatherStepData()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            // State the health data type(s) we want to read from HealthKit.
            let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            
            // State the health data type(s) we want to write from HealthKit.
            let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            
            // Request authorization to read and/or write the specific data.
            healthKitManager.healthStore?.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { (success, error) in
                if success {
                    print("success")
                } else {
                    print("failure")
                }
                
                if let error = error { print(error) }
            }
            
        }
        else
        {
            print("nope")
        }
    }
    
    // This query:
    // Get number of steps since last time
    func QueryStepsSum(previousDate: Date) -> Int {
        print("Last queried date: \(previousDate)\nCurrent date: \(Date())")
        var numberOfSteps: Int = 0
        let sumOption = HKStatisticsOptions.cumulativeSum
        let predicate = HKQuery.predicateForSamples(withStart: previousDate, end: Date(), options: .strictStartDate)
        let statisticsSumQuery = HKStatisticsQuery(quantityType: healthKitManager.stepCount!, quantitySamplePredicate: predicate, options: sumOption) { [unowned self] (query, result, error) in
            if let newStepQuantity = result?.sumQuantity() {
                numberOfSteps = Int(newStepQuantity.doubleValue(for: self.healthKitManager.goldUnit))
                print ("Query steps: \(numberOfSteps)")
                self.resourceManager.stepsQueried = numberOfSteps
            }
        }

        healthKitManager.healthStore?.execute(statisticsSumQuery)
        return numberOfSteps
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
    

}

