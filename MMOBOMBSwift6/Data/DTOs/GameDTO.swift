//
//  GameDTO.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Data Transfer Object para el listado de juegos
/// Mapea exactamente la estructura JSON que devuelve la API
/// Usamos Codable para serialización automática
struct GameDTO: Codable, Identifiable {
    let id: Int
    let title: String
    let thumbnail: String
    let shortDescription: String
    let gameUrl: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: String?
    let profileUrl: String
    
    // MARK: - CodingKeys
    
    /// No necesitamos definir CodingKeys porque usamos keyDecodingStrategy
    /// El decoder convertirá automáticamente snake_case a camelCase
}
