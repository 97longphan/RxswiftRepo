//
//  PokemonModel.swift
//  TestFramework
//
//  Created by ps1.longph on 30/11/2021.
//

import Foundation

struct PokemonModel: Codable {
    var name: String
    var url: String
    var avatar: String?
}

struct PokemonListModel: Codable {
    var count: Int?
    var next: String?
    var previous: String?
    var results: [PokemonModel] = []
}
