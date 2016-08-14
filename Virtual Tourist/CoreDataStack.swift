//
//  CoreDataStack.swift
//  Virtual Tourist
//
//	Provided by Apple,
//  Modified by leanne on 7/26/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	
	// let's use a singleton (shared instance)
	static let shared = CoreDataStack()
	
	lazy var applicationDocumentsDirectory: NSURL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory
		//	named "com.leanne63.Virtual_Tourist" in the application's documents Application Support directory.
		let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
		print("*****\nSQLite DB PATH:\n\(urls[urls.count-1])\n*****")	// TODO: FOR TESTING
		return urls[urls.count-1]
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = NSBundle.mainBundle().URLForResource("Virtual_Tourist", withExtension: "momd")!
		return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Virtual_Tourist.sqlite")
		var failureReason = "There was an error creating or loading the application's saved data."
		do {
			try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
		} catch {
			// Report any error we got.
			var dict = [String: AnyObject]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
			dict[NSUnderlyingErrorKey] = error as NSError
			let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
			// Replace this with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
			abort()
		}
		
		return coordinator
	}()
	
	/*
	   Resource for usual stack setup explanations and performance tests:
		https://developmentnow.com/2015/04/28/experimenting-with-the-parent-child-concurrency-pattern-to-optimize-coredata-apps/

	   Experimenting here: instead of "writer" MOC setup, creating a "reverse" "double MOC" setup:
		non-temporary private-queue MOC as parent/root, and main MOC as child...
	*/
	lazy var privateManagedObjectContext: NSManagedObjectContext = {
		// Returns the (PrivateQueueConcurrencyType) managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		let coordinator = self.persistentStoreCoordinator
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
		// Connecting to the store coordinator makes this the "root" parent context
		managedObjectContext.persistentStoreCoordinator = coordinator
		return managedObjectContext
	}()
	
	lazy var mainManagedObjectContext: NSManagedObjectContext = {
		// Returns the (MainQueueConcurrencyType) managed object context for the application (which is already bound to the private MOC for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
		// For experiment, this is the child, so set its parent to the private context
		managedObjectContext.parentContext = self.privateManagedObjectContext
		return managedObjectContext
	}()
	
	// private initializer to prevent instantiation of this class
	private init() { }
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		if mainManagedObjectContext.hasChanges {
			do {
				print("***** SAVING MAIN CONTEXT *****")
				try mainManagedObjectContext.save()
			} catch {
				print("***** FAILED TO SAVE MAIN CONTEXT *****")
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
			
		}
		
		if privateManagedObjectContext.hasChanges {
			do {
				print("***** SAVING PRIVATE CONTEXT *****")
				try privateManagedObjectContext.save()
			} catch {
				print("***** FAILED TO SAVE PRIVATE CONTEXT *****")
				// Replace this implementation with code to handle the error appropriately.
				// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
				abort()
			}
		}
	}

	
}