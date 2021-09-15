//
//  PhonebookTests.swift
//  PhonebookTests
//
//  Created by Nil Nguyen on 8/24/21.
//

import XCTest
@testable import Phonebook

class PhonebookTests: XCTestCase {
    
    var sut : PhonebookManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = PhonebookManager.shared
        sut.friendStore = CoreDataFriendStoreAdapter(adaptee: CoreDataStoreTest())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        sut = nil
        try super.tearDownWithError()
        sut = nil
    }

    func testCreateContact() throws {
        // Given
        let store = sut.friendStore
        let queue = sut.friendsQueue
        
        var newFriend = Friend()
        newFriend.firstName = "Ngan"
        newFriend.lastName = "Nguyen"
        newFriend.phoneNumbers.append("1234567")
        
        /// intial state: empty
        XCTAssertEqual(sut.getAll().count, 0)
        
        // When
        sut.add(newFriend) // async here
        
        queue.sync {
            print("hi")
        }
        // Then
        /// successfully add in memory list
        XCTAssertEqual(sut.get(key: newFriend.uid), newFriend)
        /// successfully add to Core Data
        XCTAssertEqual(store?.gets(id: newFriend.uid), newFriend)
        /// successfully add to native Contacts
        
    }
    
    
    func testDeleteContact() throws {
        // Given
        let store = sut.friendStore
        let queue = sut.friendsQueue
        
        var friendToDelete = Friend()
        friendToDelete.firstName = "Ngan"
        friendToDelete.lastName = "Nguyen"
        friendToDelete.phoneNumbers.append("1234567")
        
        sut.add(friendToDelete)
        
        /// confirm that this friend exists
        XCTAssertEqual(sut.get(key: friendToDelete.uid), friendToDelete)

        // When
        sut.delete(friendToDelete, at: -1) // warning missing index
        
        queue.sync {
            print("hi")
        }
        // Then
        /// successfully delete in memory list
        XCTAssertEqual(sut.get(key: friendToDelete.uid), nil)
        /// successfully delete in Core Data
        XCTAssertEqual(store?.gets(id: friendToDelete.uid), nil)
        /// successfully add to native Contacts
        
    }

    
    func testUpdateContact() throws {
        // Given
        let store = sut.friendStore
        let queue = sut.friendsQueue
        
        var friendToUpdate = Friend()
        friendToUpdate.firstName = "Ngan"
        friendToUpdate.lastName = "Nguyen"
        friendToUpdate.phoneNumbers.append("1234567")
        
        sut.add(friendToUpdate)
        
        /// confirm that this friend exists
        XCTAssertEqual(sut.get(key: friendToUpdate.uid), friendToUpdate)

        // When
        sut.update(friendToUpdate) // warning missing index
        
        queue.sync {
            print("hi")
        }
        // Then
        /// successfully add in memory list
        XCTAssertEqual(sut.get(key: friendToUpdate.uid), friendToUpdate)
        /// successfully add to Core Data
        XCTAssertEqual(store?.gets(id: friendToUpdate.uid), friendToUpdate)
        /// successfully add to native Contacts
        
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

