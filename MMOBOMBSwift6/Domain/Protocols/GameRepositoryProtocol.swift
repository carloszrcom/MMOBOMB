//
//  GameRepositoryProtocol.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 6/10/25.
//

import Foundation

/// Protocolo que define las operaciones del repositorio de juegos
/// Permite inyectar implementaciones mock para testing
/// Al estar en Domain, no depende de detalles de implementación (Data layer)
/// Sendable para poder ser usado de forma segura en contextos concurrentes
protocol GameRepositoryProtocol: Sendable {
    
    /// Obtiene el listado completo de juegos
    /// Primero intenta desde cache, si no hay o está expirado, obtiene de la API
    /// - Parameter forceRefresh: Si es true, ignora el cache y obtiene datos frescos
    /// - Returns: Array de modelos Game
    /// - Throws: AppError con el tipo específico de error ocurrido
    func fetchGames(forceRefresh: Bool) async throws(AppError) -> [Game]
    
    /// Obtiene los detalles de un juego específico
    /// - Parameters:
    ///   - id: Identificador del juego
    ///   - forceRefresh: Si es true, ignora el cache
    /// - Returns: Modelo GameDetail con toda la información
    /// - Throws: AppError con el tipo específico de error ocurrido
    func fetchGameDetail(id: Int, forceRefresh: Bool) async throws(AppError) -> GameDetail
}
