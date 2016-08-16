//
//  OperatorOverloads.swift
//  Virtual Tourist
//
//  Created by leanne on 8/15/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit

// MARK: - CLLocationCoordinate2D Comparison Operator (==)

/*
From:
http://gis.stackexchange.com/a/8674/35406

"Accordingly, if your accuracy needs are, say, give or take 10 meters, than 1/9 meter is nothing:
you lose essentially no accuracy by using six decimal places. If your accuracy need is sub-centimeter,
then you need at least seven and probably eight decimal places, but more will do you little good."
*/
// note: see equatable declaration in Extension_CLLocationCoordinate2D.swift
// note: function must be declared public because equatable protocol is public

/// Returns true if the two coordinates match with a precision of 6 decimal places; false if not
public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	
	let sixPlaces = 1000000.0
	
	let lhsLat = Int64(round(lhs.latitude * sixPlaces))
	let rhsLat = Int64(round(rhs.latitude * sixPlaces))
	
	guard lhsLat == rhsLat else { return false }
	
	// if we're here, the first comparison matched
	let lhsLon = Int64(round(lhs.longitude * sixPlaces))
	let rhsLon = Int64(round(rhs.longitude * sixPlaces))
	
	return lhsLon == rhsLon
}

/// Returns true if the two coordinates match with a precision of 6 decimal places; false if not
func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	
	return !(lhs == rhs)
}


// MARK: - Pin Compound Addition Operator (+=)s

/// Overrides += to assign CLLocationCoordinate2D values to a Pin
func +=(inout lhs: Pin, rhs: CLLocationCoordinate2D) {
	
	lhs.latitude = rhs.latitude
	lhs.longitude = rhs.longitude
}

