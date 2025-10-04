//
//  GameDetailEntity.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation
import SwiftData

/// Entidad de SwiftData para persistir detalles completos de juegos
@Model
final class GameDetailEntity {
    
    // MARK: - Properties
    
    @Attribute(.unique) var id: Int
    
    var title: String
    var thumbnail: String
    var status: String
    var shortDescription: String
    var gameDescription: String
    var gameUrl: String
    var genre: String
    var platform: String
    var publisher: String
    var developer: String
    var releaseDate: Date?
    var profileUrl: String
    
    // Requisitos del sistema (opcionales, algunos juegos no los tienen)
    var requirementsOS: String?
    var requirementsProcessor: String?
    var requirementsMemory: String?
    var requirementsGraphics: String?
    var requirementsStorage: String?
    
    // Screenshots almacenados como JSON string
    // SwiftData no soporta arrays de structs directamente
    var screenshotsJSON: String?
    
    var cachedAt: Date
    
    // MARK: - Initialization
    
    init(
        id: Int,
        title: String,
        thumbnail: String,
        status: String,
        shortDescription: String,
        gameDescription: String,
        gameUrl: String,
        genre: String,
        platform: String,
        publisher: String,
        developer: String,
        releaseDate: Date?,
        profileUrl: String,
        requirementsOS: String? = nil,
        requirementsProcessor: String? = nil,
        requirementsMemory: String? = nil,
        requirementsGraphics: String? = nil,
        requirementsStorage: String? = nil,
        screenshotsJSON: String? = nil,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.status = status
        self.shortDescription = shortDescription
        self.gameDescription = gameDescription
        self.gameUrl = gameUrl
        self.genre = genre
        self.platform = platform
        self.publisher = publisher
        self.developer = developer
        self.releaseDate = releaseDate
        self.profileUrl = profileUrl
        self.requirementsOS = requirementsOS
        self.requirementsProcessor = requirementsProcessor
        self.requirementsMemory = requirementsMemory
        self.requirementsGraphics = requirementsGraphics
        self.requirementsStorage = requirementsStorage
        self.screenshotsJSON = screenshotsJSON
        self.cachedAt = cachedAt
    }
}
