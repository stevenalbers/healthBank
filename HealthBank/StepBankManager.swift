//
//  StepBankManager.swift
//  HealthBank
//
//  Created by Steven Albers on 5/28/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//

import Foundation
import HealthKit
import RealmSwift

class BankRealm: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var steps: Int = 0
    @objc dynamic var lastLogin: Date = Date()
    
    override class func primaryKey() -> String?
    {
        return "id"
    }
}

// For now, because each building is worth the same amount it's easier to just take the sum of IDs logged in the database
class BuildingRealm: Object
{
    @objc dynamic var id: Int = 0
    
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
    
    // Building data goes here
    lazy var buildings: Results<BuildingRealm> = { self.realm.objects(BuildingRealm.self) }()
    
    func InitializeRealmData()
    {
        let bank = realm.objects(BankRealm.self)
        
        let buildings = realm.objects(BuildingRealm.self)
        
        if (bank.isEmpty == true) { // 1
            
            try! realm.write() { // 2
                
                let defaultSteps = 0
                let newBank = BankRealm()
                newBank.steps = defaultSteps
                self.realm.add(newBank)
            }
        }
        
        if(buildings.isEmpty == true)
        {
            try! realm.write() { // 2
                
                let newBuildings = BuildingRealm()
                self.realm.add(newBuildings)
            }
        }
        
        
    }
    
    // Returns the amount currently stored in the bank
    func GetStepBankValue() -> Int
    {
        let bank = realm.objects(BankRealm.self)
        let thing = bank.sum(ofProperty: "steps") as Int
        print("GetStepBankValue: \(thing)")
        return bank.sum(ofProperty: "steps")
        
    }
    
    func GetLastLogin() -> Date
    {
        let bank = realm.objects(BankRealm.self)
        
        return (bank.last!.lastLogin)
        
    }
    
    func AddStepsToBank(updatedSteps: Int)
    {
        let bank = realm.objects(BankRealm.self)
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
    
    func AddBuilding()
    {
        let building = realm.objects(BuildingRealm.self)
        let newID = (building.last?.id)! + 1
        try! realm.write()
        {
            let buildingUpdate = BuildingRealm()
            buildingUpdate.id = newID
            //self.realm.add(bankUpdate!, update: false)
            self.realm.create(BuildingRealm.self, value: buildingUpdate, update: false)
            
        }
    }
    
    func GetBuildingValue() -> Double
    {
        let building = realm.objects(BuildingRealm.self)
        let buildingTotal = building.count
        
        return Double(buildingTotal)
    }
}
