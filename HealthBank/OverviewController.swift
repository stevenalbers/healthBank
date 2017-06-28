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
    let bankManager = StepBankManager.sharedInstance
    var stepsCount: Int = 0  // TODO: Remove this if copying from healthkit is bad
    var localStepsCount: Int = 0

    var stepMultiplier: Double = 1.0

    @IBOutlet weak var StepLabel: UILabel!
    @IBOutlet weak var DialogBox: UILabel!
    @IBOutlet weak var PurchasesMadeText: UILabel!
    @IBOutlet weak var CurrentMultiplierText: UILabel!

    @IBAction func UpdateSteps(_ sender: Any) {
        
        resourceManager.steps = queryStepsSum(previousDate: bankManager.GetLastLogin())
        
        // This is terrible; use a callback instead
        sleep(1)
        
        print("Steps: \(resourceManager.steps)")
        print(bankManager.date)
        
        AddQueriedStepsToBank(stepsToAdd: resourceManager.steps)
        StepLabel.text = String(bankManager.GetStepBankValue())

    }


    /*@IBAction func PurchaseBuilding(_ sender: Any) {
        let multipliedSteps = 50.0 * stepMultiplier

        stepsCount = stepsCount + Int(multipliedSteps)

        bankManager.AddStepsToBank(updatedSteps: Int(multipliedSteps))
    }*/
    
    func AddQueriedStepsToBank(stepsToAdd: Int)
    {
        // TODO: Unify these variables so they're only computed once
        let buildingValue = bankManager.GetBuildingValue()
        let multipliedSteps = Double(stepsToAdd) * (1 + (buildingValue * 0.1))
        let currentBuildingMultiplier = buildingValue * 0.1
        let buildingCost = 1000 * pow(2.0, currentBuildingMultiplier)
        print("Steps Added: \(multipliedSteps)")

        bankManager.AddStepsToBank(updatedSteps: Int(multipliedSteps))
        StepLabel.text = String(resourceManager.steps)
        DialogBox.text = "Steps Walked: \(stepsToAdd) | Steps Added: \(multipliedSteps)"
        PurchasesMadeText.text = "Buildings Owned: \(buildingValue) | Next Building Cost: \(buildingCost)"
        CurrentMultiplierText.text = "Current multiplier: \(1 + (buildingValue * 0.1))"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.InitializeRealmData()
        
        check()
        resourceManager.steps = queryStepsSum(previousDate: bankManager.GetLastLogin())
        
        // This is terrible; use a callback instead
        sleep(1)
        
        print("Steps: \(resourceManager.steps)")
        print(bankManager.date)
        
        AddQueriedStepsToBank(stepsToAdd: resourceManager.steps)
        StepLabel.text = String(bankManager.GetStepBankValue())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
    // Get number of steps since last time
    // multiply by the update factor
    func queryStepsSum(previousDate: Date) -> Int {
        print("Last queried date: \(previousDate)\nCurrent Date: \(Date())")
        var numberOfSteps: Int = 0
        let sumOption = HKStatisticsOptions.cumulativeSum
        let predicate = HKQuery.predicateForSamples(withStart: previousDate, end: Date(), options: .strictStartDate)
        let statisticsSumQuery = HKStatisticsQuery(quantityType: healthKitManager.stepsCount!, quantitySamplePredicate: predicate, options: sumOption) { [unowned self] (query, result, error) in
            if let newStepQuantity = result?.sumQuantity() {
                numberOfSteps = Int(newStepQuantity.doubleValue(for: self.healthKitManager.stepsUnit))
                print ("Query steps: \(numberOfSteps)")
                self.resourceManager.steps = numberOfSteps
            }
        }

        healthKitManager.healthStore?.execute(statisticsSumQuery)
        self.StepLabel.text = "0"
        return numberOfSteps
    }

    
    

}

