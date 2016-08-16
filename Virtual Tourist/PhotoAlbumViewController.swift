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
	
	
	// MARK: - Overrides (Lifecycle)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let numPhotosFromDB = photos.count
		
		print("numPhotosFromDB: \(numPhotosFromDB)")
		
//		if numPhotosFromDB > 0 {
//			collectionView!.reloadData()
//		}
//		else {
//			// TODO: no photos were in DB, so attempt to retrieve photos directly from flickr
//		}
		
    }


    // MARK: UICollectionViewDataSource

	// using default number of sections (1), so no override for numberOfSections
	
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

		return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
		let cellImageView = cell.viewWithTag(1) as! UIImageView
		
		let imageData: NSData = photos[indexPath.row].photo!
		
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
	
	
	// MARK: - Private Functions
	
	/// Loads pins from database.
	private func loadPhotosForPin() {
		
		let request = NSFetchRequest(entityName:"Pin")
		guard let photos = try? CoreDataStack.shared.privateManagedObjectContext.executeFetchRequest(request) as! [Photo] else {
			return
		}
		print("photos:\n\(photos)")
//		var annotations = [MKPointAnnotation]()
//		
//		for pin in pins {
//			
//			let lat: Double = CLLocationDegrees(pin.latitude)
//			let long: Double = CLLocationDegrees(pin.longitude)
//			
//			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//			
//			let annotation = MKPointAnnotation()
//			annotation.coordinate = coordinate
//			
//			annotations.append(annotation)
//		}
//		
//		mapView.addAnnotations(annotations)
	}


}
