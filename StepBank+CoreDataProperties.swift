//
//  Bank+CoreDataProperties.swift
//  HealthBank
//
//  Created by Steven Albers on 1/10/17.
//  Copyright © 2017 Tropopause, LLC. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension StepBank {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bank> {
        return NSFetchRequest<Bank>(entityName: "Bank");
    }

    @NSManaged public var stepBank: Int32

}
