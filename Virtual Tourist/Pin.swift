//
//  Pin.swift
//  Virtual Tourist
//
//  Created by leanne on 8/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit
import CoreData


class Pin: NSManagedObject {

	convenience init(context: NSManagedObjectContext){
		
		if let entity = NSEntityDescription.entityForName("Pin",
		                                                  inManagedObjectContext: context){
			self.init(entity: entity, insertIntoManagedObjectContext: context)
			
			// properties must be set after initialization!
		}
		else {
			fatalError("Unable to find Entity name!")
		}
	}

}
