//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	// MARK: - Constants
	
	private let reuseIdentifier = "reusableCell"
	
	
	// MARK: - Properties
	
	var pin: Pin!
	var photos: [Photo]!
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("\n\nmain context:\n\(CoreDataStack.shared.mainManagedObjectContext)")
		print("\nprivate context:\n\(CoreDataStack.shared.privateManagedObjectContext)")
		print("\nphotos:\n\(photos)\n\n")
		
		print("***** IN \(#function)")
		
		collectionView!.delegate = self
		
		subscribeToNotifications()
		
		// note: to test zero photos, simply delete photos for this pin from the database
		let numPhotosToDisplay = photos.count
		
		if numPhotosToDisplay == 0 {
			newCollectionButton.enabled = false
			
			// get new photos in the background...
			retrieveNewPhotos()
		}
		else {
			collectionView.reloadData()
		}
    }
	
	deinit {
		// unsubscribe us from all notifications we're observing!
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


    // MARK: - UICollectionViewDataSource

	// using default number of sections (1), so no override for numberOfSections
	
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		print("***** IN \(#function)")
		
		let numItems = photos.count
		
		return numItems
    }

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
		print("***** IN \(#function)")
		print("\nphotos:\n\(photos)\n\n")
		
		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.hidesWhenStopped = true
		
		var imageData = NSData()
		
		if photos.count > 0 {
			imageData = photos[indexPath.row].photo!
		}
		
		cellImageView.image = UIImage(data: imageData)
		
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		print("***** IN \(#function)")
		
        return true
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("***** IN \(#function)")
		
		let row = indexPath.row
		deletePhotoAtRow(row)
	}

	
	// MARK: - Observer-Related Methods
	
	private func subscribeToNotifications() {
		
		print("***** IN \(#function)")
		
		/* Managed Object Context notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(managedObjectContextDidSave(_:)),
		                                                 name: NSManagedObjectContextDidSaveNotification,
		                                                 object: nil)
	}
	
	func managedObjectContextDidSave(notification: NSNotification) {
		
		print("***** IN \(#function)")
		
		let notificationContext = notification.object as! NSManagedObjectContext
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		
		if notificationContext == mainContext {
			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.retrieveExistingPhotosForDisplay()
			}
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func retrieveNewPhotos(sender: UIButton) {
		
		print("***** IN \(#function)")
		
		newCollectionButton.enabled = false
		
		deleteExistingPhotosForCurrentPin()
		
		retrieveNewPhotos()
	}
	
	
	// MARK: - Private Functions
	
	private func retrieveNewPhotos() {

		print("***** IN \(#function)")
		
		// use a queue to run the request in the background
		let backgroundQueue = NSOperationQueue()
		backgroundQueue.name = "backgroundQueue"
		backgroundQueue.addOperationWithBlock {
		
			let flickrAPI = Flickr()
			flickrAPI.getImages(forPin: self.pin)
		}
	}
	
	private func retrieveExistingPhotosForDisplay() {

		print("***** IN \(#function)")
		
		let request = NSFetchRequest.allPhotosForPin(pin)
		
		guard let newPhotos = try? CoreDataStack.shared.mainManagedObjectContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}
		
		photos = newPhotos
		
		collectionView.reloadData()
		
		newCollectionButton.enabled = true
	}
	
	private func deleteExistingPhotosForCurrentPin() {
		
		print("***** IN \(#function)")
		
		let request = NSFetchRequest.allPhotosForPin(pin)
		
		guard let photosToDelete = try? CoreDataStack.shared.mainManagedObjectContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}

		for photo in photosToDelete {
			CoreDataStack.shared.mainManagedObjectContext.deleteObject(photo)
		}
		
		CoreDataStack.shared.saveContext()
	}
	
	private func deletePhotoAtRow(row: Int) {
		
		print("***** IN \(#function)")
		
		let managedPhoto = photos[row]
		
		CoreDataStack.shared.mainManagedObjectContext.deleteObject(managedPhoto)

		CoreDataStack.shared.saveContext()
	}
	
	
}
