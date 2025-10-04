//
//  GameDetailDTO.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Data Transfer Object para los detalles completos de un juego
/// Incluye información adicional como descripción larga, screenshots y requisitos
struct GameDetailDTO: Codable {
    let id: Int
    let title: String
    let thumbnail: String
    let status: String
    let shortDescription: String
    let description: String
    let gameUrl: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: String?
    let profileUrl: String
    let minimumSystemRequirements: SystemRequirementsDTO?
    let screenshots: [ScreenshotDTO]?
}
