//
//  WorkerViewController.swift
//  HealthBank
//
//  Created by Steven Albers on 2/10/18.
//  Copyright © 2018 Tropopause, LLC. All rights reserved.
//

import UIKit
import HealthKit
import RealmSwift

enum WORKER : String {
    case farmer = "farmer"
    case woodcutter = "woodcutter"
    case stonemason = "stonemason"
    
    static let allWorkers = [farmer, woodcutter, stonemason]
}

class WorkerViewController: UIViewController {
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var FoodLabel: UILabel!
    @IBOutlet weak var WoodLabel: UILabel!
    @IBOutlet weak var StoneLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    @IBOutlet weak var FarmerStaffLabel: UILabel!
    @IBOutlet weak var FarmerProductivityLabel: UILabel!
    
    @IBOutlet weak var WoodcutterStaffLabel: UILabel!
    @IBOutlet weak var WoodcutterProductivityLabel: UILabel!
    
    @IBOutlet weak var StonemasonStaffLabel: UILabel!
    @IBOutlet weak var StonemasonProductivityLabel: UILabel!
    
    let resourceManager = ResourceManager.sharedInstance
    let bankManager = StepBankManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bankManager.UpdateResources()
        UpdateAllLabels()
    }
    
    @IBAction func AddWorker(_ sender: Any)
    {
        guard let button = sender as? UIButton else {
            return
        }
        
        if bankManager.GetAllWorkers() >= resourceManager.population
        {
            return
        }

        
        // Refer to which building was purchased here
        // TODO: Consider finding a way to make this more succinct.
        print(button.tag)
        switch button.tag {
        case 1: // Farmer
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.farmer) < bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 5 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.farmer, workersAdded: 1)
                
                UpdateAllLabels()
            }
            break
        case 2: // Woodcutter
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.woodcutter) < bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill) * 5 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.woodcutter, workersAdded: 1)
                
                UpdateAllLabels()
            }
            break
        case 3: // Stonemason
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.stonemason) < bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 5 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.stonemason, workersAdded: 1)
                
                UpdateAllLabels()
            }
            break

        default:
            // Invalid
            break
        }
    }
    
    @IBAction func RemoveWorker(_ sender: Any)
    {
        guard let button = sender as? UIButton else {
            return
        }
        
        // Refer to which building was purchased here
        // TODO: Consider finding a way to make this more succinct.
        print(button.tag)
        switch button.tag {
        case 1: // Farmer
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.farmer) > 0 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.farmer, workersAdded: -1)
                
                UpdateAllLabels()
            }
            break
        case 2: // Woodcutter
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.woodcutter) > 0 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.woodcutter, workersAdded: -1)
                
                UpdateAllLabels()
            }
            break
        case 3: // Stonemason
            if( bankManager.GetNumberOfWorkers(workerType: WORKER.stonemason) > 0 )
            {
                bankManager.UpdateWorkers(workerType: WORKER.stonemason, workersAdded: -1)
                
                UpdateAllLabels()
            }
            break
            
        default:
            // Invalid
            break
        }
    }
    
    
    func UpdateAllLabels()
    {
        UpdateResourceBar()
        UpdateWorkerView()
    }
    
    func UpdateResourceBar()
    {
        bankManager.UpdateResources()
        
        // Resource bar
        GoldLabel.text = String(resourceManager.gold)
        FoodLabel.text = String(resourceManager.food)
        WoodLabel.text = String(resourceManager.wood)
        StoneLabel.text = String(resourceManager.stone)
        PopulationLabel.text = "\(bankManager.GetAllWorkers())/\(resourceManager.population)"
        }
    
    func UpdateWorkerView()
    {
        let foodGainFactor = 1 + (Double(bankManager.GetNumberOfWorkers(workerType: WORKER.farmer)) * 0.1)
        let woodGainFactor = 1 + (Double(bankManager.GetNumberOfWorkers(workerType: WORKER.woodcutter)) * 0.1)
        let stoneGainFactor = 1 + (Double(bankManager.GetNumberOfWorkers(workerType: WORKER.stonemason)) * 0.1)

        FarmerStaffLabel.text = "\(bankManager.GetNumberOfWorkers(workerType: WORKER.farmer))/\(bankManager.GetNumberOfBuildings(buildingType: BUILDING.farm) * 5)"
        FarmerProductivityLabel.text = "Gain \(foodGainFactor) food per 50 steps"
        
        WoodcutterStaffLabel.text = "\(bankManager.GetNumberOfWorkers(workerType: WORKER.woodcutter))/\(bankManager.GetNumberOfBuildings(buildingType: BUILDING.sawmill) * 5)"
        WoodcutterProductivityLabel.text = "Gain \(woodGainFactor) food per 100 steps"
        
        StonemasonStaffLabel.text = "\(bankManager.GetNumberOfWorkers(workerType: WORKER.stonemason))/\(bankManager.GetNumberOfBuildings(buildingType: BUILDING.quarry) * 5)"
        StonemasonProductivityLabel.text = "Gain \(stoneGainFactor) food per 250 steps"

    }
}
