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
	

	// MARK: - Properties (Outlets)
	
	@IBOutlet weak var mapView: MKMapView!
	
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// retrieve initial values for map region
		var centerLatitude: CLLocationDegrees = mapView.region.center.latitude
		var centerLongitude: CLLocationDegrees = mapView.region.center.longitude
		var spanLatitudeDelta: CLLocationDegrees = mapView.region.span.latitudeDelta
		var spanLongitudeDelta: CLLocationDegrees = mapView.region.span.longitudeDelta

		
		// if haven't launched previously, this key will not exist; however iOS will report its value as 'false'
		let hasLaunchedPreviously = NSUserDefaults.standardUserDefaults().boolForKey(hasLaunchedKey)
		
		if hasLaunchedPreviously {
			// retrieve stored map values from last use
			centerLatitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapCenterLatitudeKey)
			centerLongitude = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapCenterLongitudeKey)
			spanLatitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapSpanLatitudeDeltaKey)
			spanLongitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(MapModel.mapSpanLongitudeDeltaKey)
		}
		else {
			// since hasn't launched previously, create the "has launched" value now
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: hasLaunchedKey)

			// store current map region values for use on next startup
			NSUserDefaults.standardUserDefaults().setDouble(centerLatitude, forKey: MapModel.mapCenterLatitudeKey)
			NSUserDefaults.standardUserDefaults().setDouble(centerLongitude, forKey: MapModel.mapCenterLongitudeKey)
			NSUserDefaults.standardUserDefaults().setDouble(spanLatitudeDelta, forKey: MapModel.mapSpanLatitudeDeltaKey)
			NSUserDefaults.standardUserDefaults().setDouble(spanLongitudeDelta, forKey: MapModel.mapSpanLongitudeDeltaKey)
		}
		
		// set map's region
		let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
		let spanValues = MKCoordinateSpan(latitudeDelta: spanLatitudeDelta, longitudeDelta: spanLongitudeDelta)
		
		let region = MKCoordinateRegionMake(centerCoordinate, spanValues)

		mapView.region = region
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - Actions

	@IBAction func segueToPhotoAlbum(sender: UIButton) {
		
		// retrieve current map values for center and zoom (span) levels
		let centerLatitude: Double = mapView.region.center.latitude
		let centerLongitude: Double = mapView.region.center.longitude
		let spanLatitudeDelta: Double = mapView.region.span.latitudeDelta
		let spanLongitudeDelta: Double = mapView.region.span.longitudeDelta

		// store current map values for next launch
		NSUserDefaults.standardUserDefaults().setDouble(centerLatitude, forKey: MapModel.mapCenterLatitudeKey)
		NSUserDefaults.standardUserDefaults().setDouble(centerLongitude, forKey: MapModel.mapCenterLongitudeKey)
		NSUserDefaults.standardUserDefaults().setDouble(spanLatitudeDelta, forKey: MapModel.mapSpanLatitudeDeltaKey)
		NSUserDefaults.standardUserDefaults().setDouble(spanLongitudeDelta, forKey: MapModel.mapSpanLongitudeDeltaKey)
		
		// head on over to next view
		performSegueWithIdentifier(photoAlbumSegueID, sender: self)
	}

}

