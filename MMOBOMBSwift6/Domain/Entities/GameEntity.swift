//
//  GameEntity.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData

/// Entidad de SwiftData para persistir juegos
/// @Model hace que esta clase sea observable y persistible automáticamente
@Model
final class GameEntity {
    
    // MARK: - Properties
    
    /// Identificador único del juego
    /// @Attribute(.unique) previene duplicados en la base de datos
    @Attribute(.unique) var id: Int
    
    var title: String
    var thumbnail: String
    var shortDescription: String
    var gameUrl: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: Date?
    var profileUrl: String
    
    /// Fecha en que se guardó en cache
    /// Nos permite saber si los datos están obsoletos
    var cachedAt: Date
    
    // MARK: - Initialization
    
    init(
        id: Int,
        title: String,
        thumbnail: String,
        shortDescription: String,
        gameUrl: String,
        genre: String,
        platform: String,
        publisher: String,
        developer: String,
        releaseDate: Date?,
        profileUrl: String,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.shortDescription = shortDescription
        self.gameUrl = gameUrl
        self.genre = genre
        self.platform = platform
        self.publisher = publisher
        self.developer = developer
        self.releaseDate = releaseDate
        self.profileUrl = profileUrl
        self.cachedAt = cachedAt
    }
}
