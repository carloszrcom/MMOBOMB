//
//  GameDetail.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Modelo de dominio para los detalles completos de un juego
/// Extiende la información básica con descripciones, requisitos y screenshots
struct GameDetail: Identifiable, Hashable {
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
    let releaseDate: Date?
    let profileUrl: String
    let minimumSystemRequirements: SystemRequirements?
    let screenshots: [Screenshot]
    
    // MARK: - Computed Properties
    
    /// Descripción HTML limpia (sin etiquetas)
    var cleanDescription: String {
        // Removemos las etiquetas HTML básicas para mostrar texto limpio
        description
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\r\\n", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Indica si el juego está activo
    var isLive: Bool {
        status.lowercased() == "live"
    }
}
