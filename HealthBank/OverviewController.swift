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
    var localGoldCount: Int = 0

    var goldMultiplier: Double = 1.0

    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var DialogBox: UILabel!
    @IBOutlet weak var PurchasesMadeText: UILabel!
    @IBOutlet weak var CurrentMultiplierText: UILabel!

    @IBAction func UpdateGold(_ sender: Any) {
        
        resourceManager.gold = queryGoldSum(previousDate: bankManager.GetLastLogin())
        
        // This is terrible; use a callback instead
        sleep(1)
        
        print("Gold: \(resourceManager.gold)")
        print(bankManager.date)
        
        AddQueriedGoldToBank(goldToAdd: resourceManager.gold)
        GoldLabel.text = String(bankManager.GetStepBankValue())

    }


    /*@IBAction func PurchaseBuilding(_ sender: Any) {
        let multipliedGold = 50.0 * goldMultiplier

        stepCount = stepCount + Int(multipliedGold)

        bankManager.AddGoldToBank(updatedGold: Int(multipliedGold))
    }*/
    
    func AddQueriedGoldToBank(goldToAdd: Int)
    {
        // TODO: Unify these variables so they're only computed once
        let buildingValue = bankManager.GetBuildingValue()
        let multipliedGold = Double(goldToAdd) * (1 + (buildingValue * 0.1))
        let currentBuildingMultiplier = buildingValue * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Gold Added: \(multipliedGold)")

        bankManager.AddGoldToBank(updatedGold: Int(multipliedGold))
        GoldLabel.text = String(resourceManager.gold)
        DialogBox.text = "Gold Walked: \(goldToAdd) | Gold Added: \(multipliedGold)"
        PurchasesMadeText.text = "Buildings Owned: \(buildingValue) | Next Building Cost: \(buildingCost)"
        CurrentMultiplierText.text = "Current multiplier: \(1 + (buildingValue * 0.1))"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.InitializeRealmData()
        
        check()
        resourceManager.gold = queryGoldSum(previousDate: bankManager.GetLastLogin())
        
        // This is terrible; use a callback instead
        sleep(1)
        
        print("Gold: \(resourceManager.gold)")
        print(bankManager.date)
        
        AddQueriedGoldToBank(goldToAdd: resourceManager.gold)
        GoldLabel.text = String(bankManager.GetStepBankValue())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentBuildingMultiplier = bankManager.GetBuildingValue() * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        
        GoldLabel.text = String(bankManager.GetStepBankValue())
        PurchasesMadeText.text = "Buildings Owned: \(bankManager.GetBuildingValue()) | Next Building Cost: \(buildingCost)"
        CurrentMultiplierText.text = "Current multiplier: \(1 + (bankManager.GetBuildingValue() * 0.1))"
    }
    
    // TODO: Move/rename this
    func check()
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
                self.resourceManager.gold = numberOfGold
            }
        }

        healthKitManager.healthStore?.execute(statisticsSumQuery)
        self.GoldLabel.text = "0"
        return numberOfGold
    }

    
    

}

