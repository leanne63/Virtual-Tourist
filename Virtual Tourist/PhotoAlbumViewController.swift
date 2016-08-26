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
	
	/// Selected pin for which photos are to be displayed
	var pin: Pin!
	/// Array to hold photos to be displayed for pin
	var photos = [Photo]()
	/// Indicates whether new photos have been requested
	var requestingNewPhotos = false
	/// Number of photos expected to be retrieved from new photo request
	var expectedNumPhotos: Int = FlickrConstants.Defaults.NumberOfPhotos
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView!.delegate = self
		
		subscribeToNotifications()
		
		let photosPresent = loadPhotosFromDB()
		
		newCollectionButton.enabled = photosPresent
		
		if !photosPresent {
			requestingNewPhotos = true
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

		let actualNumPhotos = photos.count
		let numItems = (requestingNewPhotos) ? expectedNumPhotos : actualNumPhotos
		
		return numItems
    }

	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		// we're requesting new photos, but haven't received any yet: all indices get placeholder + activity indicator
		let noPhotosAvailable = (photos.count == 0)
		if requestingNewPhotos && noPhotosAvailable {
			// place an activity indicator in the cell to note photos are coming!
			cellImageView.hidden = true
			
			let activityIndicator = UIActivityIndicatorView()
			activityIndicator.activityIndicatorViewStyle = .WhiteLarge
			activityIndicator.hidesWhenStopped = true
			
			cell.backgroundView = activityIndicator
			activityIndicator.startAnimating()
		}
		else {
			// if we're not requesting new photos (array is filled),
			//	OR we're requesting new photos, and are reloading cells
		
			// check for an activity indicator from last time through; if there, stop animating/hide it
			if let backgroundView = cell.backgroundView as? UIActivityIndicatorView {
				backgroundView.stopAnimating()
			}
			
			// put the photo in place
			let imageData: NSData = photos[indexPath.item].photo!
			
			cellImageView.image = UIImage(data: imageData)
			cellImageView.hidden = false
			
			// if we're on the last photo, re-enable the "new collection" button
			let isLastItem =
				(requestingNewPhotos && indexPath.item == expectedNumPhotos - 1) ||
				(!requestingNewPhotos && indexPath.item == photos.count - 1)
			if isLastItem {
				requestingNewPhotos = false
				newCollectionButton.enabled = true
				
				// check for, and remove, any excess cells (eg, when actual count less than default count)
				let itemsCount: Int = collectionView.numberOfItemsInSection(0)
				let excessItemsStartIndex: Int = indexPath.item + 1
				if  itemsCount > excessItemsStartIndex {
					var indexPathArray = [NSIndexPath]()
					for excessItem in excessItemsStartIndex..<itemsCount {
						let indexPath = NSIndexPath(forItem: excessItem, inSection: 0)
						indexPathArray.append(indexPath)
					}
					collectionView.deleteItemsAtIndexPaths(indexPathArray)
				}
			}
		}

		return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		
        return true
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let arrayRow = indexPath.item
		deletePhotoAtRow(arrayRow)
		
		collectionView.deleteItemsAtIndexPaths([indexPath])
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
		                                                 object: CoreDataStack.shared.mainManagedObjectContext)
	}
	
	func photosWillSave(notification: NSNotification) {
		
		// set the expected number of photos to allow for placeholders
		expectedNumPhotos = notification.userInfo![FlickrConstants.NotificationKeys.NumPhotosToBeSavedKey] as! Int
	}
	
	func managedObjectContextDidSave(notification: NSNotification) {
		
		// received notice that main managed object has saved; so reload a cell with its new photo
		if requestingNewPhotos {
			guard let userInfo = notification.userInfo, let insertedObjects = userInfo[NSInsertedObjectsKey]
				where insertedObjects.count > 0 else {
					// we only care about inserted items in this controller
					return
			}

			// retrieve the inserted photo from this save event
			let insertedPhoto = insertedObjects.allObjects.first as! Photo

			// add new photo to array (which was cleared when we requested new photos)
			photos.append(insertedPhoto)

			// now load the photo into its corresponding collection view cell
			let thisPhotoIndex = photos.count - 1
			let cellIndex = NSIndexPath(forItem: thisPhotoIndex, inSection: 0)

			collectionView.reloadItemsAtIndexPaths([cellIndex])
		}
	}
	
	
	// MARK: - Actions
	
	@IBAction func newCollectionButtonPressed(sender: UIButton) {
		
		requestingNewPhotos = true
		newCollectionButton.enabled = false
		
		deleteAllPhotosForCurrentPin()
		
		// reload the view with indicators of coming photos
		collectionView.reloadData()
		
		retrieveNewPhotosFromFlickr()
	}
	
	
	// MARK: - Private Functions
	
	private func retrieveNewPhotosFromFlickr() {
		
		let flickrAPI = Flickr()
		flickrAPI.getImages(forPin: pin)
	}
	
	private func loadPhotosFromDB() -> Bool {
		// retrieve any photos related to the pin
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		let photoRequest = NSFetchRequest.allPhotosForPin(pin)
		guard let photosFromDB = try? mainContext.executeFetchRequest(photoRequest) as! [Photo] where photosFromDB.count > 0 else {
			
			// no photos were available in the database
			return false
		}
		
		photos = photosFromDB
		
		// photos were successfully found in database and loaded into array
		return true
	}
	
	private func deletePhotoAtRow(row: Int) {
		
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		
		let photoToDeleteID = photos[row].objectID
		guard let managedPhoto = try? mainContext.existingObjectWithID(photoToDeleteID) else {
			print("Unable to locate selected photo in database!")
			return
		}
		
		mainContext.deleteObject(managedPhoto)
		
		CoreDataStack.shared.saveContext()
		
		photos.removeAtIndex(row)
	}
	
	/// Deletes photos from Core Data, and removes photos from controller's photo array
	private func deleteAllPhotosForCurrentPin() {
		
		// delete photos from Core Data
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		let request = NSFetchRequest.allPhotosForPin(pin)
		guard let photosToDelete = try? mainContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}

		for photo in photosToDelete {
			mainContext.deleteObject(photo)
		}
		
		CoreDataStack.shared.saveContext()
		
		// clear current photos array, too
		photos.removeAll()
	}
	
	
}
