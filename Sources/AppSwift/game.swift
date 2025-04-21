import Foundation

class Game {
    var player: Player
    var characters: [String: Character] = [:]
    var rooms: [String: Room] = [:]

    init(playerName: String) {
        self.player = Player(name: playerName, currentRoom: "start", inventory: [])
        loadWorld()
    }

    init(joueur: Player) {
    self.player = joueur
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
        let charPath = FileManager.default.currentDirectoryPath + "/ressources/character.json"
        let charURL = URL(fileURLWithPath: charPath)
        do {
            let charData = try Data(contentsOf: charURL)
            characters = try JSONDecoder().decode([String: Character].self, from: charData)
        } catch {
            print("Erreur chargement personnages : \(error)")
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

    print("\n\(room.name)")
    print(room.description)

    if !room.items.isEmpty {
        print("Objets ici : \(room.items.joined(separator: ", "))")
    }
    if !room.exits.isEmpty {
        print("Sorties : \(room.exits.keys.joined(separator: ", "))")
    }
    if let characterIDs = room.characters, !characterIDs.isEmpty {
        let noms = characterIDs.compactMap { characters[$0]?.name }
        if !noms.isEmpty {
            print("Personnage présent : \(noms.joined(separator: ", "))")
        }
    }

    checkSpecialEvents(for: player.currentRoom)
    }

    func checkSpecialEvents(for roomID: String) {
        switch roomID {
        case "bibliotheque":
            eventBibliotheque()
        case "cave":
            eventCave()
        default:
            break
        }
    }

    func eventBibliotheque() {
        guard let room = rooms["bibliotheque"] else { return }

        if !room.exits.keys.contains("sud") {
            if player.inventory.contains(where: { $0.lowercased() == "clef" }) {
                print("\nUne trappe verrouillée est au sol.")
                print("Utiliser la clef ? (oui/non)")

                if let choice = readLine()?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), choice == "oui" {
                    rooms["bibliotheque"]?.exits["sud"] = "cave"
                    print(" Tu as utilisé la clef. Une trappe s’ouvre vers le sud.")
                } else {
                    print("Tu choisis de ne pas utiliser la clef.")
                }
            } else {
                print("\nUne trappe verrouillée est au sol. Il te manque une clef pour l’ouvrir.")
            }
        }
    }

    func eventCave() {
        print("Un vieux coffre couvert de poussière trône au centre de la pièce... ")
    }

    func handlePNJDialogue(pnj: Character, choix: Int) {
    let option = pnj.options[choix - 1]
    if let condition = option.condition?.lowercased() {
        if !player.inventory.contains(where: { $0.lowercased() == condition }) {
            print("Tu n’as pas l’objet requis : \(condition).")
            return
        }
    }
    if let action = option.action {
        let parts = action.split(separator: ":")
        if parts.count == 2 {
            let type = parts[0]
            let item = String(parts[1])

            if type == "retirer" {
                if let index = player.inventory.firstIndex(where: { $0.lowercased() == item.lowercased() }) {
                    player.inventory.remove(at: index)
                    print("Tu as donné \(item).")
                }
            }
        }
    }
    print("\(pnj.name) : « \(option.reponse) »")
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

    
    if let personnages = room.characters {
    if let found = personnages.first(where: { $0.lowercased() == trimmedInput }),
       let pnj = characters[found] {
        
        print("\(pnj.name) : « \(pnj.message) »")
        print("\nQue veux-tu lui dire ?")
        
        for (index, option) in pnj.options.enumerated() {
            print("\(index + 1) - \(option.texte)")
        }
        print("> ", terminator: "")
        
        if let choix = readLine(), let index = Int(choix), index > 0, index <= pnj.options.count {
            handlePNJDialogue(pnj: pnj, choix: index)
        } else {
            print("Commande invalide.")
        }
        return
    }
    }

    switch trimmedInput {
    case "inventaire":
        let inv = player.inventory
        print("Inventaire : \(inv.isEmpty ? "vide" : inv.joined(separator: ", "))")
    case "aide", "?":
        print("Commandes valides : [direction], [objet], [pnj], inventaire, carte, aide, quitter")
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
            let pickedItem = room.items[index]
            room.items.remove(at: index)
            rooms[player.currentRoom] = room
            player.inventory.append(pickedItem)
            print("\(pickedItem) ajouté à ton inventaire.")
        } else {
            print("Cet objet n'est pas ici.")
        }
    }

    func saveProgress() {
        let savePath = FileManager.default.currentDirectoryPath + "/ressources/save.json"
        do {
            let data = try JSONEncoder().encode(player)
            try data.write(to: URL(fileURLWithPath: savePath))
        } catch {
            print("Erreur de sauvegarde : \(error)")
        }
    }

    

}
