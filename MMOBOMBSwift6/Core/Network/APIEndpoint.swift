//
//  APIEndpoint.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Define los diferentes endpoints de la API
/// Facilita la construcción de URLs y mantiene centralizada la configuración
enum APIEndpoint {
    case gamesList
    case gameDetail(id: Int)
    
    /// Construye la URL completa del endpoint
    var url: URL? {
        switch self {
        case .gamesList:
            // URL para obtener el listado completo de juegos
            return URL(string: "\(AppConfiguration.baseURL)\(AppConfiguration.gamesEndpoint)")
            
        case .gameDetail(let id):
            // URL para obtener detalles de un juego específico
            // Añade el parámetro id como query parameter
            return URL(string: "\(AppConfiguration.baseURL)\(AppConfiguration.gameDetailEndpoint)?id=\(id)")
        }
    }
}
