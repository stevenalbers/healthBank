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
    @objc dynamic var gold: Int = 0
    @objc dynamic var food: Int = 0
    @objc dynamic var wood: Int = 0
    @objc dynamic var stone: Int = 0
    
    @objc dynamic var lastLogin: Date = Date()
    
    override class func primaryKey() -> String?
    {
        return "id"
    }
}

enum RESOURCE : String {
    case gold = "gold"
    case food = "food"
    case wood = "wood"
    case stone = "stone"
    case population = "population"
}

// For now, because each building is worth the same amount it's easier to just take the sum of IDs logged in the database
class BuildingRealm: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var house: Int = 0
    @objc dynamic var farm: Int = 0
    @objc dynamic var sawmill: Int = 0
    @objc dynamic var quarry: Int = 0
    @objc dynamic var monument: Int = 0

    override class func primaryKey() -> String?
    {
        return "id"
    }

}

class WorkerRealm: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var farmer: Int = 0
    @objc dynamic var woodcutter: Int = 0
    @objc dynamic var stonemason: Int = 0
    
    override class func primaryKey() -> String?
    {
        return "id"
    }
}

class StepBankManager
{
    // TODO: Make try with do/catch handling
    let realm = try! Realm()
    
    let resourceManager = ResourceManager.sharedInstance
    
    // Building data goes here
    lazy var buildings: Results<BuildingRealm> = { self.realm.objects(BuildingRealm.self) }()
    
    func InitializeRealmData()
    {
        let bank = realm.objects(BankRealm.self)
        
        let buildings = realm.objects(BuildingRealm.self)
    
        let workers = realm.objects(WorkerRealm.self)
        
        if (bank.isEmpty == true) { // 1
            
            try! realm.write() { // 2
                
                let defaultGold = 30000
                let defaultFood = 500
                let defaultWood = 150

                let newBank = BankRealm()
                newBank.gold = defaultGold
                newBank.food = defaultFood
                newBank.wood = defaultWood
                
                resourceManager.gold = defaultGold
                resourceManager.food = defaultFood
                resourceManager.wood = defaultWood
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
    
        if(workers.isEmpty == true)
        {
            try! realm.write() { // 2
                
                let newWorkers = WorkerRealm()
                self.realm.add(newWorkers)
            }
        }
        
    }
    
    // Returns the amount currently stored in the bank
    func GetStepBankValue() -> Int
    {
        let bank = realm.objects(BankRealm.self)
        let thing = bank.sum(ofProperty: "gold") as Int
        print("GetStepBankValue: \(thing)")
        return bank.sum(ofProperty: "gold")
    }
    
    func UpdateResources()
    {
        let bank = realm.objects(BankRealm.self)

        // Gather sum of each resource here, populate resourceManager
        resourceManager.gold = bank.sum(ofProperty: "gold") as Int
        resourceManager.food = bank.sum(ofProperty: "food") as Int
        resourceManager.wood = bank.sum(ofProperty: "wood") as Int
        resourceManager.stone = bank.sum(ofProperty: "stone") as Int
        resourceManager.population = 4 + (buildings.sum(ofProperty: BUILDING.house.rawValue) * 2)
    }
    
    func GetLastLogin() -> Date
    {
        let bank = realm.objects(BankRealm.self)
        
        return (bank.last!.lastLogin)
        
    }
    
    func AddResourceToBank(resource: RESOURCE, toAdd: Int)
    {
        let bank = realm.objects(BankRealm.self)
        let newID = (bank.last?.id)! + 1
        
        try! realm.write()
        {
            let bankUpdate = BankRealm()
            
            // TODO: Convert this switch into a single use case. e.g. use the resource enum directly as the class variable
            switch(resource)
            {
            case RESOURCE.gold:
                bankUpdate.gold = toAdd
                bankUpdate.lastLogin = Date()
                bankUpdate.id = newID
                //self.realm.add(bankUpdate!, update: false)
                self.realm.create(BankRealm.self, value: bankUpdate, update: false)

                break
            case RESOURCE.food:
                bankUpdate.food = toAdd
                bankUpdate.lastLogin = Date()
                bankUpdate.id = newID
                //self.realm.add(bankUpdate!, update: false)
                self.realm.create(BankRealm.self, value: bankUpdate, update: false)

                break
            case RESOURCE.wood:
                bankUpdate.wood = toAdd
                bankUpdate.lastLogin = Date()
                bankUpdate.id = newID
                //self.realm.add(bankUpdate!, update: false)
                self.realm.create(BankRealm.self, value: bankUpdate, update: false)

                break
            case RESOURCE.stone:
                bankUpdate.stone = toAdd
                bankUpdate.lastLogin = Date()
                bankUpdate.id = newID
                //self.realm.add(bankUpdate!, update: false)
                self.realm.create(BankRealm.self, value: bankUpdate, update: false)

                break
            case RESOURCE.population:
                bankUpdate.gold = toAdd
                bankUpdate.lastLogin = Date()
                bankUpdate.id = newID
                //self.realm.add(bankUpdate!, update: false)
                self.realm.create(BankRealm.self, value: bankUpdate, update: false)

                break
            default:
                // Error
                print("Bad Resource.")
                break
            }
        }
        resourceManager.gold = GetStepBankValue()
        print("RM Gold: \(resourceManager.gold)")
    }
    
    func AddBuilding(buildingType : BUILDING)
    {
        let building = realm.objects(BuildingRealm.self)
        let newID = (building.last?.id)! + 1
        
        let currentBuilding: String = buildingType.rawValue
        
        try! realm.write()
        {
            let buildingUpdate = BuildingRealm()
            buildingUpdate.id = newID
            
            // Decide building type here
            // TODO: One-line this. Should be able to access the buildingUpdate value directly
            switch(currentBuilding)
            {
            case "house":
                buildingUpdate.house = 1
                break
            case "farm":
                buildingUpdate.farm = 1
                break
            case "sawmill":
                buildingUpdate.sawmill = 1
                break
            case "quarry":
                buildingUpdate.quarry = 1
                break
            case "monument":
                buildingUpdate.monument = 1
                break

            default:
                print("Error: Incorrect building")
            }
            
            //self.realm.add(bankUpdate!, update: false)
            self.realm.create(BuildingRealm.self, value: buildingUpdate, update: false)
        }
    }
    
    func UpdateWorkers(workerType: WORKER, workersAdded: Int)
    {
        let worker = realm.objects(WorkerRealm.self)
        let newID = (worker.last?.id)! + 1
        
        let currentWorker: String = workerType.rawValue

        try! realm.write()
        {
            let workerUpdate = WorkerRealm()
            workerUpdate.id = newID
            
            // Decide building type here
            // TODO: One-line this. Should be able to access the buildingUpdate value directly
            switch(currentWorker)
            {
            case "farmer":
                workerUpdate.farmer = workersAdded
                break
            case "woodcutter":
                workerUpdate.woodcutter = workersAdded
                break
            case "stonemason":
                workerUpdate.stonemason = workersAdded
                break
                
            default:
                print("Error: Invalid worker")
            }
            
            //self.realm.add(bankUpdate!, update: false)
            self.realm.create(WorkerRealm.self, value: workerUpdate, update: false)
        }
    }
    
    func GetNumberOfBuildings(buildingType : BUILDING) -> Int
    {
        let building = realm.objects(BuildingRealm.self)
        return building.sum(ofProperty: buildingType.rawValue)
    }
    
    func GetNumberOfWorkers(workerType : WORKER) -> Int
    {
        let worker = realm.objects(WorkerRealm.self)
        return worker.sum(ofProperty: workerType.rawValue)
    }
}
