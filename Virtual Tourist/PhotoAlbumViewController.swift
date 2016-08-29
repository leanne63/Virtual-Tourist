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
	/// Pin, if any, whose photos were being downloaded when this controller became active
	var pinForPhotosInProgress: Pin?
	/// Array to hold photos to be displayed for pin
	var photos = [Photo]()
	/// Indicates whether new photos have been requested
	var requestingNewPhotos = false
	/// Indicates whether photos are still being loaded from map view's request
	var waitingForInitialPhotos = false
	/// Number of photos expected to be retrieved from new photo request
	var expectedNumPhotos: Int = FlickrConstants.Defaults.NumberOfPhotos
	/// Indicates whether collection view cells should be selectable
	var cellsAreSelectable = false
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var newCollectionButton: UIButton!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView.delegate = self
		
		// subscribe immediately to the photosDidSave notification, so we can take advantage
		//	of this one while waiting for initial photos without others getting in the way
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosDidSave(_:)),
		                                                 name: FlickrConstants.Notifications.PhotosDidSaveNotification,
		                                                 object: nil)
		
		
		// if the photo download from the map view for this pin is not currently in progress,
		//	we can continue loading photos and watch for all notifications
		waitingForInitialPhotos = (pinForPhotosInProgress != nil && pinForPhotosInProgress == pin)
		if !waitingForInitialPhotos {
			loadPhotos()
			subscribeToNotifications()
		}

		// if our pin is in progress from the map page, though, we need to load
		//	placeholders, and wait til we get notification that the save completed
		setUpCollectionViewBackground(isEmpty: true)
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
		
		setUpCollectionViewBackground(isEmpty: false)

		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		let currentItemNum = indexPath.item
		let isLastItem =
			(requestingNewPhotos && currentItemNum == expectedNumPhotos - 1) ||
				(!requestingNewPhotos && currentItemNum == photos.count - 1)

		// we're requesting new photos, but haven't received any yet: all indices get placeholder + activity indicator
		if needPlaceholders()  {
			// since we have some cells that aren't loaded, make sure our cells aren't selectable yet!
			cellsAreSelectable = false
			
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
				
				// since we're done loading the collection view, mark the cells as selectable
				cellsAreSelectable = true
			}
		}

		return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		
		return cellsAreSelectable
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let arrayRow = indexPath.item
		deletePhotoAtRow(arrayRow)
		
		collectionView.deleteItemsAtIndexPaths([indexPath])
		
		if collectionView.visibleCells().count == 0 {
			setUpCollectionViewBackground(isEmpty: true)
		}
	}

	
	// MARK: - Observer-Related Methods
	
	private func subscribeToNotifications() {
		
		/* custom app-specific notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosWillSave(_:)),
		                                                 name: FlickrConstants.Notifications.PhotosWillSaveNotification,
		                                                 object: nil)

		/* Managed Object Context notifications */
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(managedObjectContextDidSave(_:)),
		                                                 name: NSManagedObjectContextDidSaveNotification,
		                                                 object: CoreDataStack.shared.mainManagedObjectContext)
	}
	
	func photosWillSave(notification: NSNotification) {
		
		// set the expected number of photos to allow for placeholders
		expectedNumPhotos = notification.userInfo![FlickrConstants.Notifications.NumPhotosToBeSavedKey] as! Int
	}
	
	func photosDidSave(notification: NSNotification) {
		
		if waitingForInitialPhotos {
			waitingForInitialPhotos = false
			
			loadPhotos()
			collectionView.reloadData()
			
			// now that we've received the initial photos, turn on the rest of the notifications
			subscribeToNotifications()
		}
	}
	
	func managedObjectContextDidSave(notification: NSNotification) {
		
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		let savedContext = notification.object as! NSManagedObjectContext
		let isMainManagedObjectContext = (mainContext == savedContext)
		
		// received notice that main managed object has saved; so reload a cell with its new photo
		if isMainManagedObjectContext && requestingNewPhotos {
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
	
	/**
	Sets up collection view's background to display message if it's empty, or clear it if not
	*/
	func setUpCollectionViewBackground(isEmpty isEmpty: Bool) {
		
		guard let theCollectionView = collectionView else {
			return
		}
		
		// code modified from:
		// iOS Programming 101: Implementing Pull-to-Refresh and Handling Empty Table
		//	Simon Ng, 11 July 2014
		//	http://www.appcoda.com/pull-to-refresh-uitableview-empty/
		
		let emptyMessageText: String
		if waitingForInitialPhotos {
			emptyMessageText = "Photos are on their way!\n\nPlease be patient..."
		}
		else {
			emptyMessageText = "Photos have all been deleted!\n\nPress New Collection button for more."
		}
		
		let fontName = "Palatino-Italic"
		let fontSize: CGFloat = 20.0
		
		if !isEmpty {
			if theCollectionView.backgroundView != nil {
				theCollectionView.backgroundView = nil
			}
		}
		else {
			if theCollectionView.backgroundView == nil {
				let emptyMessageLabel = UILabel(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height))
				emptyMessageLabel.text = emptyMessageText
				emptyMessageLabel.numberOfLines = 0
				emptyMessageLabel.font = UIFont(name: fontName, size: fontSize)
				emptyMessageLabel.textAlignment = .Center
				emptyMessageLabel.sizeToFit()
				
				theCollectionView.backgroundView = emptyMessageLabel
			}
		}
	}

	
	/// Determines if placeholders are needed in collection view.
	private func needPlaceholders() -> Bool {
		
		let noPhotosAvailable = (photos.count == 0)
		let requestIncomplete = (requestingNewPhotos && noPhotosAvailable)
		let needsPlaceholders = (requestIncomplete || waitingForInitialPhotos)
		
		return needsPlaceholders
	}
	
	/// Loads photos from database, if present, or requests new photos if not.
	private func loadPhotos() {
		
		let photosPresent = loadPhotosFromDB()
		
		newCollectionButton.enabled = photosPresent
		
		if !photosPresent {
			requestingNewPhotos = true
			retrieveNewPhotosFromFlickr()
		}
	}
	
	/// Calls Flickr model to retrieve photos.
	private func retrieveNewPhotosFromFlickr() {
		
		let flickrAPI = Flickr()
		flickrAPI.getImages(forPin: pin)
	}
	
	/**
	Attempts to load photos array from database.
	
	- returns: True, if photo load completes successfully; false if no photos were found in database.
	*/
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
	
	/**
	Deletes specified managed photo from the photo array and the database.
	
	- parameter row: Index of managed photo to be deleted.
	*/
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
