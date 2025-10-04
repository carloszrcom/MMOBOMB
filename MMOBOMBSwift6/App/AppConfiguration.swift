//
//  AppConfiguration.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Configuración central de la aplicación
/// Contiene constantes y URLs utilizadas en toda la app
enum AppConfiguration {
    
    // MARK: - API Configuration
    
    /// URL base de la API de MMOBomb
    static let baseURL = "https://www.mmobomb.com/api1"
    
    /// Endpoint para obtener el listado de juegos
    static let gamesEndpoint = "/games"
    
    /// Endpoint para obtener detalles de un juego
    static let gameDetailEndpoint = "/game"
    
    // MARK: - Cache Configuration
    
    /// Tiempo de expiración del cache en segundos (24 horas)
    static let cacheExpirationTime: TimeInterval = 86400
    
    // MARK: - UI Configuration
    
    /// Número de columnas para el grid en iPad
    static let gridColumnsIPad = 3
    
    /// Número de columnas para el grid en iPhone
    static let gridColumnsIPhone = 2
}
