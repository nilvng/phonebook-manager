//
//  FriendPlist.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/10/21.
//

import Foundation
struct FriendPlist {
    var uid : String
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]

}


extension FriendPlist : Codable{

    enum CodingKeys : String, CodingKey {
        case uid
        case firstName
        case lastName
        case phoneNumbers
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(uid, forKey: .uid)
        try container.encode(phoneNumbers, forKey: .phoneNumbers)
    }
}

