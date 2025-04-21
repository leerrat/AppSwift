import Foundation

struct DialogueOption: Codable {
    let texte: String
    let reponse: String
    let condition: String?
    let action: String? 
}

struct Character: Codable {
    let id: String
    let name: String
    let message: String
    let options: [DialogueOption]
}

