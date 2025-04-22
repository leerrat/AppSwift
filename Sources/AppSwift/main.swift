import Foundation

print("🎮 Jeu d'Aventure Textuel")
print("1. Nouvelle partie")
print("2. Continuer la partie sauvegardée")
print("Choix : ", terminator: "")

if let choix = readLine(), choix == "2" {
    let savePath = FileManager.default.currentDirectoryPath + "/ressources/save.json"
    let url = URL(fileURLWithPath: savePath)
    do {
        let data = try Data(contentsOf: url)
        let joueurSauvegarde = try JSONDecoder().decode(Player.self, from: data)
        let game = Game(joueur: joueurSauvegarde)
        game.start()
    } catch {
        print("Impossible de charger la sauvegarde. Démarrage d'une nouvelle partie.")
        print("Entrez votre nom : ", terminator: "")
        if let name = readLine(), !name.isEmpty {
            let game = Game(playerName: name)
            game.start()
        }
    }
} else {
    print("Entrez votre nom : ", terminator: "")
    if let name = readLine(), !name.isEmpty {
        let game = Game(playerName: name)
        game.start()
    }
}
