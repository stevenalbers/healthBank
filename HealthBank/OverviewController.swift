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
    @IBOutlet weak var PopulationLabel: UILabel!
    
    
    @IBOutlet weak var DialogBox: UILabel!
    @IBOutlet weak var PurchasesMadeText: UILabel!
    @IBOutlet weak var CurrentMultiplier: UILabel!
    
    @IBOutlet weak var StepsLabel: UILabel!
    
    // Resource grid
    @IBOutlet weak var GoldGridAmount: UILabel!
    

    // TODO: update all resources here
    @IBAction func UpdateGold(_ sender: Any) {
                
        // This is terrible; use a callback instead
        // This sleep gives healthKit time to populate itself, but really this function should wait until
        // it receives some form of message from HK
        sleep(1)
        
        print("RM Gold: \(resourceManager.gold)")
        // Somehow this dumps all realm data?
        //print(bankManager.date)

        AddQueriedGoldToBank(goldToAdd: queryGoldSum(previousDate: bankManager.GetLastLogin()))
        print("All Gold: \(bankManager.GetStepBankValue())")

        GoldLabel.text = String(resourceManager.gold)
    }
    
    // TODO: Generalize this. Either use this for all resources or make a gatekeeper that can call this with any
    // resource as a parameter
    func AddQueriedGoldToBank(goldToAdd: Int)
    {
        // TODO: Unify these variables so they're only computed once
        let populationGoldMultiplier = Double(bankManager.GetNumberOfBuildings(buildingType: BUILDING.house)) * 0.2

        let multipliedGold = Double(goldToAdd) * (1 + (populationGoldMultiplier))
        
        // Removed alongside label removal
//        let currentBuildingMultiplier = populationGoldMultiplier * 0.1
//        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Gold Added: \(multipliedGold)")

        bankManager.AddGoldToBank(updatedGold: Int(multipliedGold))

        // Update necessary labels here
        GoldGridAmount.text = String(multipliedGold)
        StepsLabel.text = String(goldToAdd)
        CurrentMultiplier.text = String(1 + (populationGoldMultiplier))
        
        // Labels removed. This data should be re-displayed in an appropriate view
//        DialogBox.text = "Gold Walked: \(goldToAdd) | Gold Added: \(multipliedGold)"
//        PurchasesMadeText.text = "Buildings Owned: \(populationGoldMultiplier) | Next Building Cost: \(buildingCost)"
//        CurrentMultiplierText.text = "Current multiplier: \(1 + (populationGoldMultiplier * 0.1))"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.InitializeRealmData()
        
        GatherStepData()

        // This is terrible; use a callback instead
        sleep(1)
        
        // Somehow this dumps all realm data?
        //print(bankManager.date)
        
        AddQueriedGoldToBank(goldToAdd: queryGoldSum(previousDate: bankManager.GetLastLogin()))
        resourceManager.population = bankManager.GetNumberOfBuildings(buildingType: BUILDING.house) * 2

        GoldLabel.text = String(resourceManager.gold)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Removed alongside label removal
//        let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
//        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        
        UpdateResourceBar()
        // Labels removed. This data should be re-displayed in an appropriate view
//        PurchasesMadeText.text = "Buildings Owned: \(bankManager.GetBuildingValue()) | Next Building Cost: \(buildingCost)"
//        CurrentMultiplierText.text = "Current multiplier: \(1 + (bankManager.GetBuildingValue() * 0.1))"
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
    // Get number of gold since last time
    // multiply by the update factor
    func queryGoldSum(previousDate: Date) -> Int {
        print("Last queried date: \(previousDate)\nCurrent Date: \(Date())")
        var numberOfGold: Int = 0
        let sumOption = HKStatisticsOptions.cumulativeSum
        let predicate = HKQuery.predicateForSamples(withStart: previousDate, end: Date(), options: .strictStartDate)
        let statisticsSumQuery = HKStatisticsQuery(quantityType: healthKitManager.stepCount!, quantitySamplePredicate: predicate, options: sumOption) { [unowned self] (query, result, error) in
            if let newGoldQuantity = result?.sumQuantity() {
                numberOfGold = Int(newGoldQuantity.doubleValue(for: self.healthKitManager.goldUnit))
                print ("Query gold: \(numberOfGold)")
                //self.resourceManager.gold = numberOfGold
            }
        }

        healthKitManager.healthStore?.execute(statisticsSumQuery)
        self.GoldLabel.text = "0"
        return numberOfGold
    }

    func UpdateResourceBar()
    {
        // Resource bar
        GoldLabel.text = String(resourceManager.gold)
        PopulationLabel.text = String(resourceManager.population)
    }
    

}

