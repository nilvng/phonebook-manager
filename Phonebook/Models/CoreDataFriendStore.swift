//
//  CoreDataFriendStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/12/21.
//

import CoreData


class CoreDataFriendStore {
    
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
    
    func getContext() -> NSManagedObjectContext {
       // return persistentContainer.newBackgroundContext()
        return persistentContainer.viewContext
    }
    // MARK: APIs
    func loadData(completion: @escaping (Result<[FriendCoreData], Error>) -> Void) {
        let  context = getContext()
        let request : NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        context.performAndWait {
            do {
                let allFriends = try context.fetch(request)
                completion(.success(allFriends))
            } catch (let err){
                print("Failed to load data from Core Data database: \(err)")
                completion(.failure(FetchError.failed))
            }
        }
    }

    @objc func saveChanges(completion: @escaping (Bool) ->Void) {
        print("Save changes to Core Data manually: hanging...")
        completion(false)
    }
    func addFriend(_ person : FriendCoreData){
        do {
            try persistentContainer.viewContext.save()
        } catch (let err){
            print("Error in adding contact: \(err)")
        }
    }
    func deleteFriend(_ person: FriendCoreData){
        guard let id =  person.uid else {
            return
        }
        let context = getContext()
        let fetchRequest: NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "uid == \(id)")

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
    func updateFriend(_ person: FriendCoreData){
        do {
            try persistentContainer.viewContext.save()
        } catch (let err){
            print("Error in updating contact: \(err)")
        }
    }
    
    func getAll() -> [FriendCoreData]{
        var friends : [FriendCoreData]!
        self.loadData { res in
            switch res {
            case .success(let cdfriends):
                friends = cdfriends
            default:
                friends = [] // hanging: return empty list if cannot fetch data
                }
            }
        return friends
    }
}

