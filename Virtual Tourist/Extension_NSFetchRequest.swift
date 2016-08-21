//
//  Extension_NSFetchRequest.swift
//  Virtual Tourist
//
//  Created by leanne on 8/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit
import CoreData

extension NSFetchRequest {
	
	/// Requests all Pin objects
	class func allPins() -> NSFetchRequest {
		let request = NSFetchRequest(entityName: "Pin")
		
		return request
	}
	
	
	/**
	Requests all pins for a specific location.
	
	- parameter location: Coordinate containing latitude and longitude values for desired Pin.
	*/
	class func allPinsForLocation(location: CLLocationCoordinate2D) -> NSFetchRequest {
		let request = NSFetchRequest(entityName:"Pin")
		
		let pinLat = location.latitude
		let pinLon = location.longitude
		
		let predicate = NSPredicate(format: "latitude == %lf && longitude == %lf", pinLat, pinLon)
		request.predicate = predicate
		
		return request
	}
	
	
	/**
	Requests all photos for a specific Pin.
	
	- parameter pin: Pin object for which photos should be retrieved.
	*/
	class func allPhotosForPin(pin: Pin) -> NSFetchRequest {
		let request = NSFetchRequest(entityName: "Photo")
		let predicate = NSPredicate(format: "pin == %@", pin)
		request.predicate = predicate
		
		return request
	}
	
}