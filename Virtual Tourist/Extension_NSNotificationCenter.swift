//
//  Extension_NSNotificationCenter.swift
//  Virtual Tourist
//
//  Created by leanne on 8/13/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

extension NSNotificationCenter {
	
	/**
	
	Creates and posts a notification to the main thread.
	
	- parameters:
		- notificationName: Notification name to be provided to observers.
		- userInfo: Dictionary of custom information to be provided to observers, or nil if none needed.
	
	*/
	class func postNotificationOnMain(notificationName: String, object: AnyObject?, userInfo: [String: AnyObject]?) {
		
		let notification = NSNotification(name: notificationName, object: nil, userInfo: userInfo)
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			NSNotificationCenter.defaultCenter().postNotification(notification)
		}
	}
	
	
	/**
	
	Post notification containing a failure message.
	
	- parameter failureMessage: Failure information to be provided to observers.
	
	*/
	class func postFailureNotification(notificationName: String, object: AnyObject?, failureMessage: String) {
		
		let userInfo = ["failureMessage": failureMessage]
		
		NSNotificationCenter.postNotificationOnMain(notificationName, object: object, userInfo: userInfo)
	}
	
	
}