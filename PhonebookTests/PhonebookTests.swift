//
//  PhonebookTests.swift
//  PhonebookTests
//
//  Created by Nil Nguyen on 8/24/21.
//

import XCTest
@testable import Phonebook

class PhonebookTests: XCTestCase {
    
//    var sut : PhonebookManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        //sut = PhonebookManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
