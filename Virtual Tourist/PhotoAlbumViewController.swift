//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController {

	// MARK: - Constants
	
	private let reuseIdentifier = "reusableCell"
	
	
	// MARK: - Properties
	
	var pin: Pin!
	var photos: [Photo]!
	var fetchRequest: NSFetchRequest!
	
	var numPhotosToDisplay: Int!
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		subscribeToNotifications()
		
		// note: to test zero photos, simply delete photos for this pin from the database
		numPhotosToDisplay = photos.count
		
		if numPhotosToDisplay == 0 {
			// no photos were in DB, so call Flickr API to retrieve photos for this pin
			let flickrAPI = Flickr()
			flickrAPI.getImages(forPin: pin)
		}
    }
	
	deinit {
		// unsubscribe us from all notifications we're observing!
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}


    // MARK: - UICollectionViewDataSource

	// using default number of sections (1), so no override for numberOfSections
	
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return numPhotosToDisplay
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
		                                                 name: FlickrConstants.NotificationKeys.PhotosWillBeSavedNotification,
		                                                 object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(photosDidSave(_:)),
		                                                 name: FlickrConstants.NotificationKeys.PhotosDidSaveNotification,
		                                                 object: nil)
	}
	
	
	func photosWillBeSaved(notification: NSNotification) {
		
		if let userInfo = notification.userInfo as? [String: Int] {
			numPhotosToDisplay = userInfo[FlickrConstants.NotificationKeys.NumPhotosToBeSavedKey]!
		}
		
		collectionView!.reloadData()
	}
	
	func photosDidSave(notification: NSNotification) {
		print(#function)
		
		guard let photosFromDB = try? CoreDataStack.shared.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}
		
		if let userInfo = notification.userInfo as? [String: Int] {
			numPhotosToDisplay = userInfo[FlickrConstants.NotificationKeys.NumPhotosSavedKey]!
		}
		
		photos = photosFromDB
		
		let maxIndex = numPhotosToDisplay - 1
		for indexValue in 0...maxIndex {
			let indexPath = NSIndexPath(forItem: indexValue, inSection: 0)
			collectionView!.reloadItemsAtIndexPaths([indexPath])
		}
	}
	
	
	// MARK: - Private Functions
	
	// TODO: use this function for retrieving photos upon refresh
	/// Loads photos from database.
	private func loadPhotosForPin() {
		
		// we already have the fetch request, so go ahead and pull the photos for this request
		guard let photosFromDB = try? CoreDataStack.shared.privateManagedObjectContext.executeFetchRequest(fetchRequest) as! [Photo] else {
			
			print("An error occurred while retrieving photos for selected pin!")
			return
		}
		
		photos = photosFromDB
	}


}
