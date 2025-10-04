//
//  ScreenshotDTO.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// DTO para las capturas de pantalla del juego
struct ScreenshotDTO: Codable, Identifiable {
    let id: Int
    let image: String
}
