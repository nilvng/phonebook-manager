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

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        sut = nil
        try super.tearDownWithError()
        sut = nil
    }

    func testCreateContact() throws {
        // Given
        let store =  CoreDataFriendStore(inMemory: true)
        sut.friendStore = store
    
        var newFriend = Friend()
        newFriend.firstName = "Ngan"
        newFriend.lastName = "Nguyen"
        newFriend.phoneNumbers.append("1234567")
        
        XCTAssertEqual(sut.getAll().count, 0)        // intial state: empty
        XCTAssertFalse(store.contains(id: newFriend.uid)) // this friend doesn't exist before
        
//        // When
//        expectation(
//           forNotification: .NSManagedObjectContextDidSave,
//            object: coreDataStore.getContext()) { _ in
//             return true
//         }
//
        sut.add(newFriend) // async here
//
//        // Then
        /// successfully add in memory list
        XCTAssertEqual(sut.getContact(key: newFriend.uid), newFriend)
        /// successfully add to Core Data
        XCTAssertNotNil(store.getFriend(id: newFriend.uid))
//        /// successfully add to native Contacts
        
    }
    
    
    func testDeleteContact() throws {
        // Given
        let store =  CoreDataFriendStore(inMemory: true)
        sut.friendStore = store
        
        var friendToDelete = Friend()
        friendToDelete.firstName = "Delete"
        friendToDelete.lastName = "Nguyen"
        friendToDelete.phoneNumbers.append("1234567")
        
        sut.add(friendToDelete)
        /// confirm that this friend exists
        XCTAssertEqual(sut.getContact(key: friendToDelete.uid), friendToDelete)

        // When
        sut.delete(friendToDelete, at: 0) // warning missing index

        // Then
        /// successfully delete in memory list
        XCTAssertEqual(sut.getContact(key: friendToDelete.uid), nil)
        /// successfully delete in Core Data
        XCTAssertEqual(store.getFriend(id: friendToDelete.uid), nil)
        /// successfully add to native Contacts
        
    }

    
    func testUpdateContact() throws {
        // Given
        let store =  CoreDataFriendStore(inMemory: true)
        sut.friendStore = store

        var friendToUpdate = Friend()
        friendToUpdate.firstName = "Ngan"
        friendToUpdate.lastName = "Nguyen"
        friendToUpdate.phoneNumbers.append("1234567")
        
        sut.add(friendToUpdate)
        /// confirm that this friend exists
        XCTAssertEqual(sut.getContact(key: friendToUpdate.uid), friendToUpdate)

        // When
        friendToUpdate.firstName = "Updated"
        sut.update(friendToUpdate) // warning missing index

        // Then
        /// successfully delete in memory list
        XCTAssertEqual(sut.getContact(key: friendToUpdate.uid), friendToUpdate)
        /// successfully delete in Core Data
        XCTAssertEqual(store.getFriend(id: friendToUpdate.uid), friendToUpdate)
        /// successfully add to native Contacts
            }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

