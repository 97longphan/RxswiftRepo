import Foundation

struct PokemonDetailModel: Decodable {
    var height: Int?
    var id: Int?
    var name: String?
    var sprites: PokemonSprites?
}

struct PokemonSprites: Decodable {
    var back_default: String?
    var front_default: String?
    var front_shiny: String?
}
