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
	
	
	// MARK: - Properties (non-outlets)
	
	var pin: Pin!
	var photos: [Photo]!
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView!.delegate = self
		
		subscribeToNotifications()
		
		// note: to test zero photos, simply delete photos for this pin from the database
		let numPhotosToDisplay = photos.count
		
		if numPhotosToDisplay == 0 {
			newCollectionButton.enabled = false
			
			// get new photos
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

		let numItems = photos.count
		
		return numItems
    }

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.hidesWhenStopped = true
		
		var imageData = NSData()
		
		if photos.count > 0 {
			imageData = photos[indexPath.row].photo!
		}
		else {
			// TODO: alert that photos are being retrieved
		}
		
		cellImageView.image = UIImage(data: imageData)
		
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		
        return true
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let row = indexPath.row
		deletePhotoAtRow(row)
	}

	
	// MARK: - Observer-Related Methods
	
	private func subscribeToNotifications() {
		
		/* Managed Object Context notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(managedObjectContextDidSave(_:)),
		                                                 name: NSManagedObjectContextDidSaveNotification,
		                                                 object: nil)
	}
	
	func managedObjectContextDidSave(notification: NSNotification) {
		
		let notificationContext = notification.object as! NSManagedObjectContext
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		
		if notificationContext == mainContext {
			retrieveExistingPhotosForDisplay()
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func retrieveNewPhotos(sender: UIButton) {
		
		newCollectionButton.enabled = false
		
		deleteExistingPhotosForCurrentPin()
		
		retrieveNewPhotos()
	}
	
	
	// MARK: - Private Functions
	
	private func retrieveNewPhotos() {

		// use a queue to run the request in the background
		let backgroundQueue = NSOperationQueue()
		backgroundQueue.name = "backgroundQueue"
		backgroundQueue.addOperationWithBlock {
		
			let flickrAPI = Flickr()
			flickrAPI.getImages(forPin: self.pin)
		}
	}
	
	private func retrieveExistingPhotosForDisplay() {

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
		
		let managedPhoto = photos[row]
		
		CoreDataStack.shared.mainManagedObjectContext.deleteObject(managedPhoto)

		CoreDataStack.shared.saveContext()
	}
	
	
}
