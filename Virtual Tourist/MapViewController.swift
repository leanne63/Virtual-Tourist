//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by leanne on 7/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
	
	// MARK: - Constants
	
	private let hasLaunchedKey = "hasLaunched"
	private let photoAlbumSegueID = "mapToPhotoAlbumSegue"
	private let pinViewReuseIdentifier = "reusablePinView"


	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	// MARK: - Overrides (Lifecycle)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		let hasLaunchedPreviously: Bool = NSUserDefaults.standardUserDefaults().boolForKey(hasLaunchedKey)
		if !hasLaunchedPreviously {
			// since hasn't launched previously, create the "has launched" value now
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasLaunchedKey)
			
			// store the initial map region
			storeCurrentMapRegion()
		}
		
		mapView.region = createMapRegionFromStoredValues()
	}
	
	
	// MARK: - Actions

	@IBAction func longPressDidOccur(sender: UILongPressGestureRecognizer) {
		
		if sender.state == UIGestureRecognizerState.Ended {
			// get map location of press action
			let longPressEndPoint: CGPoint = sender.locationInView(mapView)
			let endCoordinate: CLLocationCoordinate2D = mapView.convertPoint(longPressEndPoint, toCoordinateFromView: mapView)
		
			// drop new pin at this location
			let annotation = MKPointAnnotation()
			annotation.coordinate = endCoordinate
			
			mapView.addAnnotation(annotation)
			
			// now, store pin in db
			var newPin = Pin(context: CoreDataStack.shared.privateManagedObjectContext)
			// TODO: move operator overloads into their own file under Extensions
			// += is overloaded for Pin and CLLocationCoordinate2D to add latitude and longitude in one step
			// (see Extension_CLLocationCoordinate2D)
			newPin += endCoordinate

			CoreDataStack.shared.saveContext()
			
			// call Flickr API to retrieve photos for this pin
			let flickrAPI = Flickr()
			flickrAPI.getImages(forPin: newPin)
		}
	}
	
	
	// MARK: - MKMapViewDelegate Actions
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		
		mapView.deselectAnnotation(view.annotation!, animated: false)
		
		storeCurrentMapRegion()
		
		performSegueWithIdentifier(photoAlbumSegueID, sender: self)
	}
	
	
	// MARK: - Private Utility Functions
	
	/// Store current map region values (center coordinates and span values).
	private func storeCurrentMapRegion() {
		
		let centerLatitude = mapView.region.center.latitude
		let centerLongitude = mapView.region.center.longitude
		let spanLatitudeDelta = mapView.region.span.latitudeDelta
		let spanLongitudeDelta = mapView.region.span.longitudeDelta
		
		NSUserDefaults.standardUserDefaults().setDouble(centerLatitude, forKey: MapModel.mapCenterLatitudeKey)
		NSUserDefaults.standardUserDefaults().setDouble(centerLongitude, forKey: MapModel.mapCenterLongitudeKey)
		NSUserDefaults.standardUserDefaults().setDouble(spanLatitudeDelta, forKey: MapModel.mapSpanLatitudeDeltaKey)
		NSUserDefaults.standardUserDefaults().setDouble(spanLongitudeDelta, forKey: MapModel.mapSpanLongitudeDeltaKey)
	}
	
	
	/**
	Creates a map region object based on previously stored values.
	
	- returns: Map region object.
	*/
	private func createMapRegionFromStoredValues() -> MKCoordinateRegion {
		
		// retrieve stored map values
		let centerLatitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapCenterLatitudeKey)
		let centerLongitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapCenterLongitudeKey)
		let spanLatitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapSpanLatitudeDeltaKey)
		let spanLongitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapSpanLongitudeDeltaKey)
		
		// create the region
		let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
		let spanValues = MKCoordinateSpan(latitudeDelta: spanLatitudeDelta, longitudeDelta: spanLongitudeDelta)
		
		let region = MKCoordinateRegionMake(centerCoordinate, spanValues)
		
		// send the created region back
		return region
	}

}

