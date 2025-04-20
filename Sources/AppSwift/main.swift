import Foundation

print("🎮 Jeu d'Aventure Textuel")
print("Entrez votre nom :")

if let name = readLine(), !name.isEmpty {
    let game = Game(playerName: name)
    game.start()
} else {
    print("Nom invalide. Fermeture du jeu.")
}

