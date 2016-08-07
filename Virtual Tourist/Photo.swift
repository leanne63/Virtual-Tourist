//
//  Photo.swift
//  Virtual Tourist
//
//  Created by leanne on 8/6/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

	convenience init(photo: NSData,  pin: Pin, context : NSManagedObjectContext){
		
		if let entity = NSEntityDescription.entityForName("Photo",
		                                                  inManagedObjectContext: context){
			self.init(entity: entity, insertIntoManagedObjectContext: context)
			self.photo = photo
			self.pin = pin
			
		}
		else {
			fatalError("Unable to find Entity name!")
		}
		
	}

}
