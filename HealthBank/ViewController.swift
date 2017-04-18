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
    dynamic var id: Int = 0
    dynamic var steps: Int = 0
    dynamic var lastLogin: Date = Date()
    
    override class func primaryKey() -> String?
    {
        return "id"
    }
}

class StepBankManager
{
    // TODO: Make try with do/catch handling
    let realm = try! Realm()
    lazy var steps: Results<BankRealm> = { self.realm.objects(BankRealm.self) }()
    lazy var date: Results<BankRealm> = { self.realm.objects(BankRealm.self) }()
    /*var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }*/
    
    
    func CreateStepBank()
    {
        let bank = try! realm.objects(BankRealm.self)

        if (bank.isEmpty == true) { // 1
            
            try! realm.write() { // 2
                
                let defaultSteps = 0
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
        let thing = bank.sum(ofProperty: "steps") as Int
        print("GetStepBankValue: \(thing)")
        return bank.sum(ofProperty: "steps")
        
    }
    
    func GetLastLogin() -> Date
    {
        let bank = try! realm.objects(BankRealm.self)
        
        return (bank.last!.lastLogin)

    }
    
    func AddStepsToBank(updatedSteps: Int)
    {
        
        //save it to realm
        //realm.create(Dog, value: dog, update: true)
        //get the dog reference from the database
        //let realmDog = realm.object(ofType: Dog.self, forPrimaryKey: "id")
        //append dog to person
        //person.dogs.append(realmDog)
        let bank = try! realm.objects(BankRealm.self)
        let newID = (bank.last?.id)! + 1
        
        try! realm.write()
        {
            let bankUpdate = BankRealm()
            bankUpdate.steps = updatedSteps
            bankUpdate.lastLogin = Date()
            bankUpdate.id = newID
            //self.realm.add(bankUpdate!, update: false)
            self.realm.create(BankRealm.self, value: bankUpdate, update: false)

        }
    }
}

class ViewController: UIViewController {
    
    //let healthStore = HKHealthStore()
    let healthKitManager = HealthKitManager.sharedInstance
    let bankManager = StepBankManager()
    var stepsCount: Int = 0  // TODO: Remove this if copying from healthkit is bad
    var localStepsCount: Int = 0

    var stepMultiplier: Double = 1.0

    @IBOutlet weak var StepLabel: UILabel!
    @IBOutlet weak var DialogBox: UILabel!
    @IBOutlet weak var PurchasesMadeText: UILabel!
    @IBOutlet weak var CurrentMultiplierText: UILabel!

    @IBAction func UpdateSteps(_ sender: Any) {
        
        //AddQueriedStepsToBank(stepsToAdd: localStepsCount)
        StepLabel.text = String(bankManager.GetStepBankValue())

        // Old functionality
        /*
        stepsCount = bankManager.GetStepBankValue()
        print("Update Steps: \(stepsCount)")
        StepLabel.text = String(bankManager.GetStepBankValue())
        print("Last date: \(bankManager.GetLastLogin())")
 */
    }
    @IBAction func UseSteps(_ sender: Any) {
        if(stepsCount - 50 >= 0)
        {
            stepsCount = stepsCount - 50
            print("Use Steps: \(stepsCount)")

            stepMultiplier = stepMultiplier + 0.1
            print("Multiplier is now: \(stepMultiplier)")

            bankManager.AddStepsToBank(updatedSteps: -50)
            StepLabel.text = String(stepsCount)
        }
    }

    @IBAction func AddSteps(_ sender: Any) {
        let multipliedSteps = 50.0 * stepMultiplier

        stepsCount = stepsCount + Int(multipliedSteps)

        bankManager.AddStepsToBank(updatedSteps: Int(multipliedSteps))
        StepLabel.text = String(stepsCount)
    }
    
    func AddQueriedStepsToBank(stepsToAdd: Int)
    {
        let multipliedSteps = stepsToAdd * Int(arc4random_uniform(2) + 1)
        print("Steps Added: \(multipliedSteps)")

        bankManager.AddStepsToBank(updatedSteps: Int(multipliedSteps))
        StepLabel.text = String(localStepsCount)
        DialogBox.text = "Steps Added: \(multipliedSteps)"

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.description)
        // Do any additional setup after loading the view, typically from a nib.
        bankManager.CreateStepBank()
        
        check()
        localStepsCount = queryStepsSum(previousDate: bankManager.GetLastLogin())
        
        
        // This is terrible; use a callback instead
        sleep(1)
        
        print("Steps: \(localStepsCount)")
        print(bankManager.date)
        
        AddQueriedStepsToBank(stepsToAdd: localStepsCount)
        StepLabel.text = String(bankManager.GetStepBankValue())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.stepsCount = numberOfSteps
                self.localStepsCount = numberOfSteps
                //self.bankManager.AddStepsToBank(updatedSteps: numberOfSteps)
                
            }
        }
        healthKitManager.healthStore?.execute(statisticsSumQuery)
        self.StepLabel.text = "0"
        return numberOfSteps
    }

    
    

}

