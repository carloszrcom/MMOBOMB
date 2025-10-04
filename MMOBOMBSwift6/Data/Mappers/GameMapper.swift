//
//  GameMapper.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Mapper para convertir entre DTOs, Models y Entities
/// Centraliza la lógica de transformación de datos
enum GameMapper {
    
    // MARK: - DTO to Model
    
    /// Convierte un GameDTO (de la API) a un Game (modelo de dominio)
    /// - Parameter dto: El DTO recibido de la API
    /// - Returns: El modelo de dominio
    static func toModel(from dto: GameDTO) -> Game {
        Game(
            id: dto.id,
            title: dto.title,
            thumbnail: dto.thumbnail,
            shortDescription: dto.shortDescription,
            gameUrl: dto.gameUrl,
            genre: dto.genre,
            platform: dto.platform,
            publisher: dto.publisher,
            developer: dto.developer,
            releaseDate: parseDate(from: dto.releaseDate),
            profileUrl: dto.profileUrl
        )
    }
    
    // MARK: - Model to Entity
    
    /// Convierte un Game (modelo) a GameEntity (para persistir en SwiftData)
    /// - Parameter model: El modelo de dominio
    /// - Returns: La entidad para SwiftData
    static func toEntity(from model: Game) -> GameEntity {
        GameEntity(
            id: model.id,
            title: model.title,
            thumbnail: model.thumbnail,
            shortDescription: model.shortDescription,
            gameUrl: model.gameUrl,
            genre: model.genre,
            platform: model.platform,
            publisher: model.publisher,
            developer: model.developer,
            releaseDate: model.releaseDate,
            profileUrl: model.profileUrl
        )
    }
    
    // MARK: - Entity to Model
    
    /// Convierte un GameEntity (de SwiftData) a Game (modelo de dominio)
    /// - Parameter entity: La entidad de SwiftData
    /// - Returns: El modelo de dominio
    static func toModel(from entity: GameEntity) -> Game {
        Game(
            id: entity.id,
            title: entity.title,
            thumbnail: entity.thumbnail,
            shortDescription: entity.shortDescription,
            gameUrl: entity.gameUrl,
            genre: entity.genre,
            platform: entity.platform,
            publisher: entity.publisher,
            developer: entity.developer,
            releaseDate: entity.releaseDate,
            profileUrl: entity.profileUrl
        )
    }
    
    // MARK: - Helper Methods
    
    /// Parsea una fecha en formato string a Date
    /// La API devuelve fechas en formato "yyyy-MM-dd"
    /// - Parameter dateString: String con la fecha
    /// - Returns: Date parseada o nil si el formato es inválido
    private static func parseDate(from dateString: String?) -> Date? {
        guard let dateString = dateString, !dateString.isEmpty else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter.date(from: dateString)
    }
}
