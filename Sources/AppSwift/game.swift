import Foundation

class Game {
    var player: Player
    var rooms: [String: Room] = [:]

    init(playerName: String) {
        self.player = Player(name: playerName, currentRoom: "start", inventory: [])
        loadWorld()
    }

    func loadWorld() {
        let path = FileManager.default.currentDirectoryPath + "/ressources/world.json"
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            rooms = try JSONDecoder().decode([String: Room].self, from: data)
        } catch {
            print("Erreur lors du chargement du monde : \(error)")
            exit(1)
        }
    }

    func start() {
        print("\nBienvenue, \(player.name) !\n")
        loop()
    }

    func loop() {
        while true {
            showCurrentRoom()

            print("\n> ", terminator: "")
            guard let input = readLine()?.lowercased() else { continue }
            handleCommand(input)
        }
    }

    func showCurrentRoom() {
        guard let room = rooms[player.currentRoom] else { return }
        print("\n \(room.name)")
        print(room.description)
        if !room.items.isEmpty {
            print("Objets ici : \(room.items.joined(separator: ", "))")
        }
        if !room.exits.isEmpty {
            print("Sorties : \(room.exits.keys.joined(separator: ", "))")
        }
    }

    func handleCommand(_ input: String) {
    let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    guard let room = rooms[player.currentRoom] else {
        print("Erreur : salle inconnue.")
        return
    }
    if room.exits.keys.contains(trimmedInput) {
        move(direction: trimmedInput)
        return
    }
    if let foundItem = room.items.first(where: { $0.lowercased() == trimmedInput }) {
    take(item: foundItem)
    return
    }

    switch trimmedInput {
    case "inventaire":
        let inv = player.inventory
        print("Inventaire : \(inv.isEmpty ? "vide" : inv.joined(separator: ", "))")
    case "aide", "?":
        print("Commandes valides : [nom d’un objet], [direction], inventaire, aide, quitter")
    case "quitter":
        saveProgress()
        print("Progression sauvegardée. À bientôt, \(player.name) !")
        exit(0)
    default:
        print("Commande inconnue. Tape 'aide' pour voir la liste.")
    }
}
    func move(direction: String) {
        guard let currentRoom = rooms[player.currentRoom],
              let nextRoomID = currentRoom.exits[direction] else {
            print("Impossible d'aller dans cette direction.")
            return
        }
        player.currentRoom = nextRoomID
    }

    func take(item: String) {
    guard var room = rooms[player.currentRoom] else {
        print("Erreur interne : salle introuvable.")
        return
    }

    if let index = room.items.firstIndex(where: { $0.lowercased() == item.lowercased() }) {
        let pickedItem = room.items[index] // récupérer la bonne casse réelle
        room.items.remove(at: index)
        rooms[player.currentRoom] = room
        player.inventory.append(pickedItem)
        print("\(pickedItem) ajouté à ton inventaire.")
    } else {
        print("Cet objet n'est pas ici.")
    }
}
    func saveProgress() {
        let savePath = FileManager.default.currentDirectoryPath + "/Resources/save.json"
        do {
            let data = try JSONEncoder().encode(player)
            try data.write(to: URL(fileURLWithPath: savePath))
        } catch {
            print("Erreur de sauvegarde : \(error)")
        }
    }
}
