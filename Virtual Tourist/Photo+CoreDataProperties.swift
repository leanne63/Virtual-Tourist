//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var photo: NSData?
    @NSManaged var pin: Pin?

}
