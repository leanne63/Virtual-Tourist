//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by leanne on 8/9/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import Foundation

struct FlickrConstants {
	
	// MARK: Network
	struct Network {
		// NSURL will take non-URL, and SCNetworkReachability doesn't actually access URL,
		//	so using plain text to test for network availability (since we don't know the
		//	actual URL/host used by CLGeocoder)
		static let FakeURLForAccessTest = "fakeURLforAccessTest"
		static let NoAccessMessage = "Network Unavailable"
	}
	
	// MARK: Flickr
	struct API {
		static let Scheme = "https"
		static let Host = "api.flickr.com"
		static let Path = "/services/rest"
		
		static let SearchBBoxHalfWidth = 1.0
		static let SearchBBoxHalfHeight = 1.0
		static let SearchLatRange = (-90.0, 90.0)
		static let SearchLonRange = (-180.0, 180.0)
	}
	
	// MARK: Flickr Notification Keys
	struct NotificationKeys {
		static let MessageKey = "Message"
		static let RequestURLKey = "RequestURL"
		
		static let NumPhotosToBeSavedKey = "NumPhotosToBeSaved"
		
		static let PhotoRetrievalDidFailNotification = "PhotoRetrievalDidFailNotification"
		static let PhotosWillSaveNotification = "PhotosWillSaveNotification"
	}
	
	// MARK: Flickr Parameter Keys
	struct ParameterKeys {
		static let Method = "method"
		static let APIKey = "api_key"
		static let GalleryID = "gallery_id"
		static let Extras = "extras"
		static let Format = "format"
		static let NoJSONCallback = "nojsoncallback"
		static let SafeSearch = "safe_search"
		static let Text = "text"
		static let BoundingBox = "bbox"
		static let Page = "page"
		static let PerPage = "per_page"
		static let MinDateUploaded = "min_date_uploaded"
	}
	
	// MARK: Flickr Parameter Values
	struct ParameterValues {
		static let SearchMethod = "flickr.photos.search"
		static let APIKey = "2742af0d60792bd8e65585339744f8b5"
		static let ResponseFormat = "json"
		static let DisableJSONCallback = "1" /* 1 means "yes" */
		static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
		static let GalleryID = "5704-72157622566655097"
		static let MediumURL = "url_m"
		static let UseSafeSearch = "1"
		static let NumPerPage = "10"
		static let MinUploadDate = "2014/01/01"
	}
	
	// MARK: Flickr Response Keys
	struct ResponseKeys {
		static let Status = "stat"
		static let Photos = "photos"
		static let Photo = "photo"
		static let Title = "title"
		static let MediumURL = "url_m"
		static let Pages = "pages"
		static let Total = "total"
	}
	
	// MARK: Flickr Response Values
	struct ResponseValues {
		static let OKStatus = "ok"
	}
}
