//
//  PlistFriendStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/12/21.
//

import UIKit


class PlistFriendStore {
    
    private var friends : [FriendPlist] = []
    
    func addFriend(_ person: FriendPlist){
        friends.append(person)
    }
    
    func deleteFriend(uid: String) {
        guard let index = self.friends.firstIndex(where: {$0.uid == uid}) else { return }
        self.friends.remove(at: index)
    }
    
    func updateFriend(_ person: FriendPlist){
        guard let index = self.friends.firstIndex(where: {$0.uid == person.uid}) else {return}
        friends[index] = person
    }
    func contains(_ person:FriendPlist) -> Bool{
        return self.friends.firstIndex(where: {$0.uid == person.uid}) != nil
    }
    
    func getAll() -> [FriendPlist] {
        return self.friends
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
    
    @discardableResult func loadData()-> Result<[FriendPlist], Error>{
        do {
            let data        = try Data(contentsOf: itemArchiveURL)
            let unarchiver  = PropertyListDecoder()
            let persons     = try unarchiver.decode([FriendPlist].self, from: data)
            self.friends    = persons
            
            return .success(persons)
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

    
}

