//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by leanne on 7/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit

class MapViewController: UIViewController {
	
	// MARK: - Constants
	
	private let hasLaunchedKey = "hasLaunched"
	private let photoAlbumSegueID = "mapToPhotoAlbumSegue"
	

	// MARK: - Properties (Non-Outlets)
	
	private var longPressBeginPoint: CGPoint!
	private var longPressEndPoint: CGPoint!
	
	
	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	// MARK: - Overrides (Lifecycle)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let hasLaunchedPreviously: Bool = NSUserDefaults.standardUserDefaults().boolForKey(hasLaunchedKey)
		if !hasLaunchedPreviously {
			// since hasn't launched previously, create the "has launched" value now
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasLaunchedKey)
			
			// store the initial map values
			storeCurrentMapRegion()
		}
		
		mapView.region = createMapRegionFromStoredValues()
	}
	
	
	// MARK: - Actions

	@IBAction func segueToPhotoAlbum(sender: UIButton) {
		
		storeCurrentMapRegion()
		
		performSegueWithIdentifier(photoAlbumSegueID, sender: self)
	}
	
	@IBAction func longPressDidOccur(sender: UILongPressGestureRecognizer) {
		
		// TODO: Compare began and ended states to see if a pin was moved (assuming one already existed)
		switch sender.state {
			
		case .Began:
			longPressBeginPoint = sender.locationInView(mapView)
			
		case .Ended:
			longPressEndPoint = sender.locationInView(mapView)
			
			// did annotation exist at this point? if so, don't create new one
			let endCoordinate: CLLocationCoordinate2D = mapView.convertPoint(longPressEndPoint, toCoordinateFromView: mapView)
			
			if longPressEndPoint == longPressBeginPoint {
				// drop new pin at this location (if one doesn't already exist)
				
				let pinAlreadyPresent = mapView.annotations.contains({ $0.coordinate == endCoordinate })
				
				let annotation = MKPointAnnotation()
				annotation.coordinate = endCoordinate
				
				mapView.addAnnotation(annotation)
			}
			else {
				// if pinPresentAtBeginPoint { // move pin to this new location }
			}
			
		default:
			// if it's any other case, just exit
			return
		}
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

