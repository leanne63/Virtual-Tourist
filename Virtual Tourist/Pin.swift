//
//  Pin.swift
//  Virtual Tourist
//
//  Created by leanne on 8/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

	convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext){
		
		if let entity = NSEntityDescription.entityForName("Pin",
		                                                  inManagedObjectContext: context){
			self.init(entity: entity, insertIntoManagedObjectContext: context)
			self.latitude = latitude;
			self.longitude = longitude
			
		}
		else {
			fatalError("Unable to find Entity name!")
		}
	}

}
