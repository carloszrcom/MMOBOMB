//
//  GameRepositoryImpl.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData

/// Implementación del repositorio de juegos
/// Gestiona la obtención de datos desde API y cache local (SwiftData)
final class GameRepositoryImpl: GameRepository {
    
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
    
    // MARK: - GameRepository Implementation
    
    func fetchGames(forceRefresh: Bool = false) async throws -> [Game] {
        // Si no forzamos refresh, intentamos obtener desde cache
        if !forceRefresh {
            let cachedGames = try fetchGamesFromCache()
            
            // Si hay datos en cache y no están expirados, los devolvemos
            if !cachedGames.isEmpty && !isCacheExpired(cachedGames.first?.cachedAt) {
                return cachedGames.map { GameMapper.toModel(from: $0) }
            }
        }
        
        // Si no hay cache válido, obtenemos de la API
        let gamesDTO: [GameDTO] = try await networkManager.fetch(from: .gamesList)
        
        // Convertimos DTOs a Models
        let games = gamesDTO.map { GameMapper.toModel(from: $0) }
        
        // Guardamos en cache para futuras consultas
        await saveGamesToCache(games)
        
        return games
    }
    
    func fetchGameDetail(id: Int, forceRefresh: Bool = false) async throws -> GameDetail {
        // Intentamos obtener desde cache si no forzamos refresh
        if !forceRefresh {
            if let cachedDetail = try fetchGameDetailFromCache(id: id),
               !isCacheExpired(cachedDetail.cachedAt) {
                return GameDetailMapper.toModel(from: cachedDetail)
            }
        }
        
        // Obtenemos desde la API
        let detailDTO: GameDetailDTO = try await networkManager.fetch(from: .gameDetail(id: id))
        
        // Convertimos a modelo
        let detail = GameDetailMapper.toModel(from: detailDTO)
        
        // Guardamos en cache
        await saveGameDetailToCache(detail)
        
        return detail
    }
    
    // MARK: - Private Cache Methods
    
    /// Obtiene juegos desde el cache de SwiftData
    private func fetchGamesFromCache() throws -> [GameEntity] {
        let descriptor = FetchDescriptor<GameEntity>(
            sortBy: [SortDescriptor(\.title)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Obtiene detalle de un juego desde cache
    private func fetchGameDetailFromCache(id: Int) throws -> GameDetailEntity? {
        // Capturamos el id en una variable local para usarlo en el predicado
        let gameId = id
        
        let predicate = #Predicate<GameDetailEntity> { entity in
            entity.id == gameId
        }
        
        let descriptor = FetchDescriptor<GameDetailEntity>(predicate: predicate)
        
        return try modelContext.fetch(descriptor).first
    }
    
    /// Guarda juegos en cache
    /// Elimina los juegos antiguos y guarda los nuevos
    @MainActor
    private func saveGamesToCache(_ games: [Game]) async {
        // Eliminamos todos los juegos antiguos del cache
        let descriptor = FetchDescriptor<GameEntity>()
        
        if let oldGames = try? modelContext.fetch(descriptor) {
            oldGames.forEach { modelContext.delete($0) }
        }
        
        // Insertamos los nuevos juegos
        games.forEach { game in
            let entity = GameMapper.toEntity(from: game)
            modelContext.insert(entity)
        }
        
        // Guardamos los cambios
        try? modelContext.save()
    }
    
    /// Guarda detalle de juego en cache
    @MainActor
    private func saveGameDetailToCache(_ detail: GameDetail) async {
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
        }
        
        // Insertamos el nuevo detalle
        let entity = GameDetailMapper.toEntity(from: detail)
        modelContext.insert(entity)
        
        // Guardamos
        try? modelContext.save()
    }
    
    /// Verifica si el cache ha expirado
    /// - Parameter cachedDate: Fecha en que se guardó el dato
    /// - Returns: true si ha expirado, false si aún es válido
    private func isCacheExpired(_ cachedDate: Date?) -> Bool {
        guard let cachedDate = cachedDate else { return true }
        
        let timeInterval = Date().timeIntervalSince(cachedDate)
        return timeInterval > AppConfiguration.cacheExpirationTime
    }
}


//import Foundation
//import SwiftData
//
///// Implementación del repositorio de juegos
///// Gestiona la obtención de datos desde API y cache local (SwiftData)
//final class GameRepositoryImpl: GameRepository {
//    
//    // MARK: - Properties
//    
//    /// Contexto de SwiftData para operaciones de persistencia
//    private let modelContext: ModelContext
//    
//    /// Manager de red para peticiones a la API
//    private let networkManager: NetworkManager
//    
//    // MARK: - Initialization
//    
//    init(modelContext: ModelContext, networkManager: NetworkManager = .shared) {
//        self.modelContext = modelContext
//        self.networkManager = networkManager
//    }
//    
//    // MARK: - GameRepository Implementation
//    
//    func fetchGames(forceRefresh: Bool = false) async throws -> [Game] {
//        // Si no forzamos refresh, intentamos obtener desde cache
//        if !forceRefresh {
//            let cachedGames = try fetchGamesFromCache()
//            
//            // Si hay datos en cache y no están expirados, los devolvemos
//            if !cachedGames.isEmpty && !isCacheExpired(cachedGames.first?.cachedAt) {
//                return cachedGames.map { GameMapper.toModel(from: $0) }
//            }
//        }
//        
//        // Si no hay cache válido, obtenemos de la API
//        let gamesDTO: [GameDTO] = try await networkManager.fetch(from: .gamesList)
//        
//        // Convertimos DTOs a Models
//        let games = gamesDTO.map { GameMapper.toModel(from: $0) }
//        
//        // Guardamos en cache para futuras consultas
//        await saveGamesToCache(games)
//        
//        return games
//    }
//    
//    func fetchGameDetail(id: Int, forceRefresh: Bool = false) async throws -> GameDetail {
//        // Intentamos obtener desde cache si no forzamos refresh
//        if !forceRefresh {
//            if let cachedDetail = try fetchGameDetailFromCache(id: id),
//               !isCacheExpired(cachedDetail.cachedAt) {
//                return GameDetailMapper.toModel(from: cachedDetail)
//            }
//        }
//        
//        // Obtenemos desde la API
//        let detailDTO: GameDetailDTO = try await networkManager.fetch(from: .gameDetail(id: id))
//        
//        // Convertimos a modelo
//        let detail = GameDetailMapper.toModel(from: detailDTO)
//        
//        // Guardamos en cache
//        await saveGameDetailToCache(detail)
//        
//        return detail
//    }
//    
//    // MARK: - Private Cache Methods
//    
//    /// Obtiene juegos desde el cache de SwiftData
//    private func fetchGamesFromCache() throws -> [GameEntity] {
//        let descriptor = FetchDescriptor<GameEntity>(
//            sortBy: [SortDescriptor(\.title)]
//        )
//        
//        return try modelContext.fetch(descriptor)
//    }
//    
//    /// Obtiene detalle de un juego desde cache
//    private func fetchGameDetailFromCache(id: Int) throws -> GameDetailEntity? {
//        let predicate = #Predicate<GameDetailEntity> { entity in
//            entity.id == id
//        }
//        
//        let descriptor = FetchDescriptor<GameDetailEntity>(predicate: predicate)
//        
//        return try modelContext.fetch(descriptor).first
//    }
//    
//    /// Guarda juegos en cache
//    /// Elimina los juegos antiguos y guarda los nuevos
//    @MainActor
//    private func saveGamesToCache(_ games: [Game]) async {
//        // Eliminamos todos los juegos antiguos del cache
//        let descriptor = FetchDescriptor<GameEntity>()
//        
//        if let oldGames = try? modelContext.fetch(descriptor) {
//            oldGames.forEach { modelContext.delete($0) }
//        }
//        
//        // Insertamos los nuevos juegos
//        games.forEach { game in
//            let entity = GameMapper.toEntity(from: game)
//            modelContext.insert(entity)
//        }
//        
//        // Guardamos los cambios
//        try? modelContext.save()
//    }
//    
//    /// Guarda detalle de juego en cache
//    @MainActor
//    private func saveGameDetailToCache(_ detail: GameDetail) async {
//        // Buscamos si ya existe para actualizarlo
//        let predicate = #Predicate<GameDetailEntity> { entity in
//            entity.id == detail.id
//        }
//        
//        let descriptor = FetchDescriptor<GameDetailEntity>(predicate: predicate)
//        
//        if let existingEntity = try? modelContext.fetch(descriptor).first {
//            // Si existe, lo eliminamos para insertar el nuevo
//            modelContext.delete(existingEntity)
//        }
//        
//        // Insertamos el nuevo detalle
//        let entity = GameDetailMapper.toEntity(from: detail)
//        modelContext.insert(entity)
//        
//        // Guardamos
//        try? modelContext.save()
//    }
//    
//    /// Verifica si el cache ha expirado
//    /// - Parameter cachedDate: Fecha en que se guardó el dato
//    /// - Returns: true si ha expirado, false si aún es válido
//    private func isCacheExpired(_ cachedDate: Date?) -> Bool {
//        guard let cachedDate = cachedDate else { return true }
//        
//        let timeInterval = Date().timeIntervalSince(cachedDate)
//        return timeInterval > AppConfiguration.cacheExpirationTime
//    }
//}
