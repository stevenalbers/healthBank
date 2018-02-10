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

class WorkerViewController: UIViewController {
    
    // Resource bar
    @IBOutlet weak var GoldLabel: UILabel!
    @IBOutlet weak var FoodLabel: UILabel!
    @IBOutlet weak var WoodLabel: UILabel!
    @IBOutlet weak var StoneLabel: UILabel!
    @IBOutlet weak var PopulationLabel: UILabel!
    
    @IBOutlet weak var FarmerProductivityLabel: UILabel!
   
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
    
    
    func UpdateAllLabels()
    {
        UpdateResourceBar()
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
