//
//  PersonStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/24/21.
//

import UIKit
import Contacts
import CoreData

protocol FriendStore {
    @discardableResult func addFriend(_ person : Friend) -> Friend
    func deleteFriend(_ person: Friend)
    func updateFriend(_ person: Friend)
    func contains(_ person:Friend) -> Bool
    func get(key: String) -> Friend?
    func getAll() -> [Friend]
    func saveChanges(completion: @escaping (Bool) ->Void)
    func loadData()-> Result<[Friend], Error>
}

class PlistFriendStore: FriendStore {
    private var friends : [FriendPlist] = []
    func addFriend(_ person: Friend) -> Friend{
        friends.append(self.convertToPlistFriend(friend: person))
        return person
    }
    
    func deleteFriend(_ person: Friend) {
        guard let index = self.friends.firstIndex(where: {$0.uid == person.uid}) else { return }
        self.friends.remove(at: index)
    }
    
    func updateFriend(_ person: Friend){
        guard let index = self.friends.firstIndex(where: {$0.uid == person.uid}) else {return}
        let plistf = self.convertToPlistFriend(friend: person)
        friends[index] = plistf
    }
    func contains(_ person:Friend) -> Bool{
        return self.friends.firstIndex(where: {$0.uid == person.uid}) != nil
    }
    func get(key: String) -> Friend?{
        fatalError()
    }
    
    func getAll() -> [Friend] {
        return self.convertToFriendList()
    }
    
    let itemArchiveURL : URL = {
        
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentDirectories.first!
        
        return documentDirectory.appendingPathComponent("contacts2.plist")
    }()

        
    @objc func saveChanges(completion: @escaping (Bool) ->Void) {
        print("Saving items to: \(itemArchiveURL)")
        do{
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(friends)
            try data.write(to: itemArchiveURL)
            print("Saved all items")
            completion(true)
        } catch let encodingError{
            print("Error encoding items: \(encodingError)")
            completion(false)
        }
    }
    
    @discardableResult func loadData()-> Result<[Friend], Error>{
        do {
            let data        = try Data(contentsOf: itemArchiveURL)
            let unarchiver  = PropertyListDecoder()
            let persons     = try unarchiver.decode([FriendPlist].self, from: data)
            self.friends    = persons
            
            let universalTypeFriends : [Friend] = self.convertToFriendList()
            return .success(universalTypeFriends)
        } catch let error {
            print("Error reading in save file: \(error)")
            return .failure(FetchError.failed)
        }
}
    init() {
        self.loadData()
        // auto save the list of items whenever users turn off the app
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector:#selector(saveChanges),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func convertToFriendList() -> [Friend] {
        let friendList : [Friend] =  self.friends.compactMap {f in
            let friend = Friend()
            friend.firstName = f.firstName
            friend.lastName = f.lastName
            friend.phoneNumbers = f.phoneNumbers
            friend.uid = f.uid
            return friend
        }
        return friendList
    }
    
    func convertToFriend(plistFriend f : FriendPlist) -> Friend {
            let friend = Friend()
            friend.firstName = f.firstName
            friend.lastName = f.lastName
            friend.phoneNumbers = f.phoneNumbers
            friend.uid = f.uid
            return friend
        }
    
    func convertToPlistFriend(friend f : Friend) -> FriendPlist {
        let friend = FriendPlist(uid: f.uid, firstName: f.firstName, lastName: f.lastName, phoneNumbers: f.phoneNumbers)
            return friend
        }


    
}


class CoreDataFriendStore: FriendStore {
    
    // MARK: Properties
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Phonebook")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private func getContext() -> NSManagedObjectContext {
       // return persistentContainer.newBackgroundContext()
        return persistentContainer.viewContext
    }
    // MARK: APIs
    func loadData()-> Result<[Friend], Error> {
        let  context = getContext()
        let request : NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        var universalTypeFriends : [Friend] = []
        context.performAndWait {
            do {
                let allFriends = try context.fetch(request)
                universalTypeFriends = allFriends.compactMap {f in
                    let friend = Friend()
                    friend.firstName    = f.firstName ?? ""
                    friend.lastName     = f.lastName ?? ""
                    friend.phoneNumbers = f.phoneNumbers ?? [""]
                    friend.uid          = f.uid ?? UUID().uuidString
                    print("Load from Core Data: \(friend)")
                    return friend
                }

            } catch (let err){
                print("Failed to load data from Core Data database: \(err)")
            }
        }
        return .success(universalTypeFriends)
    }

    @objc func saveChanges(completion: @escaping (Bool) ->Void) {
        print("Save changes to Core Data manually: hanging...")
        completion(false)
    }
    @discardableResult func addFriend(_ person : Friend) -> Friend{
        let context =  getContext()
        var friend : FriendCoreData!
        context.performAndWait {
        friend = FriendCoreData(context: context)
        friend.firstName = person.firstName
        friend.lastName = person.lastName
        friend.phoneNumbers = person.phoneNumbers
        friend.uid = person.uid
        }
        do {
            try persistentContainer.viewContext.save()
        } catch (let err){
            print("Error in adding contact: \(err)")
        }
        return person
    }
    func deleteFriend(_ person: Friend){
        let context = getContext()
        let fetchRequest: NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "uid == %@",person.uid)

        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
            try context.save()
        } catch (let err) {
            print("Error in adding contact: \(err)")
        }
    }
    func updateFriend(_ person: Friend){
        let context =  getContext()
        var friend : FriendCoreData!
        context.performAndWait {
        friend = FriendCoreData(context: context)
        friend.firstName = person.firstName
        friend.lastName = person.lastName
        friend.phoneNumbers = person.phoneNumbers
        friend.uid = person.uid
        }
        do {
            try persistentContainer.viewContext.save()
        } catch (let err){
            print("Error in updating contact: \(err)")
        }
    }
    func contains(_ person: Friend) -> Bool {
        fatalError()
    }
    
    func get(key: String) -> Friend? {
        fatalError()
    }
    
    func getAll() -> [Friend]{
        let res = self.loadData()
        switch res {
        case .success(let friends):
            return friends
        default:
            return [] // hanging: return empty list if cannot fetch data
        }
    }
}
