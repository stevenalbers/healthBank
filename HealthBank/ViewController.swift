//
//  ViewController.swift
//  HealthBank
//
//  Created by Steven Albers on 1/3/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    //let healthStore = HKHealthStore()
    let healthKitManager = HealthKitManager.sharedInstance
    var stepsCount: Int = 0

    @IBOutlet weak var StepLabel: UILabel!

    @IBAction func UpdateSteps(_ sender: Any) {
        StepLabel.text = String(stepsCount)

    }
    @IBAction func UseSteps(_ sender: Any) {
        if(stepsCount - 50 >= 0)
        {
            stepsCount = stepsCount - 50
            StepLabel.text = String(stepsCount)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        check()
        
        print("Steps: \(stepsCount)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func check()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            print("hello")
            // State the health data type(s) we want to read from HealthKit.
            let healthDataToRead = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            
            // State the health data type(s) we want to write from HealthKit.
            let healthDataToWrite = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
            
            // Request authorization to read and/or write the specific data.
            healthKitManager.healthStore?.requestAuthorization(toShare: healthDataToWrite, read: healthDataToRead) { (success, error) in
                if success {
                    self.queryStepsSum()
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
    
    func queryStepsSum() {
        let sumOption = HKStatisticsOptions.cumulativeSum
        let statisticsSumQuery = HKStatisticsQuery(quantityType: healthKitManager.stepsCount!, quantitySamplePredicate: nil, options: sumOption) { [unowned self] (query, result, error) in
            if let sumQuantity = result?.sumQuantity() {
                
                let numberOfSteps = Int(sumQuantity.doubleValue(for: self.healthKitManager.stepsUnit))
                self.stepsCount = numberOfSteps
                
            }
            
        }
        healthKitManager.healthStore?.execute(statisticsSumQuery)
        self.StepLabel.text = String(self.stepsCount)
    }

}

