import Foundation

struct Player: Codable {
    let name: String
    var currentRoom: String
    var inventory: [String]
}
