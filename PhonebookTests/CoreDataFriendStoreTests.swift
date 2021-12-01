//
//  FriendStoreTests.swift
//  PhonebookTests
//
//  Created by Nil Nguyen on 9/17/21.
//

import XCTest

@testable import Phonebook
class CoreDataFriendStoreTests: XCTestCase {

    var sut : CoreDataFriendStore!
    
    override func setUpWithError() throws {
        sut = CoreDataFriendStore(inMemory: true)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func addStubData(_ newFriend: Friend) {
        // Given New Friend
        XCTAssertEqual(sut.getAll().count, 0)        // intial state: empty
        XCTAssertFalse(sut.contains(id: newFriend.uid)) // this friend doesn't exist before
        
        // When
        expectation(
           forNotification: .NSManagedObjectContextDidSave,
            object: sut.getContext()) { _ in
             return true
         }
        
        sut.addFriend(newFriend) // async here
        
        waitForExpectations(timeout: 2.0) { error in
          XCTAssertNil(error, "Save did not occur")
        }
        
        // Then
        let addedFriend : Friend? = sut.getFriend(id: newFriend.uid)
        XCTAssertNotNil(addedFriend)
        
    }
    
    func testAdd() throws {
        // Given New Friend
        var newFriend = Friend()
        newFriend.firstName = "Ngan"
        newFriend.lastName = "Nguyen"
        newFriend.phoneNumbers.append("1234567")
        
        addStubData(newFriend)
    }
    
    func testUpdate() throws {
        // Given
        var friendToUpdate = Friend(firstName: "Update", lastName: "Test", phoneNumbers: ["1452"])
        addStubData(friendToUpdate)
        
        // When
        friendToUpdate.lastName = "Now"
        sut.updateFriend(friendToUpdate)
        
        // Then
        let updatedFriend : Friend? = sut.getFriend(id: friendToUpdate.uid)
         XCTAssertEqual(updatedFriend, friendToUpdate)
        
        
    }

    func testDelete() throws {
        // Given
        let friendToDelete = Friend(firstName: "Delete", lastName: "Test", phoneNumbers: ["1452"])
        addStubData(friendToDelete)
        
        // When
        sut.deleteFriend(id: friendToDelete.uid)
        
        // Then
        let deletedFriend : Friend? = sut.getFriend(id: friendToDelete.uid)
         XCTAssertNil(deletedFriend)
  
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
