//
<<<<<<< HEAD
//  Flickr.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit


/// Provides access to the Flickr API
class Flickr {
	
	// MARK: - Protected Functions
	
	/**
	Retrieve images from Flickr
	
	- parameter forPin: Pin object containing latitude and longitude to search
	*/
	func getImages(forPin pin: Pin) {

		// get standard parameters
		var methodParameters: [String: String!] = getStandardParameters()

		// add custom parms for bounding box search
		methodParameters[FlickrConstants.ParameterKeys.BoundingBox] = bboxString(pin)

		// added this parameter to "limit" the geo search; per flickr docs: w/o limiter,
		//	only photos uploaded in last 12 hours will be returned
		methodParameters[FlickrConstants.ParameterKeys.MinDateUploaded] = FlickrConstants.ParameterValues.MinUploadDate

		retrieveImagesFromFlickrBySearch(methodParameters, forPin: pin)
	}
	
	
	// MARK: - Private Functions
	
	private func getStandardParameters() -> ([String: String!]) {
		var standardParameters: [String: String!] = [:]
		
		standardParameters[FlickrConstants.ParameterKeys.APIKey] = FlickrConstants.ParameterValues.APIKey
		standardParameters[FlickrConstants.ParameterKeys.Method] = FlickrConstants.ParameterValues.SearchMethod
		standardParameters[FlickrConstants.ParameterKeys.SafeSearch] = FlickrConstants.ParameterValues.UseSafeSearch
		standardParameters[FlickrConstants.ParameterKeys.Extras] = FlickrConstants.ParameterValues.MediumURL
		standardParameters[FlickrConstants.ParameterKeys.Format] = FlickrConstants.ParameterValues.ResponseFormat
		standardParameters[FlickrConstants.ParameterKeys.NoJSONCallback] = FlickrConstants.ParameterValues.DisableJSONCallback
		standardParameters[FlickrConstants.ParameterKeys.PerPage] = FlickrConstants.ParameterValues.NumPerPage
		
		return standardParameters
	}
	
	private func bboxString(pin: Pin) -> String {
		
		// calculate a value higher, lower, left, and right of pin's lon abs(180)/lat abs(90)
		// -180, -90, 180, 90 are default values if no bbox specified
		// Udacity example: pin contains 48.85 lat/2.29 lon
		// Result: 1.29, 47.85, 3.29, 49.85
		
		let pinLonLat = (lon: pin.longitude, lat: pin.latitude)
		
		let bbox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)
		bbox.bottomLeftLon = pinLonLat.lon - FlickrConstants.API.SearchBBoxHalfHeight
		bbox.bottomLeftLat = pinLonLat.lat - FlickrConstants.API.SearchBBoxHalfWidth
		bbox.topRightLon = pinLonLat.lon + FlickrConstants.API.SearchBBoxHalfHeight
		bbox.topRightLat = pinLonLat.lat + FlickrConstants.API.SearchBBoxHalfWidth
		
		let validatedBBox = validateBBox(bbox)
		
		let resultString = "\(validatedBBox.bottomLeftLon),\(validatedBBox.bottomLeftLat),\(validatedBBox.topRightLon),\(validatedBBox.topRightLat)"
		
		return resultString
	}

	private func validateBBox(bbox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)) ->
		(bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double) {
		
		let newBBox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)
		newBBox.bottomLeftLon = max(FlickrConstants.API.SearchLonRange.0, bbox.bottomLeftLon)
		newBBox.bottomLeftLat = max(FlickrConstants.API.SearchLatRange.0, bbox.bottomLeftLat)
		newBBox.topRightLon = min(FlickrConstants.API.SearchLonRange.1, bbox.topRightLon)
		newBBox.topRightLat = min(FlickrConstants.API.SearchLatRange.1, bbox.topRightLat)
		
		return newBBox
	}
	
	
	/**
	Retrieves all images for given pin's latitude and longitude.
	
	- parameters:
		- methodParameters: Dictionary of parameters to be used for request.
		- forPin: Pin object containing latitude and longitude to search.
	*/
	private func retrieveImagesFromFlickrBySearch(methodParameters: [String: AnyObject], forPin pin: Pin) {
		
		// TODO: remove test prints
		print(flickrURLFromParameters(methodParameters))
		
		let requestURL = flickrURLFromParameters(methodParameters)
		let request = NSURLRequest(URL: requestURL)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			func displayError(errorMsg: String) {
				print(errorMsg)
				print("URL at time of error:\n\(request.URL!)")
			}
			
			guard (error == nil) else {
				displayError("There was an error with the request:\n\(error!.localizedDescription)")
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
				where statusCode >= 200 && statusCode <= 299 else {
					
					displayError("Your request returned a status code other than 2xx (success): \((response as? NSHTTPURLResponse)?.statusCode)")
					return
			}
			
			guard let returnedData = data else {
				displayError("Unable to retrieve data:\n\(error)")
				return
			}
			
			guard let parsedData = try? NSJSONSerialization.JSONObjectWithData(returnedData, options: .AllowFragments) else {
				displayError("Couldn't parse the data as JSON:\n\(data)")
				return
			}
			
			guard let status = parsedData[FlickrConstants.ResponseKeys.Status] as? String
				where status == FlickrConstants.ResponseValues.OKStatus else {
					
					displayError("Flickr API returned an error. Details follow:\n\(parsedData)")
					return
			}
			
			guard let photosDictionary = parsedData[FlickrConstants.ResponseKeys.Photos] as? [String: AnyObject] else {
				displayError("Cannot find key \(FlickrConstants.ResponseKeys.Photos) in \(parsedData)")
				return
			}
			
			guard let numPages = photosDictionary[FlickrConstants.ResponseKeys.Pages] as? Int else {
				displayError("Cannot find key \(FlickrConstants.ResponseKeys.Pages) in \(parsedData)")
				return
			}
			
			let randomPageNumber = Int(arc4random_uniform(UInt32(numPages)))
			print("random page number: \(randomPageNumber) of \(numPages) total pages")
			
			print("***** PHOTOS DICTIONARY, \(numPages) pages, random page chosen: \(randomPageNumber) *****\n\(photosDictionary)")
			
			self.retrieveImagesFromFlickrBySearch(methodParameters, withPageNumber: randomPageNumber, forPin: pin)
		}
		
		task.resume()
	}
	
	
	/**
	Retrieves images for a given page number within a given pin's latitude and longitude.
	
	- parameters:
	- methodParameters: Dictionary of parameters to be used for request.
	- withPageNumber: Page number to use for retrieving photo results.
	- forPin: Pin object containing latitude and longitude to search.
	*/
	private func retrieveImagesFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber page: Int, forPin pin: Pin) {
		
		// 'var' parameters are deprecated in Swift 2.2, to be removed in Swift 3.0
		// so, using "shadow" variable here that can be changed later to add the page number
		var methodParameters = methodParameters
		
		// now we can add the desired page number
		methodParameters[FlickrConstants.ParameterKeys.Page] = page
		
		// TODO: remove test prints
		print("PAGE:\n\(flickrURLFromParameters(methodParameters))")
		
		// and make the request
		let requestURL = flickrURLFromParameters(methodParameters)
		let request = NSURLRequest(URL: requestURL)
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
			(data, response, error) in
			
			var userInfo: [String: AnyObject]!
			func sendErrorNotification(errorMsg: String) {
				// notify observers of failure
				userInfo = [FlickrConstants.NotificationKeys.MessageKey: errorMsg]
				userInfo[FlickrConstants.NotificationKeys.RequestURLKey] = String(request.URL!)
				NSNotificationCenter.postNotificationOnMain(FlickrConstants.NotificationKeys.PhotoRetrievalDidFailNotification, object: nil, userInfo: userInfo)
			}
			
			guard (error == nil) else {
				sendErrorNotification(error!.localizedDescription)
				return
			}
			
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode
				where statusCode >= 200 && statusCode <= 299 else {
					
					sendErrorNotification("Your request returned a status code other than 2xx (success): \((response as? NSHTTPURLResponse)?.statusCode)")
					return
			}
			
			guard let returnedData = data else {
				sendErrorNotification("Unable to retrieve data:\n\(error)")
				return
			}
			
			guard let parsedData = try? NSJSONSerialization.JSONObjectWithData(returnedData, options: .AllowFragments) else {
				sendErrorNotification("Couldn't parse the data as JSON:\n\(data)")
				return
			}
			
			guard let status = parsedData[FlickrConstants.ResponseKeys.Status] as? String
				where status == FlickrConstants.ResponseValues.OKStatus else {
					
					sendErrorNotification("Flickr API returned an error. Details follow:\n\(parsedData)")
					return
			}
			
			guard let photosDictionary = parsedData[FlickrConstants.ResponseKeys.Photos] as? [String: AnyObject],
				photoArray = photosDictionary[FlickrConstants.ResponseKeys.Photo] as? [[String: AnyObject]] else {
					
					sendErrorNotification("Cannot find keys \(FlickrConstants.ResponseKeys.Photos) and \(FlickrConstants.ResponseKeys.Photo) in \(parsedData)")
					return
			}
			
			// notify observers of photo count
			userInfo = [FlickrConstants.NotificationKeys.NumPhotosToBeSavedKey : photoArray.count]
			NSNotificationCenter.postNotificationOnMain(FlickrConstants.NotificationKeys.PhotosWillBeSavedNotification, object: nil, userInfo: userInfo)

			
			// if no photos were retrieved, we don't need to save anything, so just return
			guard photoArray.count > 0  else {
				
				return
			}
			
			// alrighty, then! We've got photos, so let's save them!
			var numPhotosSaved = 0
			for photo in photoArray {
				guard let imageURLString = photo[FlickrConstants.ResponseKeys.MediumURL] as? String else {
					// if no (or invalid) URL for this photo, just move on to next one
					continue
				}
				
				// retrieve the image data from the web
				let imageURL = NSURL(string: imageURLString)
				guard let imageData = NSData(contentsOfURL: imageURL!) else {
					// if no (or invalid) imageData found for this photo, just move on to next one
					continue
				}
				
				// save the image data to the database, associated with the appropriate pin (not using result, so set as '_')
				let _ = Photo(photo: imageData, pin: pin, context: CoreDataStack.shared.privateManagedObjectContext)
				
				numPhotosSaved += 1
			}
			
			// save the context
			CoreDataStack.shared.saveContext()
			
			// TODO: remove test print statement
			print("***** \(numPhotosSaved) PHOTOS WERE SAVED *****")
			
			// notify observers that we're done!
			userInfo = [FlickrConstants.NotificationKeys.NumPhotosSavedKey: numPhotosSaved]
			NSNotificationCenter.postNotificationOnMain(FlickrConstants.NotificationKeys.PhotosDidSaveNotification, object: nil, userInfo: userInfo)
		}
		
		task.resume()
	}

	private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
		
		let components = NSURLComponents()
		components.scheme = FlickrConstants.API.Scheme
		components.host = FlickrConstants.API.Host
		components.path = FlickrConstants.API.Path
		// don't need to init array, 'cause known type
		//components.queryItems = [NSURLQueryItem]()
		components.queryItems = []
		
		for (key, value) in parameters {
			let queryItem = NSURLQueryItem(name: key, value: "\(value)")
			components.queryItems!.append(queryItem)
		}
		
		return components.URL!
	}

}
