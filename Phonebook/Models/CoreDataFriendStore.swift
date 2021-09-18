//
//  CoreDataFriendStore.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/12/21.
//

import CoreData


class CoreDataFriendStore : FriendStore{
        
    // MARK: Properties
    let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        self.persistentContainer = NSPersistentContainer(name: "Phonebook")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            //description.type = NSInMemoryStoreType
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

    }
    
    func getContext() -> NSManagedObjectContext {
        //return persistentContainer.newBackgroundContext()
        return persistentContainer.viewContext
    }
    // MARK: APIs
    func loadData(completion: @escaping (Result<[Friend], Error>) -> Void) {
        let  context = getContext()
        let request : NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        context.performAndWait {
            do {
                let allFriends = try context.fetch(request)
                let universalTypeFriends : [Friend] = allFriends.compactMap {f in
                    var friend = Friend()
                    friend.firstName    = f.firstName ?? ""
                    friend.lastName     = f.lastName ?? ""
                    friend.phoneNumbers = f.phoneNumbers ?? [""]
                    friend.uid          = f.uid ?? UUID().uuidString
                    return friend
                }
                completion(.success(universalTypeFriends))
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
    
    func addFriend(_ person : Friend){
        let context =  getContext()
         var friend : FriendCoreData!
        friend = FriendCoreData(context: context)
        friend.firstName = person.firstName
        friend.lastName = person.lastName
        friend.phoneNumbers = person.phoneNumbers
        friend.uid = person.uid
        do{
            try context.save()
        } catch (let err){
            print("Cannot save to CoreData: \(err)")
        }
    }
    
    func gets(id: String) -> FriendCoreData? {
        /*
         Get one Friend that match given id
         */
        let context = getContext()
        let fetchRequest: NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "\(#keyPath(FriendCoreData.uid)) == %@",id)

        do {
            let objects = try context.fetch(fetchRequest)
            return objects.first
        }catch(let err){
            print("Cannot get Friend:\(err)")
        }
        return nil
    }
    func deleteFriend(id : String){
        let context = getContext()
        do{
            let object = gets(id: id)
            if object == nil {
                print("Friend not exist to delete.")
                return
            }
            context.delete(object!)
            try context.save()
        } catch (let err) {
            print("Error in delete contact: \(err)")
        }
    }
    func updateFriend(_ person: Friend){
        let context = getContext()
        do {
            // get the original item
            let object = gets(id: person.uid)
            // update its detail
            object?.firstName       = person.firstName
            object?.lastName        = person.lastName
            object?.phoneNumbers    = person.phoneNumbers
            
            // save changes
            try context.save()
        } catch (let err){
            print("Error in updating contact: \(err)")
        }
    }
    
    func getAll() -> [Friend]{
        var friends : [Friend]!
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
    
    func getFriend(id: String) -> Friend? {
        let context = getContext()
        let fetchRequest : NSFetchRequest<FriendCoreData> = FriendCoreData.fetchRequest()
        
        let predicate = NSPredicate(format: "\(#keyPath(FriendCoreData.uid)) == %@", id)
        fetchRequest.predicate = predicate
        
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.count > 0 {
                return toFriend(objects.first!)
            } else {
                return nil
            }
        } catch (let err) {
            print("Error:\(err)\nCannot retrieve object from Core Data with this id: \(id)")
            return nil
        }
    }
    
    func contains(id: String) -> Bool {
        return gets(id: id) != nil
    }
    
    func toFriendCoreData(_ person: Friend, completion: @escaping (FriendCoreData) -> Void){
        let context =  getContext()
        context.perform {
        let friend = FriendCoreData(context: context)
        friend.firstName = person.firstName
        friend.lastName = person.lastName
        friend.phoneNumbers = person.phoneNumbers
        friend.uid = person.uid
        completion(friend)
            
        }
    }
    
    func toFriend(_ person: FriendCoreData) -> Friend {
        var friend = Friend()
        friend.uid = person.uid!
        friend.firstName = person.firstName!
        friend.lastName = person.lastName!
        friend.phoneNumbers = person.phoneNumbers!
        return friend
    }
    
    func toFriendList(_ friends: [FriendCoreData]) -> [Friend]{
        return friends.compactMap {f in
            let friend = toFriend(f)
            return friend
        }
    }

}

