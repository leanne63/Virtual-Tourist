//
//  MapModel.swift
//  Virtual Tourist
//
//  Created by leanne on 7/23/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

struct MapModel {
	
	// MARK: - Constants
	
	static let mapCenterLatitudeKey = "mapCenterLatitudeKey"
	static let mapCenterLongitudeKey = "mapCenterLongitudeKey"
	
	/*
	From:
	https://developer.apple.com/library/ios/documentation/MapKit/Reference/MapKitFunctionsReference/#//apple_ref/c/func/MKCoordinateSpanMake
	
	latitudeDelta:
	The amount of north-to-south distance (measured in degrees) to use for the span.
	Unlike longitudinal distances, which vary based on the latitude, one degree of latitude is
	approximately 111 kilometers (69 miles) at all times.
	
	longitudeDelta:
	The amount of east-to-west distance (measured in degrees) to use for the span.
	The number of kilometers spanned by a longitude range varies based on the current latitude.
	For example, one degree of longitude spans a distance of approximately 111 kilometers (69 miles)
	at the equator but shrinks to 0 kilometers at the poles.
	*/
	static let mapSpanLatitudeDeltaKey = "mapSpanLatitudeDelta"
	static let mapSpanLongitudeDeltaKey = "mapSpanLongitudeDelta"
}