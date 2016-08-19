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
	var fetchRequest: NSFetchRequest!
	
	var numPhotosToDisplay: Int!
	
	
	// MARK: - Outlets
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		collectionView!.delegate = self
		
		subscribeToNotifications()
		
		// note: to test zero photos, simply delete photos for this pin from the database
		numPhotosToDisplay = photos.count
		
		if numPhotosToDisplay == 0 {
			callFlickrForNewPhotos()
		}
    }
	
	deinit {
		// unsubscribe us from all notifications we're observing!
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


    // MARK: - UICollectionViewDataSource

	// using default number of sections (1), so no override for numberOfSections
	
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return numPhotosToDisplay
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
		
		cellImageView.image = UIImage(data: imageData)
		
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
	
	
	// MARK: - Observer-Related Methods
	
	private func subscribeToNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosWillBeSaved(_:)),
		                                                 name: FlickrConstants.NotificationKeys.PhotosWillSaveNotification,
		                                                 object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosDidSave(_:)),
		                                                 name: FlickrConstants.NotificationKeys.PhotosDidSaveNotification,
		                                                 object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(noPhotosDidSave(_:)),
		                                                 name: FlickrConstants.NotificationKeys.NoPhotosDidSaveNotification,
		                                                 object: nil)
	}
	
	func photosWillBeSaved(notification: NSNotification) {
		
		if let userInfo = notification.userInfo as? [String: Int] {
			numPhotosToDisplay = userInfo[FlickrConstants.NotificationKeys.NumPhotosToBeSavedKey]!
		}
		
		print("IN \(#function) - numPhotosToDisplay: \(numPhotosToDisplay)")
		
		collectionView!.reloadData()
	}
	
	func photosDidSave(notification: NSNotification) {
		
		if let userInfo = notification.userInfo as? [String: Int] {
			numPhotosToDisplay = userInfo[FlickrConstants.NotificationKeys.NumPhotosSavedKey]!
		}
		
		var photosRemaining: Int = numPhotosToDisplay
		var currentPhoto: Int = 0
		while photosRemaining > 0 {
			guard let photosFromDB = try? CoreDataStack.shared.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [Photo] else {
				continue
			}
			
			let numPhotosAvailable = photosFromDB.count
			if numPhotosAvailable > 0 {
				photos = photosFromDB
				
				collectionView.reloadData()
				
				let maxIndex = numPhotosAvailable - 1
				for indexValue in currentPhoto...maxIndex {
					let indexPath = NSIndexPath(forItem: indexValue, inSection: 0)
					if collectionView!.numberOfItemsInSection(0) == currentPhoto {
						collectionView!.insertItemsAtIndexPaths([indexPath])
					}
					else {
						collectionView!.reloadItemsAtIndexPaths([indexPath])
					}
					currentPhoto += 1
					photosRemaining -= 1
				}
			}
		}
	}
	
	func noPhotosDidSave(notification: NSNotification) {
		// TODO: what do we want to do if no photos were saved???
		print("No photos were saved.")
	}
	
	
	// MARK: - Actions
	
	@IBAction func retrieveNewPhotos(sender: UIButton) {
		
		deleteExistingPhotosForCurrentPin()
		
		callFlickrForNewPhotos()
	}
	
	
	// MARK: - Private Functions
	
	private func callFlickrForNewPhotos() {

		let flickrAPI = Flickr()
		flickrAPI.getImages(forPin: pin)
	}
	
	private func deleteExistingPhotosForCurrentPin() {
		
		let request = NSFetchRequest(entityName: "Photo")
		let predicate = NSPredicate(format: "pin == %@", pin)
		request.predicate = predicate
		
		guard let photosToDelete = try? CoreDataStack.shared.privateManagedObjectContext.executeFetchRequest(request) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}
		
		for photo in photosToDelete {
			CoreDataStack.shared.privateManagedObjectContext.deleteObject(photo)
		}
		
		CoreDataStack.shared.saveContext()
	}
	
	
}
