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
	
	
	// MARK: - Properties (Non-Outlets)
	
	var startAnnotation = MKPointAnnotation()


	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	// MARK: - Overrides (Lifecycle)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		// TODO: REMOVE BELOW - USED ONLY FOR TESTING
//		do {
//			try CoreDataStack.shared.dropAllData()
//		}
//		catch {
//			// do nothing
//		}
//		// TODO: REMOVE ABOVE - USED ONLY FOR TESTING
		
		mapView.delegate = self
		
		let hasLaunchedPreviously: Bool = NSUserDefaults.standardUserDefaults().boolForKey(hasLaunchedKey)
		if !hasLaunchedPreviously {
			// since hasn't launched previously, create the "has launched" value now
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasLaunchedKey)
			
			// store the initial map region
			storeCurrentMapRegion()
		}
		
		mapView.region = createMapRegionFromStoredValues()
		
		loadMapData()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		guard let segueId = segue.identifier else {
			return
		}
		
		// if we're going to the photo album, pass the pin matching the annotation view that initiated this segue
		if segueId == photoAlbumSegueID {

			let location = (sender as! MKAnnotationView).annotation!.coordinate
			let pinRequest = NSFetchRequest.allPinsForLocation(location)
			
			let mainContext = CoreDataStack.shared.mainManagedObjectContext
			guard let pinsFound =
				try? mainContext.executeFetchRequest(pinRequest) as! [Pin] where pinsFound.count == 1 else {
					
					print("Unable to locate selected pin in database!")
					return
			}
			
			let destController = segue.destinationViewController as! PhotoAlbumViewController
			destController.pin = pinsFound[0]
		}
	}
	
	deinit {
		// unsubscribe us from all notifications we're observing!
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	// MARK: - Actions

	@IBAction func longPressDidOccur(sender: UILongPressGestureRecognizer) {
		
		if sender.state == UIGestureRecognizerState.Began {
			let longPressStartPoint: CGPoint = sender.locationInView(mapView)
			let startCoordinate: CLLocationCoordinate2D = mapView.convertPoint(longPressStartPoint, toCoordinateFromView: mapView)
			
			// drop new pin (temporary) at this location
			startAnnotation.coordinate = startCoordinate
			
			mapView.addAnnotation(startAnnotation)
		}
		
		if sender.state == UIGestureRecognizerState.Recognized {
			// get map location of press action
			let longPressEndPoint: CGPoint = sender.locationInView(mapView)
			let endCoordinate: CLLocationCoordinate2D = mapView.convertPoint(longPressEndPoint, toCoordinateFromView: mapView)
		
			// drop new pin at this location
			let endAnnotation = MKPointAnnotation()
			endAnnotation.coordinate = endCoordinate
			
			mapView.addAnnotation(endAnnotation)
			
			// remove the temporary start pin, as we're not saving it
			mapView.removeAnnotation(startAnnotation)
			
			// now, store endpoint pin in db
			// create the managed object
			let mainContext = CoreDataStack.shared.mainManagedObjectContext
			var newPin = Pin(context: mainContext)

			// += is overloaded for Pin and CLLocationCoordinate2D to add latitude and longitude in one step
			// (see OperatorOverloads.swift)
			newPin += endCoordinate
			
			// commit the new pin to the store
			CoreDataStack.shared.saveContext()
		}
	}
	
	
	// MARK: - MKMapViewDelegate Actions
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		
		mapView.deselectAnnotation(view.annotation!, animated: false)
		
		storeCurrentMapRegion()
		
		performSegueWithIdentifier(photoAlbumSegueID, sender: view)
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
	
	
	/// Loads pins from database.
	private func loadMapData() {
		
		let mainContext = CoreDataStack.shared.mainManagedObjectContext
		let request = NSFetchRequest.allPins()
		guard let pins = try? mainContext.executeFetchRequest(request) as! [Pin] else {
			
			print("Unable to retrieve pins from database!")
			return
		}
		
		var annotations = [MKPointAnnotation]()
		
		for pin in pins {
			
			let lat: Double = CLLocationDegrees(pin.latitude)
			let long: Double = CLLocationDegrees(pin.longitude)
			
			let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			
			annotations.append(annotation)
		}
		
		mapView.addAnnotations(annotations)
	}


}

