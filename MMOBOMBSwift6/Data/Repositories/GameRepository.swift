//
//  GameRepository.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Protocolo que define las operaciones del repositorio de juegos
/// Permite inyectar implementaciones mock para testing
protocol GameRepository {
    
    /// Obtiene el listado completo de juegos
    /// Primero intenta desde cache, si no hay o está expirado, obtiene de la API
    /// - Parameter forceRefresh: Si es true, ignora el cache y obtiene datos frescos
    /// - Returns: Array de modelos Game
    func fetchGames(forceRefresh: Bool) async throws -> [Game]
    
    /// Obtiene los detalles de un juego específico
    /// - Parameters:
    ///   - id: Identificador del juego
    ///   - forceRefresh: Si es true, ignora el cache
    /// - Returns: Modelo GameDetail con toda la información
    func fetchGameDetail(id: Int, forceRefresh: Bool) async throws -> GameDetail
}
