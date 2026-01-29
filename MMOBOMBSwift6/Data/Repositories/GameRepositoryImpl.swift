//
//  GameRepositoryImpl.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData
import OSLog

/// Implementación del repositorio de juegos
/// Gestiona la obtención de datos desde API y cache local (SwiftData)
/// @Observable permite inyectarlo en el Environment de SwiftUI
/// @MainActor garantiza que todas las operaciones con ModelContext sean thread-safe
@Observable
@MainActor
final class GameRepositoryImpl: GameRepositoryProtocol {
    
    // MARK: - Properties
    
    /// Contexto de SwiftData para operaciones de persistencia
    private let modelContext: ModelContext
    
    /// Manager de red para peticiones a la API
    private let networkManager: NetworkManager
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext, networkManager: NetworkManager = .shared) {
        self.modelContext = modelContext
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    
    func fetchGames(forceRefresh: Bool = false) async throws(AppError) -> [Game] {
        Logger.store.info("Fetching games (forceRefresh: \(forceRefresh))")
        
        // Si no forzamos refresh, intentamos obtener desde cache
        if !forceRefresh {
            let cachedGames = try fetchGamesFromCache()
            
            // Si hay datos en cache y no están expirados, los devolvemos
            if !cachedGames.isEmpty && !isCacheExpired(cachedGames.first?.cachedAt) {
                Logger.database.info("Returning \(cachedGames.count) games from cache")
                return cachedGames.map { GameMapper.toModel(from: $0) }
            } else {
                Logger.database.debug("Cache expired or empty, fetching from API")
            }
        }
        
        // Si no hay cache válido, obtenemos de la API con reintentos
        do {
            let gamesDTO: [GameDTO] = try await networkManager.fetchWithRetry(from: .gamesList)
            
            // Convertimos DTOs a Models
            let games = gamesDTO.map { GameMapper.toModel(from: $0) }
            
            Logger.store.info("Successfully fetched \(games.count) games from API")
            
            // Guardamos en cache para futuras consultas
            saveGamesToCache(games)
            
            return games
        } catch {
            Logger.network.error("Failed to fetch games: \(error.localizedDescription)")
            throw AppError.from(error)
        }
    }
    
    func fetchGameDetail(id: Int, forceRefresh: Bool = false) async throws(AppError) -> GameDetail {
        Logger.store.info("Fetching game detail for id: \(id) (forceRefresh: \(forceRefresh))")
        
        // Intentamos obtener desde cache si no forzamos refresh
        if !forceRefresh {
            if let cachedDetail = try fetchGameDetailFromCache(id: id),
               !isCacheExpired(cachedDetail.cachedAt) {
                Logger.database.info("Returning game detail from cache for id: \(id)")
                return GameDetailMapper.toModel(from: cachedDetail)
            } else {
                Logger.database.debug("Cache expired or not found for game \(id), fetching from API")
            }
        }
        
        // Obtenemos desde la API con reintentos
        do {
            let detailDTO: GameDetailDTO = try await networkManager.fetchWithRetry(from: .gameDetail(id: id))
            
            // Convertimos a modelo
            let detail = GameDetailMapper.toModel(from: detailDTO)
            
            Logger.store.info("Successfully fetched game detail for id: \(id)")
            
            // Guardamos en cache
            saveGameDetailToCache(detail)
            
            return detail
        } catch {
            Logger.network.error("Failed to fetch game detail \(id): \(error.localizedDescription)")
            throw AppError.from(error)
        }
    }
    
    // MARK: - Private Cache Methods
    
    /// Obtiene juegos desde el cache de SwiftData
    private func fetchGamesFromCache() throws(AppError) -> [GameEntity] {
        let descriptor = FetchDescriptor<GameEntity>(
            sortBy: [SortDescriptor(\.title)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.database.error("Failed to fetch games from cache: \(error.localizedDescription)")
            throw AppError.database("Error al obtener juegos del cache")
        }
    }
    
    /// Obtiene detalle de un juego desde cache
    private func fetchGameDetailFromCache(id: Int) throws(AppError) -> GameDetailEntity? {
        // Capturamos el id en una variable local para usarlo en el predicado
        let gameId = id
        
        let predicate = #Predicate<GameDetailEntity> { entity in
            entity.id == gameId
        }
        
        let descriptor = FetchDescriptor<GameDetailEntity>(predicate: predicate)
        
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            Logger.database.error("Failed to fetch game detail from cache: \(error.localizedDescription)")
            throw AppError.database("Error al obtener detalle del cache")
        }
    }
    
    /// Guarda juegos en cache usando estrategia de upsert (actualizar o insertar)
    /// Mejora: NO borra todo el cache, solo actualiza lo necesario
    private func saveGamesToCache(_ games: [Game]) {
        Logger.database.info("Saving \(games.count) games to cache")
        
        for game in games {
            // Buscar si ya existe
            let gameId = game.id
            let predicate = #Predicate<GameEntity> { $0.id == gameId }
            let descriptor = FetchDescriptor<GameEntity>(predicate: predicate)
            
            do {
                if let existing = try modelContext.fetch(descriptor).first {
                    // Actualizar entidad existente
                    existing.title = game.title
                    existing.thumbnail = game.thumbnail
                    existing.shortDescription = game.shortDescription
                    existing.gameUrl = game.gameUrl
                    existing.genre = game.genre
                    existing.platform = game.platform
                    existing.publisher = game.publisher
                    existing.developer = game.developer
                    existing.releaseDate = game.releaseDate
                    existing.profileUrl = game.profileUrl
                    existing.cachedAt = Date() // Actualizar timestamp
                    
                    Logger.database.debug("Updated existing game: \(game.title)")
                } else {
                    // Insertar nuevo
                    let entity = GameMapper.toEntity(from: game)
                    modelContext.insert(entity)
                    
                    Logger.database.debug("Inserted new game: \(game.title)")
                }
            } catch {
                Logger.database.error("Error upserting game \(game.id): \(error.localizedDescription)")
            }
        }
        
        // Guardamos los cambios
        do {
            try modelContext.save()
            Logger.database.info("Successfully saved games to cache")
        } catch {
            Logger.database.error("Failed to save games to cache: \(error.localizedDescription)")
        }
    }
    
    /// Guarda detalle de juego en cache
    private func saveGameDetailToCache(_ detail: GameDetail) {
        Logger.database.info("Saving game detail to cache for id: \(detail.id)")
        
        // Capturamos el id en una variable local para usarlo en el predicado
        let detailId = detail.id
        
        // Buscamos si ya existe para actualizarlo
        let predicate = #Predicate<GameDetailEntity> { entity in
            entity.id == detailId
        }
        
        let descriptor = FetchDescriptor<GameDetailEntity>(predicate: predicate)
        
        if let existingEntity = try? modelContext.fetch(descriptor).first {
            // Si existe, lo eliminamos para insertar el nuevo
            modelContext.delete(existingEntity)
            Logger.database.debug("Deleted existing game detail for id: \(detailId)")
        }
        
        // Insertamos el nuevo detalle
        let entity = GameDetailMapper.toEntity(from: detail)
        modelContext.insert(entity)
        
        // Guardamos
        do {
            try modelContext.save()
            Logger.database.info("Successfully saved game detail to cache")
        } catch {
            Logger.database.error("Failed to save game detail: \(error.localizedDescription)")
        }
    }
    
    /// Verifica si el cache ha expirado
    /// - Parameter cachedDate: Fecha en que se guardó el dato
    /// - Returns: true si ha expirado, false si aún es válido
    private func isCacheExpired(_ cachedDate: Date?) -> Bool {
        guard let cachedDate = cachedDate else {
            Logger.database.debug("No cached date found, considering expired")
            return true
        }
        
        let timeInterval = Date().timeIntervalSince(cachedDate)
        let isExpired = timeInterval > AppConfiguration.cacheExpirationTime
        
        if isExpired {
            Logger.database.debug("Cache expired (\(timeInterval)s > \(AppConfiguration.cacheExpirationTime)s)")
        }
        
        return isExpired
    }
}
