//
//  Game.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Modelo de dominio para un juego
/// Representa un juego en la lógica de negocio de la app
/// Es inmutable (struct) para garantizar thread-safety
struct Game: Identifiable, Hashable {
    let id: Int
    let title: String
    let thumbnail: String
    let shortDescription: String
    let gameUrl: String
    let genre: String
    let platform: String
    let publisher: String
    let developer: String
    let releaseDate: Date?
    let profileUrl: String
    
    // MARK: - Computed Properties
    
    /// Fecha formateada para mostrar al usuario
    var releaseDateFormatted: String {
        guard let date = releaseDate else {
            return "Fecha desconocida"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}
