//
//  Virtual_TouristTests.swift
//  Virtual TouristTests
//
//  Created by leanne on 7/21/16.
//  Copyright © 2016 leanne63. All rights reserved.
//

import XCTest
import MapKit
import CoreData
@testable import Virtual_Tourist

class Virtual_TouristTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
	
	// MARK: - Operator Overloads -
	
	// MARK: CLLocationCoordinate2D Equatable Operator Overloads
	
	/// Two CLLocationCoordinate2D values should be equal if they match to 6 (rounded) decimal places
	func testEqualityOperatorOverload() {
		
		var firstCoord = CLLocationCoordinate2DMake(Double(30), Double(-90))
		var secondCoord = CLLocationCoordinate2DMake(Double(30), Double(-90))
		XCTAssertTrue(firstCoord == secondCoord, "firstCoord and secondCoord should've matched")
		
		firstCoord = CLLocationCoordinate2DMake(30.1234562, -90.1234562)
		secondCoord = CLLocationCoordinate2DMake(30.1234564, -90.1234564)
		XCTAssertTrue(firstCoord == secondCoord, "firstCoord and secondCoord should've matched")
		
		
		firstCoord = CLLocationCoordinate2DMake(30.3, -90.3)
		secondCoord = CLLocationCoordinate2DMake(30.5, -90.5)
		XCTAssertFalse(firstCoord == secondCoord, "firstCoord and secondCoord should not have matched")
		
		firstCoord = CLLocationCoordinate2DMake(30.1234562, -90.1234562)
		secondCoord = CLLocationCoordinate2DMake(30.1234566, -90.1234566)
		XCTAssertFalse(firstCoord == secondCoord, "firstCoord and secondCoord should not have matched")
	}
    
	/// Two CLLocationCoordinate2D values should only be equal if they match to 6 (rounded) decimal places
	func testInequalityOperatorOverload() {
		
		var firstCoord = CLLocationCoordinate2DMake(Double(30), Double(-90))
		var secondCoord = CLLocationCoordinate2DMake(Double(30), Double(-90))
		XCTAssertFalse(firstCoord != secondCoord, "firstCoord and secondCoord should not have matched")
		
		firstCoord = CLLocationCoordinate2DMake(30.1234562, -90.1234562)
		secondCoord = CLLocationCoordinate2DMake(30.1234564, -90.1234564)
		XCTAssertFalse(firstCoord != secondCoord, "firstCoord and secondCoord should not have matched")
		
		
		firstCoord = CLLocationCoordinate2DMake(30.3, -90.3)
		secondCoord = CLLocationCoordinate2DMake(30.5, -90.5)
		XCTAssertTrue(firstCoord != secondCoord, "firstCoord and secondCoord should've matched")
		
		firstCoord = CLLocationCoordinate2DMake(30.1234562, -90.1234562)
		secondCoord = CLLocationCoordinate2DMake(30.1234566, -90.1234566)
		XCTAssertTrue(firstCoord != secondCoord, "firstCoord and secondCoord should've matched")
	}
	
	
	// MARK: Pin Compound Addition Operator Overload (+=)
	
	/// Adding a CLLocationCoordinate2D to a Pin should set the Pin's Lat/Lon properties accordingly
	func testAdditionOperatorOverload() {
		
		guard let entityForPin = NSEntityDescription.entityForName("Pin",
		                                                           inManagedObjectContext: CoreDataStack.shared.mainManagedObjectContext) else {
			XCTFail("Entity doesn't exist for Pin!")
			return
		}
		var pin = Pin(entity: entityForPin, insertIntoManagedObjectContext: nil)
		
		let coord2D = CLLocationCoordinate2DMake(30.1234562, -90.1234562)
		pin += coord2D
		
		let compareResult = (pin.latitude == coord2D.latitude) && (pin.longitude == coord2D.longitude)
		XCTAssertTrue(compareResult)
	}
	
}
