//
//  Extension_SCNetworkReachability.swift
//  Virtual_Tourist
//
//  Created by leanne on 8/18/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import SystemConfiguration

extension SCNetworkReachability {
	
	/**
	
	Verify network connection is available.
	
	- parameter urlToReach: URL to be accessed.
	
	- returns: true if network available, false otherwise.
	
	*/
	class func checkIfNetworkAvailable(urlToReach: NSURL) -> Bool {
		
		let host = (urlToReach.absoluteString as NSString).UTF8String
		guard let ref = SCNetworkReachabilityCreateWithName(nil, host) else {
			//Unable to create SCNetworkReachability reference.
			return false
		}
		
		var flags: SCNetworkReachabilityFlags = []
		guard SCNetworkReachabilityGetFlags(ref, &flags) == true && flags.contains(.Reachable) else {
			//Unable to access network."
			return false
		}
		
		// if we're here, this device is connected
		return true
	}
	
}