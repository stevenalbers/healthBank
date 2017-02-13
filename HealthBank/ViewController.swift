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

class BankRealm: Object
{
    dynamic var steps = 0
}

class StepBankManager
{
    // TODO: Make try with do/catch handling
    let realm = try! Realm()
    lazy var steps: Results<BankRealm> = { self.realm.objects(BankRealm.self) }()
    /*var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }*/
    
    
    func CreateStepBank()
    {
        if steps.count == 0 { // 1
            
            try! realm.write() { // 2
                
                let defaultSteps = 5
                let newBank = BankRealm()
                newBank.steps = defaultSteps
                self.realm.add(newBank)
            }
        }

    }
    // Returns the amount currently stored in the bank
    func GetStepBankValue() -> Int
    {
        let bank = try! realm.objects(BankRealm.self)

        return bank.sum(ofProperty: "steps")
        
    }
    
    
    func SetStepBankValue(updatedSteps: Int)
    {
        try! realm.write()
        {
            let bankUpdate = BankRealm()
            bankUpdate.steps = updatedSteps
            self.realm.add(bankUpdate, update: true)
        }
    }
}

class ViewController: UIViewController {
    
    //let healthStore = HKHealthStore()
    let healthKitManager = HealthKitManager.sharedInstance
    let bankManager = StepBankManager()
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
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.CreateStepBank()
        
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

