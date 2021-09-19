//
//  PhonebookUITests.swift
//  PhonebookUITests
//
//  Created by Nil Nguyen on 8/24/21.
//

import XCTest

class PhonebookUITests: XCTestCase {
    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()

        // Since UI tests are more expensive to run, it's usually a good idea
        // to exit if a failure was encountered
        continueAfterFailure = false

    }
    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.isDisplayingFriendsView)
    }

    func testAddNewContact() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Given
        // number cell before add new contact
        let friendsTable = app.tables["table-FriendsView"]
        let totalCell = friendsTable.cells.count
                
        // When
        let homeNavigationBar = app.navigationBars["Phonebook"]
        homeNavigationBar.buttons["Add"].tap()
        ///navigate to detail view
        let tablesQuery = app.tables["table-EditView"]
        
        let fnameField = tablesQuery.textFields["edit-First name"]
        fnameField.tap()
        fnameField.typeText("UI")

        let lastNameTextField = tablesQuery.cells.textFields["edit-Last name"]
        lastNameTextField.tap()
        lastNameTextField.typeText("Test")

        let phoneNumberTextField = tablesQuery.cells.textFields["edit-Phone number"]
        phoneNumberTextField.tap()
        phoneNumberTextField.typeText("1234567")
        
        app.navigationBars["New Contact"].buttons["Done"].tap()
        
        // Then
        let totalCellAfter = friendsTable.cells.count
        XCTAssertEqual(totalCellAfter, totalCell + 1)
    }
    
    func testDeletingContact() throws {
        let app = XCUIApplication()
        app.launch()
        
        let friendsTable = app.tables["table-FriendsView"]
        let totalCell = friendsTable.cells.count
        if totalCell > 0{
            // navigate to detail view
            let cell = friendsTable.cells.element(boundBy: 0)
            cell.tap()
            // enable editing mode
            app.navigationBars["View Contact"].buttons["Edit"].tap()
            // When
            app.tables["table-EditView"].buttons["Delete"].tap()
            
            //Then
            XCTAssertEqual(friendsTable.cells.count, totalCell - 1)
            
        }
                                                
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIApplication {
    var isDisplayingFriendsView: Bool {
        return otherElements["FriendsView"].exists
    }
}
