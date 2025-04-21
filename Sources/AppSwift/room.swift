import Foundation

struct Room: Codable {
    let id: String
    let name: String
    let description: String
    var exits: [String: String]
    var items: [String]
    var characters: [String]?
}
