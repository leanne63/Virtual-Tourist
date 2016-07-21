//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by leanne on 7/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
	
	// MARK: - Constants
	
	let photoAlbumSegueID = "mapToPhotoAlbumSegue"
	

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	// MARK: - Actions

	@IBAction func segueToPhotoAlbum(sender: UIButton) {
		performSegueWithIdentifier(photoAlbumSegueID, sender: self)
	}

}

