//
//  GameDetailMapper.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Mapper para convertir entre DTOs, Models y Entities de detalles de juego
enum GameDetailMapper {
    
    // MARK: - DTO to Model
    
    /// Convierte un GameDetailDTO a GameDetail
    /// - Parameter dto: DTO recibido de la API
    /// - Returns: Modelo de dominio con los detalles
    static func toModel(from dto: GameDetailDTO) -> GameDetail {
        GameDetail(
            id: dto.id,
            title: dto.title,
            thumbnail: dto.thumbnail,
            status: dto.status,
            shortDescription: dto.shortDescription,
            description: dto.description,
            gameUrl: dto.gameUrl,
            genre: dto.genre,
            platform: dto.platform,
            publisher: dto.publisher,
            developer: dto.developer,
            releaseDate: parseDate(from: dto.releaseDate),
            profileUrl: dto.profileUrl,
            minimumSystemRequirements: mapSystemRequirements(from: dto.minimumSystemRequirements),
            screenshots: mapScreenshots(from: dto.screenshots)
        )
    }
    
    // MARK: - Model to Entity
    
    /// Convierte GameDetail a GameDetailEntity para persistencia
    /// - Parameter model: Modelo de dominio
    /// - Returns: Entidad de SwiftData
    static func toEntity(from model: GameDetail) -> GameDetailEntity {
        // Convertimos el array de screenshots a JSON para almacenarlo
        let screenshotsJSON = encodeScreenshots(model.screenshots)
        
        return GameDetailEntity(
            id: model.id,
            title: model.title,
            thumbnail: model.thumbnail,
            status: model.status,
            shortDescription: model.shortDescription,
            gameDescription: model.description,
            gameUrl: model.gameUrl,
            genre: model.genre,
            platform: model.platform,
            publisher: model.publisher,
            developer: model.developer,
            releaseDate: model.releaseDate,
            profileUrl: model.profileUrl,
            requirementsOS: model.minimumSystemRequirements?.os,
            requirementsProcessor: model.minimumSystemRequirements?.processor,
            requirementsMemory: model.minimumSystemRequirements?.memory,
            requirementsGraphics: model.minimumSystemRequirements?.graphics,
            requirementsStorage: model.minimumSystemRequirements?.storage,
            screenshotsJSON: screenshotsJSON
        )
    }
    
    // MARK: - Entity to Model
    
    /// Convierte GameDetailEntity a GameDetail
    /// - Parameter entity: Entidad de SwiftData
    /// - Returns: Modelo de dominio
    static func toModel(from entity: GameDetailEntity) -> GameDetail {
        // Decodificamos el JSON de screenshots
        let screenshots = decodeScreenshots(from: entity.screenshotsJSON)
        
        // Construimos los requisitos del sistema si existen
        let requirements = buildSystemRequirements(from: entity)
        
        return GameDetail(
            id: entity.id,
            title: entity.title,
            thumbnail: entity.thumbnail,
            status: entity.status,
            shortDescription: entity.shortDescription,
            description: entity.gameDescription,
            gameUrl: entity.gameUrl,
            genre: entity.genre,
            platform: entity.platform,
            publisher: entity.publisher,
            developer: entity.developer,
            releaseDate: entity.releaseDate,
            profileUrl: entity.profileUrl,
            minimumSystemRequirements: requirements,
            screenshots: screenshots
        )
    }
    
    // MARK: - Helper Methods
    
    /// Mapea SystemRequirementsDTO a SystemRequirements
    private static func mapSystemRequirements(from dto: SystemRequirementsDTO?) -> SystemRequirements? {
        guard let dto = dto,
              let os = dto.os,
              let processor = dto.processor,
              let memory = dto.memory,
              let graphics = dto.graphics,
              let storage = dto.storage else {
            return nil
        }
        
        return SystemRequirements(
            os: os,
            processor: processor,
            memory: memory,
            graphics: graphics,
            storage: storage
        )
    }
    
    /// Mapea array de ScreenshotDTO a array de Screenshot
    private static func mapScreenshots(from dtos: [ScreenshotDTO]?) -> [Screenshot] {
        guard let dtos = dtos else { return [] }
        
        return dtos.map { dto in
            Screenshot(id: dto.id, imageUrl: dto.image)
        }
    }
    
    /// Construye SystemRequirements desde una entidad
    private static func buildSystemRequirements(from entity: GameDetailEntity) -> SystemRequirements? {
        guard let os = entity.requirementsOS,
              let processor = entity.requirementsProcessor,
              let memory = entity.requirementsMemory,
              let graphics = entity.requirementsGraphics,
              let storage = entity.requirementsStorage else {
            return nil
        }
        
        return SystemRequirements(
            os: os,
            processor: processor,
            memory: memory,
            graphics: graphics,
            storage: storage
        )
    }
    
    /// Codifica array de screenshots a JSON string
    private static func encodeScreenshots(_ screenshots: [Screenshot]) -> String? {
        // Creamos un array de diccionarios para codificar
        let screenshotsData = screenshots.map { ["id": $0.id, "imageUrl": $0.imageUrl] }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: screenshotsData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    /// Decodifica JSON string a array de screenshots
    private static func decodeScreenshots(from json: String?) -> [Screenshot] {
        guard let json = json,
              let data = json.data(using: .utf8),
              let screenshotsData = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return screenshotsData.compactMap { dict in
            guard let id = dict["id"] as? Int,
                  let imageUrl = dict["imageUrl"] as? String else {
                return nil
            }
            return Screenshot(id: id, imageUrl: imageUrl)
        }
    }
    
    /// Parsea fecha desde string
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
