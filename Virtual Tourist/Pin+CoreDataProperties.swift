//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by leanne on 8/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: NSSet?

}
