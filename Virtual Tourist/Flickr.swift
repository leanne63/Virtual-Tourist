//
//  Flickr.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import MapKit


/// Provides access to the Flickr API
class Flickr {
	
	func getImages(pin: Pin) {
		// get standard parameters
		var methodParameters: [String: String!] = getStandardParameters()

		// add custom parms for bounding box search
		methodParameters[Constants.FlickrParameterKeys.BoundingBox] = bboxString(pin)

		// added this parameter to "limit" the geo search; per flickr docs: w/o limiter,
		//	only photos uploaded in last 12 hours will be returned
		methodParameters["min_date_uploaded"] = "2014/01/01"

		displayImageFromFlickrBySearch(methodParameters)
	}
	
	private func getStandardParameters() -> ([String: String!]) {
		var standardParameters: [String: String!] = [:]
		
		standardParameters[Constants.FlickrParameterKeys.APIKey] = Constants.FlickrParameterValues.APIKey
		standardParameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.SearchMethod
		standardParameters[Constants.FlickrParameterKeys.SafeSearch] = Constants.FlickrParameterValues.UseSafeSearch
		standardParameters[Constants.FlickrParameterKeys.Extras] = Constants.FlickrParameterValues.MediumURL
		standardParameters[Constants.FlickrParameterKeys.Format] = Constants.FlickrParameterValues.ResponseFormat
		standardParameters[Constants.FlickrParameterKeys.NoJSONCallback] = Constants.FlickrParameterValues.DisableJSONCallback
		
		return standardParameters
	}
	
	private func bboxString(pin: Pin) -> String {
		
		// calculate a value higher, lower, left, and right of pin's lon abs(180)/lat abs(90)
		// -180, -90, 180, 90 are default values if no bbox specified
		// Udacity example: pin contains 48.85 lat/2.29 lon
		// Result: 1.29, 47.85, 3.29, 49.85
		
		let pinLonLat = (lon: pin.longitude, lat: pin.latitude)
		
		let bbox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)
		bbox.bottomLeftLon = pinLonLat.lon - Constants.Flickr.SearchBBoxHalfHeight
		bbox.bottomLeftLat = pinLonLat.lat - Constants.Flickr.SearchBBoxHalfWidth
		bbox.topRightLon = pinLonLat.lon + Constants.Flickr.SearchBBoxHalfHeight
		bbox.topRightLat = pinLonLat.lat + Constants.Flickr.SearchBBoxHalfWidth
		
		let validatedBBox = validateBBox(bbox)
		
		let resultString = "\(validatedBBox.bottomLeftLon),\(validatedBBox.bottomLeftLat),\(validatedBBox.topRightLon),\(validatedBBox.topRightLat)"
		
		return resultString
	}

	private func validateBBox(bbox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)) ->
		(bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double) {
		
		let newBBox: (bottomLeftLon: Double, bottomLeftLat: Double, topRightLon: Double, topRightLat: Double)
		newBBox.bottomLeftLon = max(Constants.Flickr.SearchLonRange.0, bbox.bottomLeftLon)
		newBBox.bottomLeftLat = max(Constants.Flickr.SearchLatRange.0, bbox.bottomLeftLat)
		newBBox.topRightLon = min(Constants.Flickr.SearchLonRange.1, bbox.topRightLon)
		newBBox.topRightLat = min(Constants.Flickr.SearchLatRange.1, bbox.topRightLat)
		
		return newBBox
	}
	
	
	// MARK: Flickr API Call
	
	private func displayImageFromFlickrBySearch(methodParameters: [String: AnyObject]) {
		
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
			
			guard let status = parsedData[Constants.FlickrResponseKeys.Status] as? String
				where status == Constants.FlickrResponseValues.OKStatus else {
					
					displayError("Flickr API returned an error. Details follow:\n\(parsedData)")
					return
			}
			
			guard let photosDictionary = parsedData[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] else {
				displayError("Cannot find key \(Constants.FlickrResponseKeys.Photos) in \(parsedData)")
				return
			}
			
			guard let numPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
				displayError("Cannot find key \(Constants.FlickrResponseKeys.Pages) in \(parsedData)")
				return
			}
			
			let randomPageNumber = Int(arc4random_uniform(UInt32(numPages)))
			print("random page number: \(randomPageNumber) of \(numPages) total pages")
			
			print("***** PHOTOS DICTIONARY, \(numPages) pages, random page chosen: \(randomPageNumber) *****\n\(photosDictionary)")
			
			self.displayImageFromFlickrBySearch(methodParameters, withPageNumber: randomPageNumber)
		}
		
		task.resume()
	}
	
	
	private func displayImageFromFlickrBySearch(methodParameters: [String:AnyObject], withPageNumber page: Int) {
		
		// 'var' parameters (used in Udacity course) are deprecated in Swift 2.2, to be removed in Swift 3.0
		// as a result, we need a "shadow" variable that can be changed later to add the page number
		var newMethodParameters = methodParameters
		
		// now we can add the desired page number
		newMethodParameters[Constants.FlickrParameterKeys.Page] = page
		
		// and continue...
		print("PAGE:\n\(flickrURLFromParameters(newMethodParameters))")
		
		// TODO: Make request to Flickr!
		let requestURL = flickrURLFromParameters(newMethodParameters)
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
			
			guard let status = parsedData[Constants.FlickrResponseKeys.Status] as? String
				where status == Constants.FlickrResponseValues.OKStatus else {
					
					displayError("Flickr API returned an error. Details follow:\n\(parsedData)")
					return
			}
			
			guard let photosDictionary = parsedData[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject],
				photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
					
					displayError("Cannot find keys \(Constants.FlickrResponseKeys.Photos) and \(Constants.FlickrResponseKeys.Photo) in \(parsedData)")
					return
			}
			
			print("***** photoArray.count: \(photoArray.count) *****")
			if photoArray.count == 0 {
				
				return
			}
			
			let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
			let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
			
			guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String,
				photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String else {
					
					displayError("Cannot find keys \(Constants.FlickrResponseKeys.MediumURL) and \(Constants.FlickrResponseKeys.Title) in \(photosDictionary)")
					return
			}
			
			// retrieve the image data from the web
			let imageURL = NSURL(string: imageURLString)
			guard let imageData = NSData(contentsOfURL: imageURL!) else {
				displayError("Unable to display image data from \(imageURL)!")
				return
			}
			
		}
		
		task.resume()
	}

	private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
		
		let components = NSURLComponents()
		components.scheme = Constants.Flickr.APIScheme
		components.host = Constants.Flickr.APIHost
		components.path = Constants.Flickr.APIPath
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
