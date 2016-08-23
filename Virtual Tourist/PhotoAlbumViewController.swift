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
	
	var mainContext: NSManagedObjectContext!
	var pin: Pin!
	var photos: [Photo]!
	var expectedNumberOfPhotos: Int = 0
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		newCollectionButton.enabled = false
		
		collectionView!.delegate = self
		
		subscribeToNotifications()
		
		expectedNumberOfPhotos = photos.count
		
		if expectedNumberOfPhotos == 0 {
			// get new photos
			retrieveNewPhotosFromFlickr()
		}
    }
	
	deinit {
		// unsubscribe us from all notifications we're observing!
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


    // MARK: - UICollectionViewDataSource

	// using default number of sections (1), so no override for numberOfSections
	
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		let numItems = (expectedNumberOfPhotos > 0) ? expectedNumberOfPhotos : FlickrConstants.Defaults.NumberOfPhotos
		
		return numItems
    }

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
		// if we've got photos to put in the cell, go for it
		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		let numPhotos = photos.count
		if numPhotos > 0 && indexPath.row < numPhotos {
			// check for an activity indicator from last time through; if there, stop animating/hide it
			if let backgroundView = cell.backgroundView as? UIActivityIndicatorView {
				backgroundView.stopAnimating()
			}
			
			// put the photo in place
			let imageData: NSData = photos[indexPath.row].photo!
			
			cellImageView.image = UIImage(data: imageData)
			cellImageView.hidden = false
			
			// if we're on the last photo, re-enable the "new collection" button
			if indexPath.row == numPhotos - 1 {
				newCollectionButton.enabled = true
			}
		}
		else {
			// otherwise, place an activity indicator in the cell to note photos are coming!
			cellImageView.hidden = true
			
			let activityIndicator = UIActivityIndicatorView()
			activityIndicator.activityIndicatorViewStyle = .WhiteLarge
			activityIndicator.hidesWhenStopped = true
			
			cell.backgroundView = activityIndicator
			activityIndicator.startAnimating()
		}
		
		
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		
        return true
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let row = indexPath.row
		deletePhotoAtRow(row)
		
		// decrease the expected number of photos, to ensure a correct number of placeholders
		expectedNumberOfPhotos -= 1
	}

	
	// MARK: - Observer-Related Methods
	
	private func subscribeToNotifications() {
		
		/* custom app-specific notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosWillSave(_:)),
		                                                 name: FlickrConstants.NotificationKeys.PhotosWillSaveNotification,
		                                                 object: nil)

		
		/* Managed Object Context notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(managedObjectContextDidSave(_:)),
		                                                 name: NSManagedObjectContextDidSaveNotification,
		                                                 object: nil)
	}
	
	func photosWillSave(notification: NSNotification) {
		
		expectedNumberOfPhotos = notification.userInfo![FlickrConstants.NotificationKeys.NumPhotosToBeSavedKey] as! Int
	}
	
	func managedObjectContextDidSave(notification: NSNotification) {
		
		let notificationContext = notification.object as! NSManagedObjectContext
		if notificationContext.concurrencyType == .PrivateQueueConcurrencyType {
			// save the parent via a block
			mainContext.performBlockAndWait {
				self.saveTheMainContext()
			}
		}
		else {
			saveTheMainContext()
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func retrieveNewPhotos(sender: UIButton) {
		
		newCollectionButton.enabled = false
		
		deleteExistingPhotosForCurrentPin()
		
		retrieveNewPhotosFromFlickr()
	}
	
	
	// MARK: - Private Functions
	
	/// Save the main context
	private func saveTheMainContext() {
		
		do {
			try self.mainContext.save()
		} catch {
			fatalError("Failure to save context: \(error)")
		}
	}
	
	private func retrieveNewPhotosFromFlickr() {
		
		let flickrAPI = Flickr()
		flickrAPI.getImages(forPin: pin, withMainContext: mainContext)
	}
	
	private func retrieveExistingPhotosForDisplay() {
		
		let request = NSFetchRequest.allPhotosForPin(pin)
		
		guard let newPhotos = try? mainContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}
		
		photos = newPhotos
		
		collectionView.reloadData()
	}
	
	private func deleteExistingPhotosForCurrentPin() {
		
		let request = NSFetchRequest.allPhotosForPin(pin)
		
		guard let photosToDelete = try? mainContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}

		for photo in photosToDelete {
			mainContext.deleteObject(photo)
		}
		
		do {
			try mainContext.save()
		}
		catch {
			fatalError("Failure to save context: \(error)")
		}
	}
	
	private func deletePhotoAtRow(row: Int) {
		
		// TODO: fix this delete (do we have a fetch request extension for a single photo? make one, if not)
		let photoToDelete = photos[row]
		//let managedPhoto = mainContext.objectWithID(photoToDelete.objectID)
		
		//mainContext.deleteObject(managedPhoto)
		mainContext.deleteObject(photoToDelete)

		do {
			try mainContext.save()
		}
		catch {
			fatalError("Failure to save context: \(error)")
		}
		
		photos.removeAtIndex(row)
	}
	
	
}
