//
//  Extension_Pin.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit


/// Overrides += to assign CLLocationCoordinate2D values to a Pin
func +=(inout lhs: Pin, rhs: CLLocationCoordinate2D) {
	
	lhs.latitude = rhs.latitude
	lhs.longitude = rhs.longitude
}

